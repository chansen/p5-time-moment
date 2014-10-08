#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include "moment.h"
#include "moment_fmt.h"
#include "moment_parse.h"

typedef enum {
    MOMENT_PARAM_UNKNOWN=0,
    MOMENT_PARAM_YEAR,
    MOMENT_PARAM_MONTH,
    MOMENT_PARAM_DAY,
    MOMENT_PARAM_HOUR,
    MOMENT_PARAM_MINUTE,
    MOMENT_PARAM_SECOND,
    MOMENT_PARAM_NANOSECOND,
    MOMENT_PARAM_OFFSET,
    MOMENT_PARAM_LENIENT,
    MOMENT_PARAM_REDUCED,
} moment_param_t;

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

static moment_param_t
moment_param(const char *s, const STRLEN len) {
    switch (len) {
        case 3:
            if (memEQ(s, "day", 3))
                return MOMENT_PARAM_DAY;
            break;
        case 4:
            if (memEQ(s, "year", 4))
                return MOMENT_PARAM_YEAR;
            if (memEQ(s, "hour", 4))
                return MOMENT_PARAM_HOUR;
            break;
        case 5:
            if (memEQ(s, "month", 5))
                return MOMENT_PARAM_MONTH;
            break;
        case 6:
            if (memEQ(s, "minute", 6))
                return MOMENT_PARAM_MINUTE;
            if (memEQ(s, "second", 6))
                return MOMENT_PARAM_SECOND;
            if (memEQ(s, "offset", 6))
                return MOMENT_PARAM_OFFSET;
            break;
        case 7:
            if (memEQ(s, "lenient", 7))
                return MOMENT_PARAM_LENIENT;
            if (memEQ(s, "reduced", 7))
                return MOMENT_PARAM_REDUCED;
            break;
        case 10:
            if (memEQ(s, "nanosecond", 10))
                return MOMENT_PARAM_NANOSECOND;
            break;
    }
    return MOMENT_PARAM_UNKNOWN;
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
    return sv;
}

static SV *
THX_sv_set_moment(pTHX_ SV *sv, const moment_t *m) {
    if (!SvROK(sv))
        croak("panic: sv_set_moment called with nonreference");
    sv_setpvn_mg(SvRV(sv), (const char *)m, sizeof(moment_t));
    SvTEMP_off(sv);
    return sv;
}

static bool
THX_sv_isa_stash(pTHX_ SV *sv, const char *klass, HV *stash, size_t size) {
    SV *rv;

    SvGETMAGIC(sv);
    if (!SvROK(sv))
        return FALSE;
    rv = SvRV(sv);
    if (!(SvOBJECT(rv) && SvSTASH(rv) && SvPOKp(rv) && SvCUR(rv) == size))
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
    return THX_sv_isa_stash(aTHX_ sv, "Time::Moment", MY_CXT.stash, sizeof(moment_t));
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

#define sv_set_moment(sv, m) \
    THX_sv_set_moment(aTHX_ sv, m);

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

#define sv_reusable(sv) \
    (SvTEMP(sv) && SvREFCNT(sv) == 1 && SvROK(sv) && SvREFCNT(SvRV(sv)) == 1)

XS(XS_Time_Moment_nil) {
    dVAR; dXSARGS;
    PERL_UNUSED_VAR(items);
    XSRETURN_EMPTY;
}

XS(XS_Time_Moment_stringify) {
    dVAR; dXSARGS;
    if (items < 1)
        croak("Wrong number of arguments to Time::Moment::(\"\"");
    ST(0) = moment_to_string(sv_2moment_ptr(ST(0), "self"), FALSE);
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

#ifdef HAS_GETTIMEOFDAY
static moment_t
THX_moment_now(pTHX_ bool utc) {
    struct timeval tv;
    IV off, sec;

    gettimeofday(&tv, NULL);
    if (utc)
        off = 0;
    else {
        const time_t when = tv.tv_sec;
        struct tm *tm;
#ifdef HAS_LOCALTIME_R
        struct tm tmbuf;
#ifdef LOCALTIME_R_NEEDS_TZSET
        tzset();
#endif
        tm = localtime_r(&when, &tmbuf);
#else
        tm = localtime(&when);
#endif
        if (tm == NULL)
            croak("localtime() failed: %s", Strerror(errno));

        sec = ((1461 * (tm->tm_year - 1) >> 2) + tm->tm_yday - 25202) * 86400
            + tm->tm_hour * 3600 + tm->tm_min * 60 + tm->tm_sec;
        off = (sec - tv.tv_sec) / 60;
    }
    return moment_from_epoch(tv.tv_sec, tv.tv_usec * 1000, off);
}
#endif

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
new(klass, ...)
    SV *klass
  PREINIT:
    dSTASH_CONSTRUCTOR_MOMENT(klass);
    IV year = 1, month = 1, day = 1;
    IV hour = 0, minute = 0, second = 0, ns = 0, offset = 0;
    I32 i;
    STRLEN len;
    const char *str;
  CODE:
    if (((items - 1) % 2) != 0)
        croak("Odd number of elements in call to constructor when named parameters were expected");

    for (i = 1; i < items; i += 2) {
        str = SvPV_const(ST(i), len);
        switch (moment_param(str, len)) {
            case MOMENT_PARAM_YEAR:        year   = SvIV(ST(i+1)); break;
            case MOMENT_PARAM_MONTH:       month  = SvIV(ST(i+1)); break;
            case MOMENT_PARAM_DAY:         day    = SvIV(ST(i+1)); break;
            case MOMENT_PARAM_HOUR:        hour   = SvIV(ST(i+1)); break;
            case MOMENT_PARAM_MINUTE:      minute = SvIV(ST(i+1)); break;
            case MOMENT_PARAM_SECOND:      second = SvIV(ST(i+1)); break;
            case MOMENT_PARAM_NANOSECOND:  ns     = SvIV(ST(i+1)); break;
            case MOMENT_PARAM_OFFSET:      offset = SvIV(ST(i+1)); break;
            default: croak("Unrecognised parameter: '%s'", str);
        }
    }
    RETVAL = moment_new(year, month, day, hour, minute, second, ns, offset);
  OUTPUT:
    RETVAL

#ifdef HAS_GETTIMEOFDAY

moment_t
now(klass)
    SV *klass
  ALIAS:
    Time::Moment::now     = 0
    Time::Moment::now_utc = 1
  PREINIT:
    dSTASH_CONSTRUCTOR_MOMENT(klass);
  CODE:
    RETVAL = THX_moment_now(aTHX_ !!ix);
  OUTPUT:
    RETVAL

#endif

moment_t 
from_epoch(klass, seconds, nanosecond=0)
    SV *klass
    SV *seconds
    IV nanosecond
  PREINIT:
    dSTASH_CONSTRUCTOR_MOMENT(klass);
    int64_t secs;
    NV frac;
  CODE:
    if (items != 2 || SvIOK(seconds))
        secs = SvI64V(seconds);
    else {
        frac = SvNV(seconds);
        secs = (int64_t)frac;
        frac = frac - (NV)secs;
        if (frac < 0)
            frac = -frac;
        nanosecond = (IV)(frac * 1E9 + 0.5);
    }
    RETVAL = moment_from_epoch(secs, nanosecond, 0);
  OUTPUT:
    RETVAL

moment_t
from_string(klass, string, ...)
    SV *klass
    SV *string
  PREINIT:
    dSTASH_CONSTRUCTOR_MOMENT(klass);
    bool lenient;
    STRLEN len;
    const char *str;
    I32 i;
  CODE:
    if ((items % 2) != 0)
        croak("Odd number of elements in named parameters");

    lenient = FALSE;
    for (i = 2; i < items; i += 2) {
        str = SvPV_const(ST(i), len);
        switch (moment_param(str, len)) {
            case MOMENT_PARAM_LENIENT:
                lenient = cBOOL(SvTRUE((ST(i+1))));
                break;
            default: 
                croak("Unrecognised parameter: '%s'", str);
        }
    }
    str = SvPV_const(string, len);
    RETVAL = moment_from_string(str, len, lenient);
  OUTPUT:
    RETVAL

void
from_object(klass, object)
    SV *klass
    SV *object
  PREINIT:
    dSTASH_CONSTRUCTOR_MOMENT(klass);
    PERL_UNUSED_VAR(stash);
  CODE:
    XSRETURN_SV(sv_2moment_coerce_sv(object));

moment_t
at_utc(self)
    const moment_t *self
  PREINIT:
    dSTASH_INVOCANT;
  CODE:
    if (0 == moment_offset(self))
        XSRETURN(1);
    RETVAL = moment_with_offset_same_instant(self, 0);
    if (sv_reusable(ST(0))) {
        sv_set_moment(ST(0), &RETVAL);
        XSRETURN(1);
    }
  OUTPUT:
    RETVAL

moment_t
plus_seconds(self, value)
    const moment_t *self
    I64V value
  PREINIT:
    dSTASH_INVOCANT;
  ALIAS:
    Time::Moment::plus_years        =  MOMENT_UNIT_YEARS
    Time::Moment::plus_months       =  MOMENT_UNIT_MONTHS
    Time::Moment::plus_weeks        =  MOMENT_UNIT_WEEKS
    Time::Moment::plus_days         =  MOMENT_UNIT_DAYS
    Time::Moment::plus_hours        =  MOMENT_UNIT_HOURS
    Time::Moment::plus_minutes      =  MOMENT_UNIT_MINUTES
    Time::Moment::plus_seconds      =  MOMENT_UNIT_SECONDS
    Time::Moment::plus_milliseconds =  MOMENT_UNIT_MILLISECONDS
    Time::Moment::plus_microseconds =  MOMENT_UNIT_MICROSECONDS
    Time::Moment::plus_nanoseconds  =  MOMENT_UNIT_NANOSECONDS
  CODE:
    if (value == 0)
        XSRETURN(1);
    RETVAL = moment_plus_unit(self, (moment_unit_t)ix, value);
    if (sv_reusable(ST(0))) {
        sv_set_moment(ST(0), &RETVAL);
        XSRETURN(1);
    }
  OUTPUT:
    RETVAL

moment_t
minus_seconds(self, value)
    const moment_t *self
    I64V value
  PREINIT:
    dSTASH_INVOCANT;
  ALIAS:
    Time::Moment::minus_years        =  MOMENT_UNIT_YEARS
    Time::Moment::minus_months       =  MOMENT_UNIT_MONTHS
    Time::Moment::minus_weeks        =  MOMENT_UNIT_WEEKS
    Time::Moment::minus_days         =  MOMENT_UNIT_DAYS
    Time::Moment::minus_hours        =  MOMENT_UNIT_HOURS
    Time::Moment::minus_minutes      =  MOMENT_UNIT_MINUTES
    Time::Moment::minus_seconds      =  MOMENT_UNIT_SECONDS
    Time::Moment::minus_milliseconds =  MOMENT_UNIT_MILLISECONDS
    Time::Moment::minus_microseconds =  MOMENT_UNIT_MICROSECONDS
    Time::Moment::minus_nanoseconds  =  MOMENT_UNIT_NANOSECONDS
  CODE:
    if (value == 0)
        XSRETURN(1);
    RETVAL = moment_minus_unit(self, (moment_unit_t)ix, value);
    if (sv_reusable(ST(0))) {
        sv_set_moment(ST(0), &RETVAL);
        XSRETURN(1);
    }
  OUTPUT:
    RETVAL

moment_t
with_year(self, value)
    const moment_t *self
    IV value
  PREINIT:
    dSTASH_INVOCANT;
  ALIAS:
    Time::Moment::with_year           =  MOMENT_COMPONENT_YEAR
    Time::Moment::with_month          =  MOMENT_COMPONENT_MONTH
    Time::Moment::with_day_of_year    =  MOMENT_COMPONENT_DAY_OF_YEAR
    Time::Moment::with_day_of_quarter =  MOMENT_COMPONENT_DAY_OF_QUARTER
    Time::Moment::with_day_of_month   =  MOMENT_COMPONENT_DAY_OF_MONTH
    Time::Moment::with_hour           =  MOMENT_COMPONENT_HOUR
    Time::Moment::with_minute         =  MOMENT_COMPONENT_MINUTE
    Time::Moment::with_second         =  MOMENT_COMPONENT_SECOND
    Time::Moment::with_millisecond    =  MOMENT_COMPONENT_MILLISECOND
    Time::Moment::with_microsecond    =  MOMENT_COMPONENT_MICROSECOND
    Time::Moment::with_nanosecond     =  MOMENT_COMPONENT_NANOSECOND
  CODE:
    RETVAL = moment_with_component(self, (moment_component_t)ix, value);
    if (moment_compare_local(self, &RETVAL) == 0)
        XSRETURN(1);
    if (sv_reusable(ST(0))) {
        sv_set_moment(ST(0), &RETVAL);
        XSRETURN(1);
    }
  OUTPUT:
    RETVAL

moment_t
with_offset_same_instant(self, offset)
    const moment_t *self
    IV offset
  PREINIT:
    dSTASH_INVOCANT;
  ALIAS:
    Time::Moment::with_offset_same_instant = 0
    Time::Moment::with_offset_same_local   = 1
  CODE:
    if (ix == 0) {
        RETVAL = moment_with_offset_same_instant(self, offset);
        if (moment_compare_local(self, &RETVAL) == 0)
            XSRETURN(1);
    }
    else {
        RETVAL = moment_with_offset_same_local(self, offset);
        if (moment_compare(self, &RETVAL) == 0)
            XSRETURN(1);
    }
    if (sv_reusable(ST(0))) {
        sv_set_moment(ST(0), &RETVAL);
        XSRETURN(1);
    }
  OUTPUT:
    RETVAL

void
year(self)
    const moment_t *self
  ALIAS:
    Time::Moment::year           =  0
    Time::Moment::quarter        =  1
    Time::Moment::month          =  2
    Time::Moment::week           =  3
    Time::Moment::day_of_year    =  4
    Time::Moment::day_of_quarter =  5
    Time::Moment::day_of_month   =  6
    Time::Moment::day_of_week    =  7
    Time::Moment::hour           =  8
    Time::Moment::minute         =  9
    Time::Moment::second         = 10
    Time::Moment::millisecond    = 11
    Time::Moment::microsecond    = 12
    Time::Moment::nanosecond     = 13
    Time::Moment::offset         = 14
  PREINIT:
    IV v = 0;
  PPCODE:
    switch (ix) {
        case  0: v = moment_year(self);             break;
        case  1: v = moment_quarter(self);          break;
        case  2: v = moment_month(self);            break;
        case  3: v = moment_week(self);             break;
        case  4: v = moment_day_of_year(self);      break;
        case  5: v = moment_day_of_quarter(self);   break;
        case  6: v = moment_day_of_month(self);     break;
        case  7: v = moment_day_of_week(self);      break;
        case  8: v = moment_hour(self);             break;
        case  9: v = moment_minute(self);           break;
        case 10: v = moment_second(self);           break;
        case 11: v = moment_millisecond(self);      break;
        case 12: v = moment_microsecond(self);      break;
        case 13: v = moment_nanosecond(self);       break;
        case 14: v = moment_offset(self);           break;
    }
    XSRETURN_IV(v);

void
jd(self)
    const moment_t *self
  ALIAS:
    Time::Moment::jd  = 0
    Time::Moment::mjd = 1
  PREINIT:
    NV v = 0;
  PPCODE:
    switch (ix) {
        case 0: v = moment_jd(self);    break;
        case 1: v = moment_mjd(self);   break;
    }
    XSRETURN_NV(v);

void
length_of_year(self)
    const moment_t *self
  ALIAS:
    Time::Moment::length_of_year    =  0
    Time::Moment::length_of_quarter =  1
    Time::Moment::length_of_month   =  2
  PREINIT:
    IV v = 0;
  PPCODE:
    switch (ix) {
        case 0: v = moment_length_of_year(self);    break;
        case 1: v = moment_length_of_quarter(self); break;
        case 2: v = moment_length_of_month(self);   break;
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
    SV *ret;
  PPCODE:
    str = SvPV_const(format, len);
    ret = moment_strftime(self, str, len);
    if (SvUTF8(format))
        SvUTF8_on(ret);
    XSRETURN_SV(ret);

void
to_string(self, ...)
    const moment_t *self
  PREINIT:
    bool reduced;
    STRLEN len;
    const char *str;
    I32 i;
  PPCODE:
    if (((items - 1) % 2) != 0)
        croak("Odd number of elements in named parameters");

    reduced = FALSE;
    for (i = 1; i < items; i += 2) {
        str = SvPV_const(ST(i), len);
        switch (moment_param(str, len)) {
            case MOMENT_PARAM_REDUCED:
                reduced = cBOOL(SvTRUE((ST(i+1))));
                break;
            default: 
                croak("Unrecognised parameter: '%s'", str);
        }
    }
    XSRETURN_SV(moment_to_string(self, reduced));

