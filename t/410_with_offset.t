#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789Z");
    for my $offset (-1080, -600, -120, -60, -30, -1, 0, 1, 30, 60, 120, 600, 1080) {
        my $got = $tm->with_offset_same_instant($offset);
        
        my $prefix = "$tm->with_offset_same_instant($offset)";
        is($got->epoch,       $tm->epoch, "$prefix->epoch");
        is($got->millisecond,        123, "$prefix->millisecond");
        is($got->microsecond,     123456, "$prefix->microsecond");
        is($got->nanosecond,   123456789, "$prefix->nanosecond");
        
        is($got->utc_rd_as_seconds,
           $tm->utc_rd_as_seconds,
           "$prefix->utc_rd_as_seconds");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789Z");
    for my $offset (-1080, -600, -120, -60, -30, -1, 0, 1, 30, 60, 120, 600, 1080) {
        my $got = $tm->with_offset_same_local($offset);
        
        my $prefix = "$tm->with_offset_same_local($offset)";
        is($got->year,              2012, "$prefix->year");
        is($got->month,               12, "$prefix->month");
        is($got->day_of_month,        24, "$prefix->day_of_month");
        is($got->hour,                12, "$prefix->hour");
        is($got->minute,              30, "$prefix->minute");
        is($got->second,              45, "$prefix->second");
        is($got->millisecond,        123, "$prefix->millisecond");
        is($got->microsecond,     123456, "$prefix->microsecond");
        is($got->nanosecond,   123456789, "$prefix->nanosecond");
        
        is($got->local_rd_as_seconds,
           $tm->local_rd_as_seconds,
           "$prefix->local_rd_as_seconds");
    }
}

done_testing();

