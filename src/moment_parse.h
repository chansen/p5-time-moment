#ifndef __MOMENT_PARSE_H__
#define __MOMENT_PARSE_H__
#include "moment.h"

moment_t THX_moment_from_string(pTHX_ const char *str, STRLEN len, bool lenient);

#define moment_from_string(str, len, lenient) \
    THX_moment_from_string(aTHX_ str, len, lenient)

#endif

