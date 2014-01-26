#include "moment.h"
#include "dt_core.h"
#include "dt_parse_iso.h"

static int
parse_string(const char *str, size_t len, bool lenient, int64_t *sp, IV *fp, IV *op) {
    size_t n;
    dt_t dt;
    int td, sod, frac, off;
    bool extended;

    n = dt_parse_iso_date(str, len, &dt);
    if (!n || n == len)
        return 1;

    /* 
     * 0123456789
     * 2012-12-14 
     */
    extended = str[4] == '-';
    if (lenient) /* only calendar date and time of day in extended format */
        lenient = (extended && str[7] == '-');
    switch (td = str[n++]) {
        case 'T':
            break;
        case 't':
        case ' ':
            if (lenient)
                break;
            /* FALLTROUGH */
        default:
            return 1;
    }

    str += n;
    len -= n;

    if (extended)
        n = dt_parse_iso_time_extended(str, len, &sod, &frac);
    else
        n = dt_parse_iso_time_basic(str, len, &sod, &frac);

    if (!n || n == len)
        return 1;

    if (lenient && td == ' ' && str[n] == ' ')
        n++;

    str += n;
    len -= n;

    if (extended) {
        if (lenient)
            n = dt_parse_iso_zone_lenient(str, len, &off);
        else 
            n = dt_parse_iso_zone_extended(str, len, &off);
    }
    else {
        n = dt_parse_iso_zone_basic(str, len, &off);
    }

    if (!n || n != len)
        return 1;

    *sp = ((int64_t)dt_rdn(dt) - 719163) * 86400 + sod - off * 60;
    *fp = frac;
    *op = off;
    return 0;
}

moment_t
THX_moment_from_string(pTHX_ const char *str, STRLEN len, bool lenient) {
    int64_t sec;
    IV frac, offset;

    if (parse_string(str, len, lenient, &sec, &frac, &offset))
        croak("Cannot parse the given string");

    return moment_from_epoch(sec, frac, offset);
}

