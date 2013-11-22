#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include "moment.h"
#include "moment_fmt.h"

typedef int64_t I64V;

#if IVSIZE >= 8
# define SvI64V(sv)         (I64V)SvIV(sv)
# define newSVi64v(i64)     newSViv((IV)i64)
# define XSRETURN_I64V(i64) XSRETURN_IV((IV)i64)
#else
# define SvI64V(sv)         (I64V)SvNV(sv)
# define newSVi64v(i64)     newSVnv((NV)i64)
# define XSRETURN_I64V(i64) XSRETURN_NV((NV)i64)
#endif

#ifndef STR_WITH_LEN
#define STR_WITH_LEN(s)  ("" s ""), (sizeof(s)-1)
#endif

#ifndef gv_stashpvs
#define gv_stashpvs(s, flags) gv_stashpvn(STR_WITH_LEN(s), flags)
#endif

#ifndef XSRETURN_BOOL
#define XSRETURN_BOOL(v) STMT_START { ST(0) = boolSV(v); XSRETURN(1); } STMT_END
#endif

#ifndef XSRETURN_SV
#define XSRETURN_SV(sv) STMT_START { ST(0) = sv; XSRETURN(1); } STMT_END
#endif

#ifndef cBOOL
#define cBOOL(cbool) ((cbool) ? (bool)1 : (bool)0)
#endif

#ifndef PERL_UNUSED_VAR
#  define PERL_UNUSED_VAR(x) ((void)x)
#endif

#define MY_CXT_KEY "Time::Moment::_guts" XS_VERSION
typedef struct {
    HV *stash;
} my_cxt_t;

START_MY_CXT

static void
setup_my_cxt(pTHX_ pMY_CXT) {
    MY_CXT.stash = gv_stashpvs("Time::Moment", GV_ADD);
}

static SV *
THX_sv_as_object(pTHX_ SV *sv, const char *name) {
    dSP;
    SV *rv;
    GV *method;
    int count;

    if (!SvROK(sv))
        return NULL;
    rv = SvRV(sv);
    if (!SvOBJECT(rv) || !SvSTASH(rv))
        return NULL;
    if (!(method = gv_fetchmethod(SvSTASH(rv), name)))
        return NULL;

    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    XPUSHs(sv);
    PUTBACK;
    count = call_sv((SV *)method, G_SCALAR);
    SPAGAIN;
    if (count != 1)
        croak("method call returned %d values, 1 expected", count);
    rv = newSVsv(POPs);
    PUTBACK;
    FREETMPS;
    LEAVE;
    return sv_2mortal(rv);
}

static SV *
THX_sv_2neat(pTHX_ SV *sv) {
    if (sv_isobject(sv)) {
        const char *name = sv_reftype(SvRV(sv), 1);
        const char *type = sv_reftype(SvRV(sv), 0);
        SV *dsv = sv_newmortal();
        sv_setpvf(dsv, "%s=%s(0x%p)", name, type, SvRV(sv));
        sv = dsv;
    }
    return sv;
}

static void
THX_croak_cmp(pTHX_ SV *sv1, SV *sv2, const bool swap, const char *name) {
    if (swap) {
        SV * const tmp = sv1;
        sv1 = sv2;
        sv2 = tmp;
    }
    croak("A %s object can only be compared to another %s object ('%"SVf"', '%"SVf"')",
        name, name, THX_sv_2neat(aTHX_ sv1), THX_sv_2neat(aTHX_ sv2));
}

static SV *
THX_newSVmoment(pTHX_ const moment_t *m, HV *stash) {
    SV *pv = newSVpvn((const char *)m, sizeof(moment_t));
    SV *sv = newRV_noinc(pv);
    sv_bless(sv, stash);
    SvREADONLY_on(pv);
    return sv;
}

static bool
THX_sv_isa_stash(pTHX_ SV *sv, const char *klass, HV *stash) {
    SV *rv;

    SvGETMAGIC(sv);
    if (!SvROK(sv))
        return FALSE;
    rv = SvRV(sv);
    if (!(SvOBJECT(rv) && SvSTASH(rv) && SvPOKp(rv)))
        return FALSE;
    if (!(SvSTASH(rv) == stash || sv_derived_from(sv, klass)))
        return FALSE;
    return TRUE;
}

static HV *
THX_stash_constructor(pTHX_ SV *sv, const char *name, STRLEN namelen, HV *stash) {
    const char *pv;
    STRLEN len;

    SvGETMAGIC(sv);
    if (SvROK(sv)) {
        SV * const rv = SvRV(sv);
        if (SvOBJECT(rv) && SvSTASH(rv))
            return SvSTASH(rv);
    }
    pv = SvPV_nomg_const(sv, len);
    if (len == namelen && memEQ(pv, name, namelen))
        return stash;
    return gv_stashpvn(pv, len, GV_ADD);
}

static bool
THX_sv_isa_moment(pTHX_ SV *sv) {
    dMY_CXT;
    return THX_sv_isa_stash(aTHX_ sv, "Time::Moment", MY_CXT.stash);
}

static moment_t *
THX_sv_2moment_ptr(pTHX_ SV *sv, const char *name) {
    if (!THX_sv_isa_moment(aTHX_ sv))
        croak("%s is not an instance of Time::Moment", name);
    return (moment_t *)SvPVX_const(SvRV(sv));
}

static moment_t
THX_sv_2moment(pTHX_ SV *sv, const char *name) {
    return *THX_sv_2moment_ptr(aTHX_ sv, name);
}

static SV *
THX_sv_2moment_coerce_sv(pTHX_ SV *sv) {
    SV *res;

    if (THX_sv_isa_moment(aTHX_ sv))
        return sv;
    res = THX_sv_as_object(aTHX_ sv, "__as_Time_Moment");
    if(!res || !THX_sv_isa_moment(aTHX_ res))
        croak("Cannot coerce object of type %"SVf" to Time::Moment", THX_sv_2neat(aTHX_ sv));
    return res;
}

#define dSTASH_CONSTRUCTOR(sv, name, dstash) \
    HV * const stash = THX_stash_constructor(aTHX_ sv, STR_WITH_LEN(name), dstash)

#define dSTASH_INVOCANT \
    HV * const stash = SvSTASH(SvRV(ST(0)))

#define dSTASH_CONSTRUCTOR_MOMENT(sv) \
    dMY_CXT; \
    dSTASH_CONSTRUCTOR(sv, "Time::Moment", MY_CXT.stash)

#define newSVmoment(m, stash) \
    THX_newSVmoment(aTHX_ m, stash)

#define sv_2moment_ptr(sv, name) \
    THX_sv_2moment_ptr(aTHX_ sv, name)

#define sv_2moment(sv, name) \
    THX_sv_2moment(aTHX_ sv, name)

#define sv_2moment_coerce_sv(sv) \
    THX_sv_2moment_coerce_sv(aTHX_ sv)

#define sv_isa_moment(sv) \
    THX_sv_isa_moment(aTHX_ sv)

#define croak_cmp(sv1, sv2, swap, name) \
    THX_croak_cmp(aTHX_ sv1, sv2, swap, name)

XS(XS_Time_Moment_nil) {
    dVAR; dXSARGS;
    PERL_UNUSED_VAR(items);
    XSRETURN_EMPTY;
}

XS(XS_Time_Moment_stringify) {
    dVAR; dXSARGS;
    if (items < 1)
        croak("Wrong number of arguments to Time::Moment::(\"\"");
    ST(0) = moment_strftime(sv_2moment_ptr(ST(0), "self"), "%c", 2);
    XSRETURN(1);
}

XS(XS_Time_Moment_ncmp) {
    dVAR; dXSARGS;
    const moment_t *m1, *m2;
    bool swap;
    SV *svm1, *svm2;

    if (items < 3)
        croak("Wrong number of arguments to Time::Moment::(<=>");

    svm1 = ST(0);
    svm2 = ST(1);
    swap = cBOOL(SvTRUE(ST(2)));

    if (!sv_isa_moment(svm2))
        croak_cmp(svm1, svm2, swap, "Time::Moment");
    m1 = sv_2moment_ptr(svm1, "self");
    m2 = sv_2moment_ptr(svm2, "other");
    if (swap) {
        const moment_t *tmp = m1;
        m1 = m2;
        m2 = tmp;
    }
    XSRETURN_IV(moment_compare(m1, m2));
}

MODULE = Time::Moment   PACKAGE = Time::Moment

PROTOTYPES: DISABLE

BOOT:
{
    MY_CXT_INIT;
    setup_my_cxt(aTHX_ aMY_CXT);
#if (PERL_REVISION == 5 && PERL_VERSION < 9)
    PL_amagic_generation++;
#endif
    sv_setsv(get_sv("Time::Moment::()", GV_ADD), &PL_sv_yes);
    newXS("Time::Moment::()", XS_Time_Moment_nil, file);
    newXS("Time::Moment::(\"\"", XS_Time_Moment_stringify, file);
    newXS("Time::Moment::(<=>", XS_Time_Moment_ncmp, file);
}

#ifdef USE_ITHREADS

void
CLONE(...)
CODE:
{
    MY_CXT_CLONE;
    setup_my_cxt(aTHX_ aMY_CXT);
    PERL_UNUSED_VAR(items);
}

#endif

moment_t 
from_epoch(klass, seconds, microsecond=0, offset=0)
    SV *klass
    I64V seconds
    IV microsecond
    IV offset
  PREINIT:
    dSTASH_CONSTRUCTOR_MOMENT(klass);
  CODE:
    RETVAL = moment_from_epoch(seconds, microsecond, offset);
  OUTPUT:
    RETVAL

void
from_object(klass, object)
    SV *klass
    SV *object
  PREINIT:
    dSTASH_CONSTRUCTOR_MOMENT(klass);
  CODE:
    XSRETURN_SV(sv_2moment_coerce_sv(object));

moment_t
with_offset(self, offset)
    const moment_t *self
    IV offset
  PREINIT:
    dSTASH_INVOCANT;
  CODE:
    RETVAL = moment_with_offset(self, offset);
  OUTPUT:
    RETVAL

void
year(self)
    const moment_t *self
  ALIAS:
    Time::Moment::year           =  0
    Time::Moment::quarter        =  1
    Time::Moment::month          =  2
    Time::Moment::day_of_year    =  3
    Time::Moment::day_of_quarter =  4
    Time::Moment::day_of_month   =  5
    Time::Moment::day_of_week    =  6
    Time::Moment::hour           =  7
    Time::Moment::minute         =  8
    Time::Moment::second         =  9
    Time::Moment::millisecond    = 10
    Time::Moment::microsecond    = 11
    Time::Moment::offset         = 12
  PREINIT:
    IV v = 0;
  PPCODE:
    switch (ix) {
        case  0: v = moment_year(self);             break;
        case  1: v = moment_quarter(self);          break;
        case  2: v = moment_month(self);            break;
        case  3: v = moment_day_of_year(self);      break;
        case  4: v = moment_day_of_quarter(self);   break;
        case  5: v = moment_day_of_month(self);     break;
        case  6: v = moment_day_of_week(self);      break;
        case  7: v = moment_hour(self);             break;
        case  8: v = moment_minute(self);           break;
        case  9: v = moment_second(self);           break;
        case 10: v = moment_millisecond(self);      break;
        case 11: v = moment_microsecond(self);      break;
        case 12: v = moment_offset(self);           break;
    }
    XSRETURN_IV(v);

void
epoch(self)
    const moment_t *self
  ALIAS:
    Time::Moment::epoch                 = 0
    Time::Moment::utc_rd_as_seconds     = 1
    Time::Moment::local_rd_as_seconds   = 2
  PREINIT:
    int64_t v = 0;
  PPCODE:
    switch (ix) {
        case 0: v = moment_epoch(self);             break;
        case 1: v = moment_utc_rd_seconds(self);    break;
        case 2: v = moment_local_rd_seconds(self);  break;
    }
    XSRETURN_I64V(v);

void
utc_rd_values(self)
    const moment_t *self
  ALIAS:
    Time::Moment::utc_rd_values     = 0
    Time::Moment::local_rd_values   = 1
  PREINIT:
    IV rdn, sod, nos;
  PPCODE:
    if (ix == 0)
        moment_to_utc_rd_values(self, &rdn, &sod, &nos);
    else
        moment_to_local_rd_values(self, &rdn, &sod, &nos);
    EXTEND(SP, 3);
    mPUSHi(rdn);
    mPUSHi(sod);
    mPUSHi(nos);
    XSRETURN(3);

IV
compare(self, other)
    const moment_t *self
    const moment_t *other
  CODE:
    RETVAL = moment_compare(self, other);
  OUTPUT:
    RETVAL

void
is_equal(self, other)
    const moment_t *self
    const moment_t *other
  ALIAS:
    Time::Moment::is_equal  = 0
    Time::Moment::is_before = 1
    Time::Moment::is_after  = 2
  PREINIT:
    bool v = FALSE;
  PPCODE:
    switch (ix) {
        case 0: v = moment_compare(self, other) == 0; break;
        case 1: v = moment_compare(self, other) < 0;  break;
        case 2: v = moment_compare(self, other) > 0;  break;
    }
    XSRETURN_BOOL(v);

void
strftime(self, format)
    const moment_t *self
    SV *format
  PREINIT:
    STRLEN len;
    const char *str;
  PPCODE:
    str = SvPV_const(format, len);
    XSRETURN_SV(moment_strftime(self, str, len));

