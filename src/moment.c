#include "moment.h"
#include "dt_core.h"
#include "dt_accessor.h"
#include "dt_arithmetic.h"
#include "dt_util.h"
#include "dt_length.h"

int64_t
moment_utc_rd_seconds(const moment_t *mt) {
    return (mt->sec - mt->offset * SECS_PER_MIN);
}

int
moment_utc_rd(const moment_t *mt) {
    return (int)(moment_utc_rd_seconds(mt) / SECS_PER_DAY);
}

void
moment_to_utc_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos) {
    const int64_t sec = moment_utc_rd_seconds(mt);
    *rdn = (IV)(sec / SECS_PER_DAY);
    *sod = (IV)(sec % SECS_PER_DAY);
    *nos = mt->nsec;
}

int64_t
moment_local_rd_seconds(const moment_t *mt) {
    return mt->sec;
}

int
moment_local_rd(const moment_t *mt) {
    return (int)(moment_local_rd_seconds(mt) / SECS_PER_DAY);
}

dt_t
moment_local_dt(const moment_t *mt) {
    return dt_from_rdn(moment_local_rd(mt));
}

void
moment_to_local_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos) {
    const int64_t sec = moment_local_rd_seconds(mt);
    *rdn = (IV)(sec / SECS_PER_DAY);
    *sod = (IV)(sec % SECS_PER_DAY);
    *nos = mt->nsec;
}

static void
THX_check_year(pTHX_ IV v) {
    if (v < 1 || v > 9999)
        croak("Parameter 'year' is out of the range [1, 9999]");
}

static void
THX_check_month(pTHX_ IV v) {
    if (v < 1 || v > 12)
        croak("Parameter 'month' is out of the range [1, 12]");
}

static void
THX_check_hour(pTHX_ IV v) {
    if (v < 0 || v > 23)
        croak("Parameter 'hour' is out of the range [1, 23]");
}

static void
THX_check_minute(pTHX_ IV v) {
    if (v < 0 || v > 59)
        croak("Parameter 'minute' is out of the range [1, 59]");
}

static void
THX_check_second(pTHX_ IV v) {
    if (v < 0 || v > 59)
        croak("Parameter 'second' is out of the range [1, 59]");
}

static void
THX_check_second_of_day(pTHX_ IV v) {
    if (v < 0 || v > 86399)
        croak("Parameter 'second' is out of the range [0, 86399]");
}

static void
THX_check_millisecond(pTHX_ IV v) {
    if (v < 0 || v > 999)
        croak("Parameter 'millisecond' is out of the range [0, 999]");
}

static void
THX_check_microsecond(pTHX_ IV v) {
    if (v < 0 || v > 999999)
        croak("Parameter 'microsecond' is out of the range [0, 999_999]");
}

static void
THX_check_nanosecond(pTHX_ IV v) {
    if (v < 0 || v > 999999999)
        croak("Parameter 'nanosecond' is out of the range [0, 999_999_999]");
}

static void
THX_check_offset(pTHX_ IV v) {
    if (v < -1080 || v > 1080)
        croak("Parameter 'offset' is out of the range [-1080, 1080]");
}

static void
THX_check_seconds(pTHX_ int64_t v) {
    if (!VALID_EPOCH_SEC(v))
        croak("Parameter 'seconds' is out of range");
}

static void
THX_moment_check_self(pTHX_ const moment_t *mt) {
    if (mt->sec < MIN_RANGE || mt->sec > MAX_RANGE)
        croak("Time::Moment is out of range");
}

static void
THX_check_unit_years(pTHX_ int64_t v) {
    if (v < MIN_UNIT_YEARS || v > MAX_UNIT_YEARS)
        croak("Parameter 'years' is out of range");
}

static void
THX_check_unit_months(pTHX_ int64_t v) {
    if (v < MIN_UNIT_MONTHS || v > MAX_UNIT_MONTHS)
        croak("Parameter 'months' is out of range");
}

static void
THX_check_unit_weeks(pTHX_ int64_t v) {
    if (v < MIN_UNIT_WEEKS || v > MAX_UNIT_WEEKS)
        croak("Parameter 'weeks' is out of range");
}

static void
THX_check_unit_days(pTHX_ int64_t v) {
    if (v < MIN_UNIT_DAYS || v > MAX_UNIT_DAYS)
        croak("Parameter 'days' is out of range");
}

static void
THX_check_unit_hours(pTHX_ int64_t v) {
    if (v < MIN_UNIT_HOURS || v > MAX_UNIT_HOURS)
        croak("Parameter 'hours' is out of range");
}

static void
THX_check_unit_minutes(pTHX_ int64_t v) {
    if (v < MIN_UNIT_MINUTES || v > MAX_UNIT_MINUTES)
        croak("Parameter 'minutes' is out of range");
}

static void
THX_check_unit_seconds(pTHX_ int64_t v) {
    if (v < MIN_UNIT_SECONDS || v > MAX_UNIT_SECONDS)
        croak("Parameter 'seconds' is out of range");
}

static void
THX_check_unit_milliseconds(pTHX_ int64_t v) {
    if (v < MIN_UNIT_MILLISECONDS || v > MAX_UNIT_MILLISECONDS)
        croak("Parameter 'milliseconds' is out of range");
}

static void
THX_check_unit_microseconds(pTHX_ int64_t v) {
    if (v < MIN_UNIT_MICROSECONDS || v > MAX_UNIT_MICROSECONDS)
        croak("Parameter 'microseconds' is out of range");
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
THX_moment_new(pTHX_ IV Y, IV M, IV D, IV h, IV m, IV s, IV ns, IV offset) {
    moment_t r;
    int64_t rdn, sod;

    THX_check_year(aTHX_ Y);
    THX_check_month(aTHX_ M);
    if (D < 1 || D > 28) {
        int dim = dt_days_in_month(Y, M);
        if (D < 1 || D > dim)
            croak("Parameter 'day' is out of the range [1, %d]", dim);
    }
    THX_check_hour(aTHX_ h);
    THX_check_minute(aTHX_ m);
    THX_check_second(aTHX_ s);
    THX_check_nanosecond(aTHX_ ns);
    THX_check_offset(aTHX_ offset);

    rdn = dt_rdn(dt_from_ymd(Y, M, D));
    sod = h * 3600 + m * 60 + s;
    r.sec    = rdn * SECS_PER_DAY + sod;
    r.nsec   = ns;
    r.offset = offset;
    return r;
}

static moment_t
THX_moment_with_local_dt(pTHX_ const moment_t *mt, const dt_t dt) {
    moment_t r;
    int64_t sod, rdn;

    sod = moment_local_rd_seconds(mt) % SECS_PER_DAY;
    rdn = dt_rdn(dt);
    r.sec    = sod + rdn * SECS_PER_DAY;
    r.nsec   = mt->nsec;
    r.offset = mt->offset;
    THX_moment_check_self(aTHX_ &r);
    return r;
}

static moment_t
THX_moment_with_year(pTHX_ const moment_t *mt, IV v) {
    int y, m, d;

    THX_check_year(aTHX_ v);
    dt_to_ymd(moment_local_dt(mt), NULL, &m, &d);
    y = (int)v;
    if (d > 28) {
        int dim = dt_days_in_month(y, m);
        if (d > dim)
            d = dim;
    }
    return THX_moment_with_local_dt(aTHX_ mt, dt_from_ymd(y, m, d));
}

static moment_t
THX_moment_with_month(pTHX_ const moment_t *mt, IV v) {
    int y, m, d;

    THX_check_month(aTHX_ v);
    dt_to_ymd(moment_local_dt(mt), &y, NULL, &d);
    m = (int)v;
    if (d > 28) {
        int dim = dt_days_in_month(y, m);
        if (d > dim)
            d = dim;
    }
    return THX_moment_with_local_dt(aTHX_ mt, dt_from_ymd(y, m, d));
}

static moment_t
THX_moment_with_week(pTHX_ const moment_t *mt, IV v) {
    int y, d;

    dt_to_ywd(moment_local_dt(mt), &y, NULL, &d);
    if (v < 1 || v > 52) {
        int wiy = dt_weeks_in_year(y);
        if (v < 1 || v > wiy)
            croak("Parameter 'week' is out of the range [1, %d]", wiy);
    }
    return THX_moment_with_local_dt(aTHX_ mt, dt_from_ywd(y, (int)v, d));
}

static moment_t
THX_moment_with_day_of_month(pTHX_ const moment_t *mt, IV v) {
    int y, m;

    dt_to_ymd(moment_local_dt(mt), &y, &m, NULL);
    if (v < 1 || v > 28) {
        int dim = dt_days_in_month(y, m);
        if (v < 1 || v > dim)
            croak("Parameter 'day' is out of the range [1, %d]", dim);
    }
    return THX_moment_with_local_dt(aTHX_ mt, dt_from_ymd(y, m, (int)v));
}

static moment_t
THX_moment_with_day_of_quarter(pTHX_ const moment_t *mt, IV v) {
    int y, q;

    dt_to_yqd(moment_local_dt(mt), &y, &q, NULL);
    if (v < 1 || v > 90) {
        int diq = dt_days_in_quarter(y, q);
        if (v < 1 || v > diq)
            croak("Parameter 'day' is out of the range [1, %d]", diq);
    }
    return THX_moment_with_local_dt(aTHX_ mt, dt_from_yqd(y, q, (int)v));
}

static moment_t
THX_moment_with_day_of_year(pTHX_ const moment_t *mt, IV v) {
    int y;

    dt_to_yd(moment_local_dt(mt), &y, NULL);
    if (v < 1 || v > 365) {
        int diy = dt_days_in_year(y);
        if (v < 1 || v > diy)
            croak("Parameter 'day' is out of the range [1, %d]", diy);
    }
    return THX_moment_with_local_dt(aTHX_ mt, dt_from_yd(y, (int)v));
}

static moment_t
THX_moment_with_day_of_week(pTHX_ const moment_t *mt, IV v) {
    dt_t dt;

    if (v < 1 || v > 7)
        croak("Parameter 'day' is out of the range [1, 7]");

    dt = moment_local_dt(mt);
    return THX_moment_with_local_dt(aTHX_ mt, dt - (dt_dow(dt) - v));
}

moment_t
THX_moment_with_hour(pTHX_ const moment_t *mt, IV v) {
    moment_t r;

    THX_check_hour(aTHX_ v);
    r.sec    = mt->sec + (v - moment_hour(mt)) * SECS_PER_HOUR;
    r.nsec   = mt->nsec;
    r.offset = mt->offset;
    return r;
}

moment_t
THX_moment_with_minute(pTHX_ const moment_t *mt, IV v) {
    moment_t r;

    THX_check_minute(aTHX_ v);
    r.sec    = mt->sec + (v - moment_minute(mt)) * SECS_PER_MIN;
    r.nsec   = mt->nsec;
    r.offset = mt->offset;
    return r;
}

moment_t
THX_moment_with_second(pTHX_ const moment_t *mt, IV v) {
    moment_t r;

    THX_check_second(aTHX_ v);
    r.sec    = mt->sec + (v - moment_second(mt));
    r.nsec   = mt->nsec;
    r.offset = mt->offset;
    return r;
}

moment_t
THX_moment_with_second_of_day(pTHX_ const moment_t *mt, IV v) {
    moment_t r;

    THX_check_second_of_day(aTHX_ v);
    r.sec    = mt->sec + (v - moment_second_of_day(mt));
    r.nsec   = mt->nsec;
    r.offset = mt->offset;
    return r;
}

moment_t
THX_moment_with_millisecond(pTHX_ const moment_t *mt, IV msec) {
    moment_t r;

    THX_check_millisecond(aTHX_ msec);
    r.sec    = mt->sec;
    r.nsec   = msec * 1000000;
    r.offset = mt->offset;
    return r;
}

moment_t
THX_moment_with_microsecond(pTHX_ const moment_t *mt, IV usec) {
    moment_t r;

    THX_check_microsecond(aTHX_ usec);
    r.sec    = mt->sec;
    r.nsec   = usec * 1000;
    r.offset = mt->offset;
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

moment_t
THX_moment_with_offset_same_instant(pTHX_ const moment_t *mt, IV offset) {
    moment_t r;

    THX_check_offset(aTHX_ offset);
    r.sec    = moment_utc_rd_seconds(mt) + offset * SECS_PER_MIN;
    r.nsec   = mt->nsec;
    r.offset = offset;
    return r;
}

moment_t
THX_moment_with_offset_same_local(pTHX_ const moment_t *mt, IV offset) {
    moment_t r;

    THX_check_offset(aTHX_ offset);
    r.sec    = mt->sec;
    r.nsec   = mt->nsec;
    r.offset = offset;
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
    THX_moment_check_self(aTHX_ &r);
    return r;
}

static moment_t
THX_moment_plus_seconds(pTHX_ const moment_t *mt, int64_t v) {
    moment_t r;

    THX_check_unit_seconds(aTHX_ v);
    r.sec    = mt->sec + v;
    r.nsec   = mt->nsec;
    r.offset = mt->offset;
    THX_moment_check_self(aTHX_ &r);
    return r;
}

moment_t
THX_moment_at_utc(pTHX_ const moment_t *mt) {
    return moment_with_offset_same_instant(aTHX_ mt, 0);
}

moment_t
THX_moment_at_midnight(pTHX_ const moment_t *mt) {
    moment_t r;

    r = THX_moment_with_second_of_day(aTHX_ mt, 0);
    r.nsec = 0;
    return r;
}

moment_t
THX_moment_at_noon(pTHX_ const moment_t *mt) {
    moment_t r;

    r = THX_moment_with_second_of_day(aTHX_ mt, 12*60*60);
    r.nsec = 0;
    return r;
}

moment_t
THX_moment_at_last_day_of_year(pTHX_ const moment_t *mt) {
    int y;

    dt_to_yd(moment_local_dt(mt), &y, NULL);
    return THX_moment_with_local_dt(aTHX_ mt, dt_from_yd(y + 1, 0));
}

moment_t
THX_moment_at_last_day_of_quarter(pTHX_ const moment_t *mt) {
    int y, q;

    dt_to_yqd(moment_local_dt(mt), &y, &q, NULL);
    return THX_moment_with_local_dt(aTHX_ mt, dt_from_yqd(y, q + 1, 0));
}

moment_t
THX_moment_at_last_day_of_month(pTHX_ const moment_t *mt) {
    int y, m;

    dt_to_ymd(moment_local_dt(mt), &y, &m, NULL);
    return THX_moment_with_local_dt(aTHX_ mt, dt_from_ymd(y, m + 1, 0));
}

static moment_t
THX_moment_plus_time(pTHX_ const moment_t *mt, int64_t sec, int64_t nsec, int sign) {
    moment_t r;

    sec  = sec + (nsec / SECS_PER_NANO);
    nsec = nsec % SECS_PER_NANO;

    sec  = mt->sec + sec * sign;
    nsec = mt->nsec + nsec * sign;

    if (nsec < 0) {
        nsec += SECS_PER_NANO;
        sec--;
    }
    else if (nsec >= SECS_PER_NANO) {
        nsec -= SECS_PER_NANO;
        sec++;
    }

    r.sec    = sec;
    r.nsec   = nsec;
    r.offset = mt->offset;
    THX_moment_check_self(aTHX_ &r);
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
            return THX_moment_plus_seconds(aTHX_ mt, v * SECS_PER_WEEK);
        case MOMENT_UNIT_DAYS:
            THX_check_unit_days(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, v * SECS_PER_DAY);
        case MOMENT_UNIT_HOURS:
            THX_check_unit_hours(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, v * SECS_PER_HOUR);
        case MOMENT_UNIT_MINUTES:
            THX_check_unit_minutes(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, v * SECS_PER_MIN);
        case MOMENT_UNIT_SECONDS:
            THX_check_unit_seconds(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, v);
        case MOMENT_UNIT_MILLISECONDS:
            THX_check_unit_milliseconds(aTHX_ v);
            return THX_moment_plus_time(aTHX_ mt, v / 1000, (v % 1000) * 1000000, 1);
        case MOMENT_UNIT_MICROSECONDS:
            THX_check_unit_microseconds(aTHX_ v);
            return THX_moment_plus_time(aTHX_ mt, v / 1000000, (v % 1000000) * 1000, 1);
        case MOMENT_UNIT_NANOSECONDS:
            return THX_moment_plus_time(aTHX_ mt, 0, v, 1);
    }
    croak("panic: THX_moment_plus_unit() called with unknown unit (%d)", (int)u);
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
            return THX_moment_plus_seconds(aTHX_ mt, -v * SECS_PER_WEEK);
        case MOMENT_UNIT_DAYS:
            THX_check_unit_days(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, -v * SECS_PER_DAY);
        case MOMENT_UNIT_HOURS:
            THX_check_unit_hours(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, -v * SECS_PER_HOUR);
        case MOMENT_UNIT_MINUTES:
            THX_check_unit_minutes(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, -v * SECS_PER_MIN);
        case MOMENT_UNIT_SECONDS:
            THX_check_unit_seconds(aTHX_ v);
            return THX_moment_plus_seconds(aTHX_ mt, -v);
        case MOMENT_UNIT_MILLISECONDS:
            THX_check_unit_milliseconds(aTHX_ v);
            return THX_moment_plus_time(aTHX_ mt, v / 1000, (v % 1000) * 1000000, -1);
        case MOMENT_UNIT_MICROSECONDS:
            THX_check_unit_microseconds(aTHX_ v);
            return THX_moment_plus_time(aTHX_ mt, v / 1000000, (v % 1000000) * 1000, -1);
        case MOMENT_UNIT_NANOSECONDS:
            return THX_moment_plus_time(aTHX_ mt, 0, v, -1);
    }
    croak("panic: THX_moment_minus_unit() called with unknown unit (%d)", (int)u);
}

moment_t
THX_moment_with_component(pTHX_ const moment_t *mt, moment_component_t c, IV v) {
    switch (c) {
        case MOMENT_COMPONENT_YEAR:
            return THX_moment_with_year(aTHX_ mt, v);
        case MOMENT_COMPONENT_MONTH:
            return THX_moment_with_month(aTHX_ mt, v);
        case MOMENT_COMPONENT_WEEK:
            return THX_moment_with_week(aTHX_ mt, v);
        case MOMENT_COMPONENT_DAY_OF_MONTH:
            return THX_moment_with_day_of_month(aTHX_ mt, v);
        case MOMENT_COMPONENT_DAY_OF_QUARTER:
            return THX_moment_with_day_of_quarter(aTHX_ mt, v);
        case MOMENT_COMPONENT_DAY_OF_YEAR:
            return THX_moment_with_day_of_year(aTHX_ mt, v);
        case MOMENT_COMPONENT_DAY_OF_WEEK:
            return THX_moment_with_day_of_week(aTHX_ mt, v);
        case MOMENT_COMPONENT_HOUR:
            return THX_moment_with_hour(aTHX_ mt, v);
        case MOMENT_COMPONENT_MINUTE:
            return THX_moment_with_minute(aTHX_ mt, v);
        case MOMENT_COMPONENT_SECOND:
            return THX_moment_with_second(aTHX_ mt, v);
        case MOMENT_COMPONENT_SECOND_OF_DAY:
            return THX_moment_with_second_of_day(aTHX_ mt, v);
        case MOMENT_COMPONENT_MILLISECOND:
            return THX_moment_with_millisecond(aTHX_ mt, v);
        case MOMENT_COMPONENT_MICROSECOND:
            return THX_moment_with_microsecond(aTHX_ mt, v);
        case MOMENT_COMPONENT_NANOSECOND:
            return THX_moment_with_nanosecond(aTHX_ mt, v);
    }
    croak("panic: THX_moment_with_component() called with unknown component (%d)", (int)c);
}

int
moment_compare_instant(const moment_t *m1, const moment_t *m2) {
    const int64_t s1 = moment_utc_rd_seconds(m1);
    const int64_t s2 = moment_utc_rd_seconds(m2);
    int r;

    r = (s1 > s2) - (s1 < s2);
    if (r == 0)
        r = (m1->nsec > m2->nsec) - (m1->nsec < m2->nsec);
    return r;
}

int
moment_compare_local(const moment_t *m1, const moment_t *m2) {
    const int64_t s1 = moment_local_rd_seconds(m1);
    const int64_t s2 = moment_local_rd_seconds(m2);
    int r;

    r = (s1 > s2) - (s1 < s2);
    if (r == 0)
        r = (m1->nsec > m2->nsec) - (m1->nsec < m2->nsec);
    return r;
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
    return (int)((moment_local_rd_seconds(mt) / SECS_PER_HOUR) % 24);
}

int
moment_minute(const moment_t *mt) {
    return (int)((moment_local_rd_seconds(mt) / SECS_PER_MIN) % 60);
}

int
moment_second(const moment_t *mt) {
    return (int)(moment_local_rd_seconds(mt) % 60);
}

int
moment_second_of_day(const moment_t *mt) {
    return (int)(moment_local_rd_seconds(mt) % SECS_PER_DAY);
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

NV
moment_jd(const moment_t *mt) {
    return moment_mjd(mt) + 2400000.5;
}

NV
moment_mjd(const moment_t *mt) {
    const int64_t s = moment_utc_rd_seconds(mt);
    const int64_t d = (s / SECS_PER_DAY) - 678576;
    const int64_t n = (s % SECS_PER_DAY) * SECS_PER_NANO + mt->nsec;
    return (NV)d + (NV)n * (1E-9/60/60/24);
}

int
moment_offset(const moment_t *mt) {
    return mt->offset;
}

int
moment_length_of_year(const moment_t *mt) {
    return dt_length_of_year(moment_local_dt(mt));
}

int
moment_length_of_quarter(const moment_t *mt) {
    return dt_length_of_quarter(moment_local_dt(mt));
}

int
moment_length_of_month(const moment_t *mt) {
    return dt_length_of_month(moment_local_dt(mt));
}

int
moment_length_of_week_year(const moment_t *mt) {
    return dt_length_of_week_year(moment_local_dt(mt));
}
