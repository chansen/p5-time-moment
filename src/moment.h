#ifndef __MOMENT_H__
#define __MOMENT_H__
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "dt_core.h"

#ifndef _MSC_VER
#  include <stdint.h>
#else
#  if _MSC_VER >= 1600
#   include <stdint.h>
#  else
    typedef __int32             int32_t;
    typedef __int64             int64_t;
    typedef unsigned __int32    uint32_t;
    typedef unsigned __int64    uint64_t;
#  endif
#  ifndef INT64_C
#   define INT64_C(x) x##i64
#  endif
#endif

#define SECS_PER_DAY        86400
#define SECS_PER_HOUR       3600
#define SECS_PER_MIN        60

#define UNIX_EPOCH          INT64_C(62135683200)  /* 1970-01-01T00:00:00 */

#define MIN_EPOCH_SEC       INT64_C(-62135596800) /* 0001-01-01T00:00:00 */
#define MAX_EPOCH_SEC       INT64_C(253402300799) /* 9999-12-31T23:59:59 */
    
#define MIN_OFFSET          -1080
#define MAX_OFFSET          1080

#define VALID_EPOCH_SEC(s) \
    (s >= MIN_EPOCH_SEC && s <= MAX_EPOCH_SEC)

#define VALID_OFFSET(o) \
    (o >= MIN_OFFSET && o <= MAX_OFFSET)

typedef struct {
    int64_t sec;
    int32_t nsec;
    int32_t offset;
} moment_t;

moment_t    THX_moment_from_epoch(pTHX_ int64_t sec, IV usec, IV offset);
moment_t    THX_moment_with_offset(pTHX_ const moment_t *mt, IV offset);

int64_t     moment_epoch(const moment_t *mt);

int64_t     moment_utc_rd_seconds(const moment_t *mt);
int64_t     moment_local_rd_seconds(const moment_t *mt);

dt_t        moment_local_dt(const moment_t *mt);

void        moment_to_utc_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos);
void        moment_to_local_rd_values(const moment_t *mt, IV *rdn, IV *sod, IV *nos);

IV          moment_compare(const moment_t *m1, const moment_t *m2);

int         moment_year(const moment_t *mt);
int         moment_quarter(const moment_t *mt);
int         moment_month(const moment_t *mt);
int         moment_week(const moment_t *mt);
int         moment_day_of_year(const moment_t *mt);
int         moment_day_of_quarter(const moment_t *mt);
int         moment_day_of_month(const moment_t *mt);
int         moment_day_of_week(const moment_t *mt);
int         moment_hour(const moment_t *mt);
int         moment_minute(const moment_t *mt);
int         moment_second(const moment_t *mt);
int         moment_millisecond(const moment_t *mt);
int         moment_microsecond(const moment_t *mt);
int         moment_nanosecond(const moment_t *mt);

int         moment_offset(const moment_t *mt);

#define moment_from_epoch(sec, usec, offset) \
    THX_moment_from_epoch(aTHX_ sec, usec, offset)

#define moment_with_offset(self, offset) \
    THX_moment_with_offset(aTHX_ self, offset)

#endif

