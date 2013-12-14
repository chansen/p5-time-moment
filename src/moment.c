#include "moment.h"
#include "dt_core.h"
#include "dt_accessor.h"
#include "dt_arithmetic.h"

int64_t
moment_utc_rd_seconds(const moment_t *mt) {
    return (mt->sec - mt->offset * SECS_PER_MIN);
}

IV
moment_utc_rd(const moment_t *mt) {
    return (moment_utc_rd_seconds(mt) / SECS_PER_DAY);
}

void
moment_to_utc_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos) {
    const int64_t sec = moment_utc_rd_seconds(mt);
    *rdn = sec / SECS_PER_DAY;
    *sod = sec % SECS_PER_DAY;
    *nos = mt->nsec;
}

int64_t
moment_local_rd_seconds(const moment_t *mt) {
    return mt->sec;
}

IV
moment_local_rd(const moment_t *mt) {
    return (moment_local_rd_seconds(mt) / SECS_PER_DAY);
}

dt_t
moment_local_dt(const moment_t *mt) {
    return dt_from_rdn((int)moment_local_rd(mt));
}

void
moment_to_local_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos) {
    const int64_t sec = moment_local_rd_seconds(mt);
    *rdn = sec / SECS_PER_DAY;
    *sod = sec % SECS_PER_DAY;
    *nos = mt->nsec;
}

static void
THX_check_seconds(pTHX_ int64_t v) {
    if (!VALID_EPOCH_SEC(v))
        croak("Parameter 'seconds' is out of supported range");
}

static void
THX_check_offset(pTHX_ IV v) {
    if (v < -1080 || v > 1080)
        croak("Parameter 'offset' is out of the range [-1080, 1080]");
}

static void
THX_check_nanosecond(pTHX_ IV v) {
    if (v < 0 || v > 999999999)
        croak("Parameter 'nanosecond' is out of the range [0, 999_999_999]");
}

static void
THX_moment_check_range(pTHX_ int64_t v) {
    if (v < MIN_RANGE || v > MAX_RANGE)
        croak("Time::Moment is out of supported time range");
}

static void
THX_check_unit_years(pTHX_ int64_t v) {
    if (v < MIN_UNIT_YEARS || v > MAX_UNIT_YEARS)
        croak("Parameter 'years' is out of supported range");
}

static void
THX_check_unit_months(pTHX_ int64_t v) {
    if (v < MIN_UNIT_MONTHS || v > MAX_UNIT_MONTHS)
        croak("Parameter 'months' is out of supported range");
}

static void
THX_check_unit_weeks(pTHX_ int64_t v) {
    if (v < MIN_UNIT_WEEKS || v > MAX_UNIT_WEEKS)
        croak("Parameter 'weeks' is out of supported range");
}

static void
THX_check_unit_days(pTHX_ int64_t v) {
    if (v < MIN_UNIT_DAYS || v > MAX_UNIT_DAYS)
        croak("Parameter 'days' is out of supported range");
}

static void
THX_check_unit_hours(pTHX_ int64_t v) {
    if (v < MIN_UNIT_HOURS || v > MAX_UNIT_HOURS)
        croak("Parameter 'hours' is out of supported range");
}

static void
THX_check_unit_minutes(pTHX_ int64_t v) {
    if (v < MIN_UNIT_MINUTES || v > MAX_UNIT_MINUTES)
        croak("Parameter 'minutes' is out of supported range");
}

static void
THX_check_unit_seconds(pTHX_ int64_t v) {
    if (v < MIN_UNIT_SECONDS || v > MAX_UNIT_SECONDS)
        croak("Parameter 'seconds' is out of supported range");
}

moment_t
THX_moment_from_epoch(pTHX_ int64_t sec, IV nsec, IV offset) {
    moment_t r;

    THX_check_seconds(aTHX_ sec);
    THX_check_nanosecond(aTHX_ nsec);
    THX_check_offset(aTHX_ offset);
    r.sec    = sec + UNIX_EPOCH + offset * 60;
    r.nsec   = nsec;
    r.offset = offset;
    return r;
}

moment_t
THX_moment_with_offset(pTHX_ const moment_t *mt, IV offset) {
    moment_t r;

    THX_check_offset(aTHX_ offset);
    r.sec    = moment_utc_rd_seconds(mt) + offset * SECS_PER_MIN;
    r.nsec   = mt->nsec;
    r.offset = offset;
    return r;
}

moment_t
THX_moment_with_nanosecond(pTHX_ const moment_t *mt, IV nsec) {
    moment_t r;

    THX_check_nanosecond(aTHX_ nsec);
    r.sec    = mt->sec;
    r.nsec   = nsec;
    r.offset = mt->offset;
    return r;
}

static moment_t
THX_moment_plus_months(pTHX_ const moment_t *mt, int64_t v) {
    int64_t sod, rdn;
    moment_t r;
    
    THX_check_unit_months(aTHX_ v);
    sod = moment_local_rd_seconds(mt) % SECS_PER_DAY;
    rdn = dt_rdn(dt_add_months(moment_local_dt(mt), (int)v, DT_LIMIT));
    r.sec    = sod + rdn * SECS_PER_DAY;
    r.nsec   = mt->nsec;
    r.offset = mt->offset;
    THX_moment_check_range(aTHX_ r.sec);
    return r;
}

static moment_t
THX_moment_plus_seconds(pTHX_ const moment_t *mt, int64_t v) {
    moment_t r;

    THX_check_unit_seconds(aTHX_ v);
    r.sec    = mt->sec + v;
    r.nsec   = mt->nsec;
    r.offset = mt->offset;
    THX_moment_check_range(aTHX_ r.sec);
    return r;
}

moment_t
THX_moment_plus_unit(pTHX_ const moment_t *mt, moment_unit_t u, int64_t v) {
    switch (u) {
        case MOMENT_UNIT_YEARS:
            THX_check_unit_years(aTHX_ v);
            return THX_moment_plus_months(aTHX_ mt, v * 12);
        case MOMENT_UNIT_MONTHS:
            THX_check_unit_months(aTHX_ v);
            return THX_moment_plus_months(aTHX_ mt, v);
        case MOMENT_UNIT_WEEKS:
            THX_check_unit_weeks(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, v * 604800);
        case MOMENT_UNIT_DAYS:
            THX_check_unit_days(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, v * 86400);
        case MOMENT_UNIT_HOURS:
            THX_check_unit_hours(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, v * 3600);
        case MOMENT_UNIT_MINUTES:
            THX_check_unit_minutes(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, v * 60);
        case MOMENT_UNIT_SECONDS:
            THX_check_unit_seconds(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, v);
    }
    croak("panic: unknown unit THX_moment_plus_unit(%d)", (int)u);
}

moment_t
THX_moment_minus_unit(pTHX_ const moment_t *mt, moment_unit_t u, int64_t v) {
    switch (u) {
        case MOMENT_UNIT_YEARS:
            THX_check_unit_years(aTHX_ v);
            return THX_moment_plus_months(aTHX_ mt, -v * 12);
        case MOMENT_UNIT_MONTHS:
            THX_check_unit_months(aTHX_ v);
            return THX_moment_plus_months(aTHX_ mt, -v);
        case MOMENT_UNIT_WEEKS:
            THX_check_unit_weeks(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, -v * 604800);
        case MOMENT_UNIT_DAYS:
            THX_check_unit_days(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, -v * 86400);
        case MOMENT_UNIT_HOURS:
            THX_check_unit_hours(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, -v * 3600);
        case MOMENT_UNIT_MINUTES:
            THX_check_unit_minutes(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, -v * 60);
        case MOMENT_UNIT_SECONDS:
            THX_check_unit_seconds(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, -v);
    }
    croak("panic: unknown unit THX_moment_minus_unit(%d)", (int)u);
}

IV
moment_compare(const moment_t *m1, const moment_t *m2) {
    const int64_t s1 = moment_utc_rd_seconds(m1);
    const int64_t s2 = moment_utc_rd_seconds(m2);
    if (s1 < s2)
        return -1;
    if (s1 > s2)
        return 1;
    if (m1->nsec < m2->nsec)
        return -1;
    if (m1->nsec > m2->nsec)
        return 1;
    return 0;
}

int64_t
moment_epoch(const moment_t *mt) {
    return (moment_utc_rd_seconds(mt) - UNIX_EPOCH);
}

int
moment_year(const moment_t *mt) {
    return dt_year(moment_local_dt(mt));
}

int
moment_month(const moment_t *mt) {
    return dt_month(moment_local_dt(mt));
}

int
moment_quarter(const moment_t *mt) {
    return dt_quarter(moment_local_dt(mt));
}

int
moment_week(const moment_t *mt) {
    return dt_woy(moment_local_dt(mt));
}

int
moment_day_of_year(const moment_t *mt) {
    return dt_doy(moment_local_dt(mt));
}

int
moment_day_of_quarter(const moment_t *mt) {
    return dt_doq(moment_local_dt(mt));
}

int
moment_day_of_month(const moment_t *mt) {
    return dt_dom(moment_local_dt(mt));
}

int
moment_day_of_week(const moment_t *mt) {
    return dt_dow(moment_local_dt(mt));
}

int
moment_hour(const moment_t *mt) {
    return (moment_local_rd_seconds(mt) / SECS_PER_HOUR) % 24;
}

int
moment_minute(const moment_t *mt) {
    return (moment_local_rd_seconds(mt) / SECS_PER_MIN) % 60;
}

int
moment_second(const moment_t *mt) {
    return (moment_local_rd_seconds(mt)) % 60;
}

int
moment_millisecond(const moment_t *mt) {
    return (mt->nsec / 1000000);
}

int
moment_microsecond(const moment_t *mt) {
    return (mt->nsec / 1000);
}

int
moment_nanosecond(const moment_t *mt) {
    return mt->nsec;
}

int
moment_offset(const moment_t *mt) {
    return mt->offset;
}

