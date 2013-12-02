#include "moment.h"
#include "dt_core.h"
#include "dt_accessor.h"

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

moment_t
THX_moment_from_epoch(pTHX_ int64_t sec, IV nsec, IV offset) {
    moment_t r;

    if (!VALID_EPOCH_SEC(sec))
        croak("Parameter 'seconds' is out of supported range");

    if (nsec < 0 || nsec > 999999999)
        croak("Parameter 'nanosecond' is out of the range [0, 999_999_999]");

    if (!VALID_OFFSET(offset))
        croak("Parameter 'offset' is out of the range [-1080, 1080]");

    r.sec    = sec + UNIX_EPOCH + offset * 60;
    r.nsec   = nsec;
    r.offset = offset;
    return r;
}

moment_t
THX_moment_with_offset(pTHX_ const moment_t *mt, IV offset) {
    moment_t r;

    if (!VALID_OFFSET(offset))
        croak("Parameter 'offset' is out of the range [-1080, 1080]");

    r.sec    = moment_utc_rd_seconds(mt) + offset * SECS_PER_MIN;
    r.nsec   = mt->nsec;
    r.offset = offset;
    return r;
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

