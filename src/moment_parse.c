#include "moment.h"
#include "dt_core.h"
#include "dt_parse_iso.h"

static int
parse_string_lenient(const char *str, size_t len, int64_t *sp, IV *np, IV *op) {
    size_t n;
    dt_t dt;
    char c;
    int sod, nanosecond, offset;

    n = dt_parse_iso_date(str, len, &dt);
    if (!n || n == len)
        return 1;

    c = str[n++];
    if (!(c == 'T' || c == 't' || c == ' '))
        return 1;

    str += n;
    len -= n;

    n = dt_parse_iso_time(str, len, &sod, &nanosecond);
    if (!n || n == len)
        return 1;

    if (str[n] == ' ')
        n++;

    str += n;
    len -= n;

    n = dt_parse_iso_zone_lenient(str, len, &offset);
    if (!n || n != len)
        return 1;

    *sp = ((int64_t)dt_rdn(dt) - 719163) * 86400 + sod - offset * 60;
    *np = nanosecond;
    *op = offset;
    return 0;
}

static int
parse_string_strict(const char *str, size_t len, int64_t *sp, IV *np, IV *op) {
    size_t n;
    dt_t dt;
    int sod, nanosecond, offset;
    bool extended;

    n = dt_parse_iso_date(str, len, &dt);
    if (!n || n == len)
        return 1;

   /*
    * 0123456789
    * 2012-12-14
    */
    extended = str[4] == '-';
    if (str[n++] != 'T')
        return 1;

    str += n;
    len -= n;

    if (extended)
        n = dt_parse_iso_time_extended(str, len, &sod, &nanosecond);
    else
        n = dt_parse_iso_time_basic(str, len, &sod, &nanosecond);

    if (!n || n == len)
        return 1;

    str += n;
    len -= n;

    if (extended)
        n = dt_parse_iso_zone_extended(str, len, &offset);
    else
        n = dt_parse_iso_zone_basic(str, len, &offset);

    if (!n || n != len)
        return 1;

    *sp = ((int64_t)dt_rdn(dt) - 719163) * 86400 + sod - offset * 60;
    *np = nanosecond;
    *op = offset;
    return 0;
}

moment_t
THX_moment_from_string(pTHX_ const char *str, STRLEN len, bool lenient) {
    int ret;
    int64_t seconds;
    IV nanosecond, offset;

    if (lenient)
        ret = parse_string_lenient(str, len, &seconds, &nanosecond, &offset);
    else
        ret = parse_string_strict(str, len, &seconds, &nanosecond, &offset);

    if (ret != 0)
        croak("Could not parse the given string");

    return moment_from_epoch(seconds, nanosecond, offset);
}

