#include "moment.h"
#include "dt_core.h"
#include "dt_accessor.h"

typedef enum {
    PAD_DEFAULT,
    PAD_NONE,
    PAD_ZERO,
    PAD_SPACE,
} pad_t;

static const char *aDoW[] = {
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
};

static const char *fDoW[] = {
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
};

static const char *aMonth[] = {
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
};

static const char *fMonth[] = {
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
};

static const char *Meridiem[] = {
    "AM",
    "PM",
};

/* 
 * The first Sunday of January is the first day of week 1; days in the new
 * year before this are in week 0.
 */
static int
dt_week_number_sun(dt_t dt) {
    int sunday = dt_doy(dt) - dt_dow(dt) % 7;
    return (sunday + 6) / 7;
}

/* 
 * The first Monday of January is the first day of week 1; days in the new
 * year before this are in week 0.
 */
static int
dt_week_number_mon(dt_t dt) {
    int monday = dt_doy(dt) - (dt_dow(dt) + 6) % 7;
    return (monday + 6) / 7;
}

static int 
moment_hour_12(const moment_t *mt) {
    int h = moment_hour(mt) % 12;
    if (h == 0)
        h = 12;
    return h;
}

static const char *
moment_hour_meridiem(const moment_t *mt) {
    return Meridiem[moment_hour(mt) / 12];
}

static bool
supports_padding_flag(const char c) {
    switch (c) {
        case 'C':
        case 'd':
        case 'e':
        case 'g':
        case 'G':
        case 'H':
        case 'I':
        case 'j':
        case 'k':
        case 'l':
        case 'm':
        case 'M':
        case 'S':
        case 'U':
        case 'V':
        case 'W':
        case 'y':
        case 'Y':
            return TRUE;
    }
    return FALSE;
}

static void
THX_format_num(pTHX_ SV *dsv, size_t width, pad_t want, pad_t def, unsigned int v) {
    char buf[20], *p, *e, *d, c;
    size_t nlen, plen, dlen;

    p = e = buf + sizeof(buf);
    do {
        *--p = '0' + (v % 10);
    } while (v /= 10);

    if (want == PAD_DEFAULT)
        want = def;

    if      (want == PAD_ZERO)  c = '0';
    else if (want == PAD_SPACE) c = ' ';
    else                        width = 0;

    nlen = e - p;
    plen = (width > nlen) ? width - nlen : 0;
    dlen = nlen + plen;
    (void)SvGROW(dsv, SvCUR(dsv) + dlen + 1);
    d = SvPVX(dsv) + SvCUR(dsv);
    if (plen) {
        memset(d, c, plen);
        d += plen;
    }
    memcpy(d, p, nlen);
    SvCUR_set(dsv, SvCUR(dsv) + dlen);
    *SvEND(dsv) = '\0';
}


#define CHR(n, d) (char)('0' + ((n) / (d)) % 10)
static void
THX_format_f(pTHX_ SV *dsv, const moment_t *mt, int len) {
    char buf[9];
    int ns;

    if      (len > 9) len = 9;
    else if (len < 0) len = 0;
    ns = moment_nanosecond(mt);
    if (len == 0) {
        if      ((ns % 1000000) == 0) len = 3;
        else if ((ns % 1000)    == 0) len = 6;
        else                          len = 9;
    }
    switch (len) {
        case 9: buf[8] = CHR(ns, 1);
        case 8: buf[7] = CHR(ns, 10);
        case 7: buf[6] = CHR(ns, 100);
        case 6: buf[5] = CHR(ns, 1000);
        case 5: buf[4] = CHR(ns, 10000);
        case 4: buf[3] = CHR(ns, 100000);
        case 3: buf[2] = CHR(ns, 1000000);
        case 2: buf[1] = CHR(ns, 10000000);
        case 1: buf[0] = CHR(ns, 100000000);
    }
    sv_catpvn(dsv, buf, len);
}
#undef CHR

static void
THX_format_s(pTHX_ SV *dsv, const moment_t *mt) {
    char buf[30], *p, *e;
    int64_t v;

    v = moment_epoch(mt);
    p = e = buf + sizeof(buf);
    if (v < 0) {
        do {
            *--p = '0' - (v % 10);
        } while (v /= 10);
        *--p = '-';
    }
    else {
        do {
            *--p = '0' + (v % 10);
        } while (v /= 10);
    }
    sv_catpvn(dsv, p, e - p);
}

static void
THX_format_z(pTHX_ SV *dsv, const moment_t *mt, int extended) {
    int offset, sign;

    offset = moment_offset(mt);
    if (offset < 0)
        sign = '-', offset = -offset;
    else
        sign = '+';
    if (extended)
        sv_catpvf(dsv, "%c%02d:%02d", sign, offset / 60, offset % 60);
    else
        sv_catpvf(dsv, "%c%04d", sign, (offset / 60) * 100 + (offset % 60));
}

static void
THX_format_Z(pTHX_ SV *dsv, const moment_t *mt) {
    int offset, sign;

    offset = moment_offset(mt);
    if (offset == 0)
        sv_catpvn(dsv, "Z", 1);
    else {
        if (offset < 0)
            sign = '-', offset = -offset;
        else
            sign = '+';
        sv_catpvf(dsv, "%c%02d:%02d", sign, offset / 60, offset % 60);
    }
}

#define format_num(dsv, width, wanted, def, num) \
    THX_format_num(aTHX_ dsv, width, wanted, def, num)

#define format_f(dsv, mt, len) \
    THX_format_f(aTHX_ dsv, mt, len)

#define format_s(dsv, mt) \
    THX_format_s(aTHX_ dsv, mt)

#define format_z(dsv, mt, extended) \
    THX_format_z(aTHX_ dsv, mt, extended)

#define format_Z(dsv, mt) \
    THX_format_Z(aTHX_ dsv, mt)

SV *
THX_moment_strftime(pTHX_ const moment_t *mt, const char *s, STRLEN len) {
    const char *e, *p;
    char c;
    SV *dsv;
    dt_t dt;
    pad_t pad;
    int year, month, day, width, zextd;

    dsv = sv_2mortal(newSV(16));
    SvCUR_set(dsv, 0);
    SvPOK_only(dsv);

    dt = moment_local_dt(mt);
    dt_to_ymd(dt, &year, &month, &day);

    e = s + len;
    while (s < e) {
        p = (const char *)memchr(s, '%', e - s);
        if (p == NULL || p + 1 == e)
            p = e;
        sv_catpvn(dsv, s, p - s);
        if (p == e)
            break;

        pad = PAD_DEFAULT;
        width = -1;
        zextd = 0;
        s = p + 1;

      label:
        switch (c = *s++) {
            case 'a': /* locale's abbreviated day of the week name */
                sv_catpv(dsv, aDoW[dt_dow(dt) - 1]);
                break;
            case 'A': /* locale's full day of the week name */
                sv_catpv(dsv, fDoW[dt_dow(dt) - 1]);
                break;
            case 'b': /* locale's abbreviated month name */
            case 'h':
                sv_catpv(dsv, aMonth[month - 1]);
                break;
            case 'B': /* locale's full month name */
                sv_catpv(dsv, fMonth[month - 1]);
                break;
            case 'c': /* locale's date and time (C locale: %a %b %e %H:%M:%S %Y) */
                sv_catpvf(dsv, "%s %s %2d %02d:%02d:%02d %04d",
                         aDoW[dt_dow(dt) - 1],
                         aMonth[month - 1],
                         day,
                         moment_hour(mt),
                         moment_minute(mt),
                         moment_second(mt),
                         year);
                break;
            case 'C':
                format_num(dsv, 2, pad, PAD_ZERO, year / 100);
                break;
            case 'd':
                format_num(dsv, 2, pad, PAD_ZERO, day);
                break;
            case 'x': /* locale's time representation (C locale: %m/%d/%y) */
            case 'D':
                sv_catpvf(dsv, "%02d/%02d/%02d", month, day, year % 100);
                break;
            case 'e':
                format_num(dsv, 2, pad, PAD_SPACE, day);
                break;
            case 'f': /* extended conversion specification */
                if (moment_nanosecond(mt)) {
                    sv_catpvn(dsv, ".", 1);
                    format_f(dsv, mt, width);
                }
                break;
            case 'F':
                sv_catpvf(dsv, "%04d-%02d-%02d", year, month, day);
                break;
            case 'g':
                format_num(dsv, 2, pad, PAD_ZERO, dt_yow(dt) % 100);
                break;
            case 'G':
                format_num(dsv, 4, pad, PAD_ZERO, dt_yow(dt));
                break;
            case 'H':
                format_num(dsv, 2, pad, PAD_ZERO, moment_hour(mt));
                break;
            case 'I':
                format_num(dsv, 2, pad, PAD_ZERO, moment_hour_12(mt));
                break;
            case 'j':
                format_num(dsv, 3, pad, PAD_ZERO, dt_doy(dt));
                break;
            case 'k': /* extended conversion specification */
                format_num(dsv, 2, pad, PAD_SPACE, moment_hour(mt));
                break;
            case 'l': /* extended conversion specification */
                format_num(dsv, 2, pad, PAD_SPACE, moment_hour_12(mt));
                break;
            case 'm':
                format_num(dsv, 2, pad, PAD_ZERO, month);
                break;
            case 'M':
                format_num(dsv, 2, pad, PAD_ZERO, moment_minute(mt));
                break;
            case 'n':
                sv_catpvn(dsv, "\n", 1);
                break;
            case 'N': /* extended conversion specification */
                format_f(dsv, mt, width);
                break;
            case 'p': /* locale's equivalent of either a.m. or p.m (C locale: AM or PM) */
                sv_catpv(dsv, moment_hour_meridiem(mt));
                break;
            case 'r': /* locale's time in a.m. and p.m. notation (C locale: %I:%M:%S %p) */
                sv_catpvf(dsv, "%02d:%02d:%02d %s",
                          moment_hour_12(mt),
                          moment_minute(mt),
                          moment_second(mt),
                          moment_hour_meridiem(mt));
                break;
            case 'R':
                sv_catpvf(dsv, "%02d:%02d",
                          moment_hour(mt),
                          moment_minute(mt));
                break;
            case 's': /* extended conversion specification */
                format_s(dsv, mt);
                break;
            case 'S':
                format_num(dsv, 2, pad, PAD_ZERO, moment_second(mt));
                break;
            case 't':
                sv_catpvn(dsv, "\t", 1);
                break;
            case 'X': /* locale's date representation (C locale: %H:%M:%S) */
            case 'T':
                sv_catpvf(dsv, "%02d:%02d:%02d",
                          moment_hour(mt),
                          moment_minute(mt),
                          moment_second(mt));
                break;
            case 'u':
                sv_catpvf(dsv, "%d", dt_dow(dt));
                break;
            case 'U':
                format_num(dsv, 2, pad, PAD_ZERO, dt_week_number_sun(dt));
                break;
            case 'V':
                format_num(dsv, 2, pad, PAD_ZERO, dt_woy(dt));
                break;
            case 'w':
                sv_catpvf(dsv, "%d", dt_dow(dt) % 7);
                break;
            case 'W':
                format_num(dsv, 2, pad, PAD_ZERO, dt_week_number_mon(dt));
                break;
            case 'y':
                format_num(dsv, 2, pad, PAD_ZERO, year % 100);
                break;
            case 'Y':
                format_num(dsv, 4, pad, PAD_ZERO, year);
                break;
            case 'z':
                format_z(dsv, mt, zextd);
                break;
            case 'Z':
                format_Z(dsv, mt);
                break;
            case '%':
                sv_catpvn(dsv, "%", 1);
                break;
            case ':':
                if (s < e && *s == 'z') {
                    zextd = 1;
                    goto label;
                }
                goto unknown;
            case '_':
                if (s < e && supports_padding_flag(*s)) {
                    pad = PAD_SPACE;
                    goto label;
                }
                goto unknown;
            case '-':
                if (s < e && supports_padding_flag(*s)) {
                    pad = PAD_NONE;
                    goto label;
                }
                goto unknown;
            case '0': case '1': case '2': case '3': case '4':
            case '5': case '6': case '7': case '8': case '9':
                if (s < e && (*s == 'f' || *s == 'N')) {
                    width = c - '0';
                    goto label;
                }
                if (s < e && c == '0' && supports_padding_flag(*s)) {
                    pad = PAD_ZERO;
                    goto label;
                }
                /* FALLTROUGH */
            default:
            unknown:
                sv_catpvn(dsv, p, s - p);
                break;
        }
    }
    return dsv;
}

SV *
THX_moment_to_string(pTHX_ const moment_t *mt, bool reduced) {
    SV *dsv;
    dt_t dt;
    int year, month, day, sec, ns, offset, sign;

    dsv = sv_2mortal(newSV(16));
    SvCUR_set(dsv, 0);
    SvPOK_only(dsv);

    dt = moment_local_dt(mt);
    dt_to_ymd(dt, &year, &month, &day);

    sv_catpvf(dsv, "%04d-%02d-%02dT%02d:%02d",
        year, month, day, moment_hour(mt), moment_minute(mt));

    sec = moment_second(mt);
    ns  = moment_nanosecond(mt);
    if (!reduced || sec || ns) {
        sv_catpvf(dsv, ":%02d", sec);
        if (ns) {
            if      ((ns % 1000000) == 0) sv_catpvf(dsv, ".%03d", ns / 1000000);
            else if ((ns % 1000)    == 0) sv_catpvf(dsv, ".%06d", ns / 1000);
            else                          sv_catpvf(dsv, ".%09d", ns);
        }
    }

    offset = moment_offset(mt);
    if (offset == 0)
        sv_catpvn(dsv, "Z", 1);
    else {
        if (offset < 0)
            sign = '-', offset = -offset;
        else
            sign = '+';

        if (reduced && (offset % 60) == 0)
            sv_catpvf(dsv, "%c%02d", sign, offset / 60);
        else
            sv_catpvf(dsv, "%c%02d:%02d", sign, offset / 60, offset % 60);
    }

    return dsv;
}

