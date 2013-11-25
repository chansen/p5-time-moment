#include "moment.h"

static bool
leap_year(unsigned int y) {
    return ((y & 3) == 0 && (y % 100 != 0 || y % 400 == 0));
}

static unsigned int
month_days(unsigned int y, unsigned int m) {
    static const unsigned int days[2][13] = {
        { 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 },
        { 0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    };
    return days[m == 2 && leap_year(y)][m];
}

static int
pnum(const unsigned char * const p, size_t i, const size_t end, unsigned int *vp) {
    unsigned int v = 0;

    for(; i <= end; i++) {
        const unsigned char c = p[i];
        if (c < '0' || c > '9')
            return -1;
        v = v * 10 + c - '0';
    }
    *vp = v;
    return 0;
}

static int
parse_string(const unsigned char *str, size_t len, int64_t *secp, IV *usecp, IV *offp) {
    static const unsigned int DayOffset[13] = {
        0, 306, 337, 0, 31, 61, 92, 122, 153, 184, 214, 245, 275,
    };
    unsigned int rdn, sod, usec, year, month, day, hour, min, sec;
    const unsigned char *end;
    unsigned char ch;
    int off;

    /*
     *           1
     * 01234567890123456789
     * 2013-12-31T23:59:59Z
     */
    if (len < 20 ||
        str[4]  != '-' || str[7]  != '-' ||
        str[10] != 'T' ||
        str[13] != ':' || str[16] != ':')
        return -1;

    if (pnum(str,  0,  3, &year)  || year  < 1  ||
        pnum(str,  5,  6, &month) || month < 1  || month > 12 ||
        pnum(str,  8,  9, &day)   || day   < 1  || day   > 31 ||
        pnum(str, 11, 12, &hour)  || hour  > 23 ||
        pnum(str, 14, 15, &min)   || min   > 59 ||
        pnum(str, 17, 18, &sec)   || sec   > 59)
        return -1;

    if (day > 28 && day > month_days(year, month))
        return -1;

    if (month < 3)
        year--;

    rdn = (1461 * year)/4 - year/100 + year/400 + DayOffset[month] + day - 306;
    sod = hour * 3600 + min * 60 + sec;
    end = str + len;
    str = str + 19;
    off = usec = 0;

    ch = *str;
    if (ch == '.' || ch == ',') {
        const unsigned char *p;
        size_t n;

        p = ++str;
        while (str < end) {
            ch = *str;
            if (ch < '0' || ch > '9')
                break;
            usec = usec * 10 + ch - '0';
            str++;
        }

        n = str - p;
        if (n < 1 || n > 6)
            return -1;

        switch (n) {
            case 1: usec *= 10;
            case 2: usec *= 10;
            case 3: usec *= 10;
            case 4: usec *= 10;
            case 5: usec *= 10;
        }
    }

    if (str == end)
        return -1;

    ch = *str++;
    if (ch != 'Z') {
        /*
         *  01234
         * ±00:00
         */
        if (str + 5 < end || !(ch == '+' || ch == '-') || str[2] != ':')
            return -1;

        if (pnum(str, 0, 1, &hour) || hour > 18 ||
            pnum(str, 3, 4, &min)  || min  > 59)
            return -1;

        off = hour * 60 + min;
        if (ch == '-')
            off *= -1;

        str += 5;
    }

    if (str != end)
        return -1;

    *secp  = ((int64_t)rdn - 719163) * 86400 + sod - off * 60;
    *usecp = usec;
    *offp  = off;
    return 0;
}

moment_t
THX_moment_from_string(pTHX_ const char *str, STRLEN len) {
    int64_t sec;
    IV usec, offset;

    if (parse_string((const unsigned char *)str, len, &sec, &usec, &offset))
        croak("Cannot parse the given string");

    return moment_from_epoch(sec, usec, offset);
}

