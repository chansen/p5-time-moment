#include "moment.h"
#include "dt_core.h"
#include "dt_accessor.h"

int64_t
moment_utc_ticks(const moment_t *mt) {
    return (mt->ticks - mt->offset * TICKS_PER_MIN);
}

IV
moment_utc_rd(const moment_t *mt) {
    return (moment_utc_ticks(mt) / TICKS_PER_DAY);
}

int64_t
moment_utc_rd_seconds(const moment_t *mt) {
    return (moment_utc_ticks(mt) / TICKS_PER_SEC);
}

void
moment_to_utc_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos) {
    const int64_t ticks = moment_utc_ticks(mt);
    const int64_t tod   = ticks % TICKS_PER_DAY;
    
    *rdn = ticks / TICKS_PER_DAY;
    *sod = tod / TICKS_PER_SEC;
    *nos = (tod % TICKS_PER_SEC) * 1000;
}

int64_t
moment_local_ticks(const moment_t *mt) {
    return mt->ticks;
}

IV
moment_local_rd(const moment_t *mt) {
    return (moment_local_ticks(mt) / TICKS_PER_DAY);
}

int64_t
moment_local_rd_seconds(const moment_t *mt) {
    return (moment_local_ticks(mt) / TICKS_PER_SEC);
}

dt_t
moment_local_dt(const moment_t *mt) {
    return (dt_t)moment_local_rd(mt);
}

void
moment_to_local_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos) {
    const int64_t ticks = moment_local_ticks(mt);
    const int64_t tod   = ticks % TICKS_PER_DAY;
    
    *rdn = ticks / TICKS_PER_DAY;
    *sod = tod / TICKS_PER_SEC;
    *nos = (tod % TICKS_PER_SEC) * 1000;
}

moment_t
THX_moment_from_epoch(pTHX_ int64_t sec, IV usec, IV offset) {
    moment_t r;

    if (!VALID_EPOCH_SEC(sec))
        croak("Parameter 'seconds' out of supported range");

    if (usec < 0 || usec > 999999)
        croak("Parameter 'microsecond' is out of the range [0, 999999]");

    if (!VALID_OFFSET(offset))
        croak("Parameter 'offset' out of the range [-1080, 1080]");

    r.ticks = (sec + UNIX_EPOCH + offset * 60) * TICKS_PER_SEC + usec * TICKS_PER_USEC;
    r.offset = offset;
    return r;
}

moment_t
THX_moment_with_offset(pTHX_ const moment_t *mt, IV offset) {
    moment_t r;

    if (!VALID_OFFSET(offset))
        croak("Parameter 'offset' out of the range [-1080, 1080]");

    r.ticks  = moment_utc_ticks(mt) + offset * TICKS_PER_MIN;
    r.offset = offset;
    return r;
}

IV
moment_compare(const moment_t *m1, const moment_t *m2) {
    const int64_t t1 = moment_utc_ticks(m1);
    const int64_t t2 = moment_utc_ticks(m2);
    if (t1 > t2) return  1;
    if (t1 < t2) return -1;
    return 0;
}

int64_t
moment_epoch(const moment_t *mt) {
    return (moment_utc_rd_seconds(mt) - UNIX_EPOCH);
}

int
moment_year(const moment_t *mt) {
    return dt_year(moment_local_rd(mt));
}

int
moment_month(const moment_t *mt) {
    return dt_month(moment_local_rd(mt));
}

int
moment_quarter(const moment_t *mt) {
    return dt_quarter(moment_local_rd(mt));
}

int
moment_day_of_year(const moment_t *mt) {
    return dt_doy(moment_local_rd(mt));
}

int
moment_day_of_quarter(const moment_t *mt) {
    return dt_doq(moment_local_rd(mt));
}

int
moment_day_of_month(const moment_t *mt) {
    return dt_dom(moment_local_rd(mt));
}

int
moment_day_of_week(const moment_t *mt) {
    return dt_dow(moment_local_rd(mt));
}

int
moment_hour(const moment_t *mt) {
    return (moment_local_ticks(mt) / TICKS_PER_HOUR) % 24;
}

int
moment_minute(const moment_t *mt) {
    return (moment_local_ticks(mt) / TICKS_PER_MIN) % 60;
}

int
moment_second(const moment_t *mt) {
    return (moment_local_ticks(mt) / TICKS_PER_SEC) % 60;
}

int
moment_millisecond(const moment_t *mt) {
    return (moment_local_ticks(mt) / TICKS_PER_MSEC) % 1000;
}

int
moment_microsecond(const moment_t *mt) {
    return (moment_local_ticks(mt) / TICKS_PER_USEC) % 1000000;
}

int
moment_offset(const moment_t *mt) {
    return mt->offset;
}

