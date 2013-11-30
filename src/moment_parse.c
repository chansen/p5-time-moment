#include "moment.h"
#include "dt_core.h"
#include "dt_parse.h"

static size_t
count_digits(const unsigned char * const p, size_t i, const size_t len) {
    size_t n = i;

    for(; i < len; i++) {
        const unsigned char c = p[i];
        if (c < '0' || c > '9')
            break;
    }
    return i - n;
}

static int
parse_number(const unsigned char * const p, size_t i, const size_t len) {
    int v = 0;

    switch (len) {
        case 6: v += (p[i++] - '0') * 100000;
        case 5: v += (p[i++] - '0') * 10000;
        case 4: v += (p[i++] - '0') * 1000;
        case 3: v += (p[i++] - '0') * 100;
        case 2: v += (p[i++] - '0') * 10;
        case 1: v += (p[i++] - '0');
    }
    return v;
}

static const int pow_10[] = {
    1,
    10,
    100,
    1000,
    10000,
    100000,
    1000000,
};

/*
 *  ffffff
 */

static size_t
parse_fraction_digits(const unsigned char *p, size_t i, size_t len, int *fp) {
    size_t n, ndigits;

    ndigits = n = count_digits(p, i, len);
    if (ndigits < 1)
        return 0;
    if (ndigits > 6)
        ndigits = 6;
    if (fp)
        *fp = parse_number(p, i, ndigits) * pow_10[6 - ndigits];
    return n;
}

/*
 *  hhmm
 *  hhmmss
 *  hhmmss.ffffff
 */

static size_t
parse_time_basic(const char *str, size_t len, int *sp, int *fp) {
    const unsigned char *p;
    int h, m, s, f;
    size_t n;

    p = (const unsigned char *)str;
    n = count_digits(p, 0, len);
    s = f = 0;
    switch (n) {
        case 4: /* hhmm */
            h = parse_number(p, 0, 2);
            m = parse_number(p, 2, 2);
            goto hms;
        case 6: /* hhmmss */
            h = parse_number(p, 0, 2);
            m = parse_number(p, 2, 2);
            s = parse_number(p, 4, 2);
            break;
        default:
            return 0;
    }

    /* hhmmss.ffffff */
    if (n < len && (p[n] == '.' || p[n] == ',')) {
        size_t r = parse_fraction_digits(p, ++n, len, &f);
        if (!r)
            return 0;
        n += r;
    }

  hms:
    if (h > 23 || m > 59 || s > 59)
        return 0;

    if (sp)
        *sp = h * 3600 + m * 60 + s;
    if (fp)
        *fp = f;
    return n;
}

/*
 *  Z
 *  ±hh
 *  ±hhmm
 */

static size_t
parse_zone_basic(const char *str, size_t len, int *op) {
    const unsigned char *p;
    int o, h, m, sign;
    size_t n;

    if (len < 1)
        return 0;

    p = (const unsigned char *)str;
    switch (*p) {
        case 'Z':
            o = 0;
            n = 1;
            goto offset;
        case '+':
            sign = 1;
            break;
        case '-':
            sign = -1;
            break;
        default:
            return 0;
    }

    if (len < 3)
        return 0;

    n = count_digits(p, 1, len);
    m = 0;
    switch (n) {
        case 2: /* ±hh */
            h = parse_number(p, 1, 2);
            n = 3;
            break;
        case 4: /* ±hhmm */
            h = parse_number(p, 1, 2);
            m = parse_number(p, 3, 2);
            n = 5;
            break;
        default:
            return 0;
    }

    if (h > 18 || m > 59)
        return 0;
    o = sign * (h * 60 + m);
    if (o == 0 && sign < 0)
        return 0;

 offset:
    if (op)
        *op = o;
    return n;
}

/*
 *  hh:mm
 *  hh:mm:ss
 *  hh:mm:ss.ffffff
 */

static size_t
parse_time_extended(const char *str, size_t len, int *sp, int *fp) {
    const unsigned char *p;
    int h, m, s, f;
    size_t n;

    if (len < 5)
        return 0;

    p = (const unsigned char *)str;
    if (count_digits(p, 0, len) != 2 || p[2] != ':' ||
        count_digits(p, 3, len) != 2)
        return 0;

    h = parse_number(p, 0, 2);
    m = parse_number(p, 3, 2);
    s = f = 0;
    n = 5;

    if (len < 6 || p[5] != ':')
        goto hms;

    if (count_digits(p, 6, len) != 2)
        return 0;

    s = parse_number(p, 6, 2);
    n = 8;

    /* hh:mm:ss.ffffff */
    if (n < len && (p[n] == '.' || p[n] == ',')) {
        size_t r = parse_fraction_digits(p, ++n, len, &f);
        if (!r)
            return 0;
        n += r;
    }

  hms:
    if (h > 23 || m > 59 || s > 59)
        return 0;

    if (sp)
        *sp = h * 3600 + m * 60 + s;
    if (fp)
        *fp = f;
    return n;
}

/*
 *  Z
 *  ±hh
 *  ±hh:mm
 */

static size_t
parse_zone_extended(const char *str, size_t len, int *op) {
    const unsigned char *p;
    int o, h, m, sign;
    size_t n;

    if (len < 1)
        return 0;

    p = (const unsigned char *)str;
    switch (*p) {
        case 'Z':
            o = 0;
            n = 1;
            goto offset;
        case '+':
            sign = 1;
            break;
        case '-':
            sign = -1;
            break;
        default:
            return 0;
    }

    if (len < 3 || count_digits(p, 1, len) != 2)
        return 0;

    h = parse_number(p, 1, 2);
    m = 0;
    n = 3;

    if (len < 4 || p[3] != ':')
        goto hm;

    if (count_digits(p, 4, len) != 2)
        return 0;

    m = parse_number(p, 4, 2);
    n = 6;

 hm:
    if (h > 18 || m > 59)
        return 0;
    o = sign * (h * 60 + m);
    if (o == 0 && sign < 0)
        return 0;

 offset:
    if (op)
        *op = o;
    return n;
}

static int
parse_string(const char *str, size_t len, int64_t *secp, IV *fracp, IV *offp) {
    size_t n;
    dt_t dt;
    int sod, frac, off;
    bool ext;

    if (!(n = dt_parse_string(str, len, &dt)))
        return 1;

    ext = str[4] == '-';
    if (n == len || !(str[n] == 'T' || str[n] == ' '))
        return 1;

    ++n;
    str += n;
    len -= n;

    if (ext)
        n = parse_time_extended(str, len, &sod, &frac);
    else
        n = parse_time_basic(str, len, &sod, &frac);

    if (!n)
        return 1;

    str += n;
    len -= n;

    if (ext)
        n = parse_zone_extended(str, len, &off);
    else
        n = parse_zone_basic(str, len, &off);

    if (!n || n != len)
        return 1;

    *secp  = ((int64_t)dt_rdn(dt) - 719163) * 86400 + sod - off * 60;
    *fracp = frac;
    *offp  = off;
    return 0;
}

moment_t
THX_moment_from_string(pTHX_ const char *str, STRLEN len) {
    int64_t sec;
    IV usec, offset;

    if (parse_string(str, len, &sec, &usec, &offset))
        croak("Cannot parse the given string");

    return moment_from_epoch(sec, usec, offset);
}

