#ifndef __MOMENT_FMT_H__
#define __MOMENT_FMT_H__
#include "moment.h"

SV * THX_moment_strftime(pTHX_ const moment_t *mt, const char *str, STRLEN len);
SV * THX_moment_to_string(pTHX_ const moment_t *mt, bool reduced);

#define moment_strftime(mt, str, len) \
    THX_moment_strftime(aTHX_ mt, str, len)

#define moment_to_string(mt, reduced) \
    THX_moment_to_string(aTHX_ mt, reduced)

#endif

