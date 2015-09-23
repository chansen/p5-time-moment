#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm = Time::Moment->from_string('2012-12-24T15:30:45.123456789Z');
    for my $n (-20..20) {
        $n *= $n ** 4;

        {
            my $exp = $n;
            {
                my $got = $tm->delta_hours($tm->plus_hours($n));
                is($got, $exp, "delta_hours(plus_hours($n))");
            }
            {
                my $got = $tm->delta_minutes($tm->plus_minutes($n));
                is($got, $exp, "delta_minutes(plus_minutes($n))");
            }
            {
                my $got = $tm->delta_seconds($tm->plus_seconds($n));
                is($got, $exp, "delta_seconds(plus_seconds($n))");
            }
            {
                my $got = $tm->delta_milliseconds($tm->plus_milliseconds($n));
                is($got, $exp, "delta_milliseconds(plus_milliseconds($n))");
            }
            {
                my $got = $tm->delta_microseconds($tm->plus_microseconds($n));
                is($got, $exp, "delta_microseconds(plus_microseconds($n))");
            }
            {
                my $got = $tm->delta_nanoseconds($tm->plus_nanoseconds($n));
                is($got, $exp, "delta_nanoseconds(plus_nanoseconds($n))");
            }
        }
        {
            my $exp = -$n;
            {
                my $got = $tm->delta_hours($tm->minus_hours($n));
                is($got, $exp, "delta_hours(minus_hours($n))");
            }
            {
                my $got = $tm->delta_minutes($tm->minus_minutes($n));
                is($got, $exp, "delta_minutes(minus_minutes($n))");
            }
            {
                my $got = $tm->delta_seconds($tm->minus_seconds($n));
                is($got, $exp, "delta_seconds(minus_seconds($n))");
            }
            {
                my $got = $tm->delta_milliseconds($tm->minus_milliseconds($n));
                is($got, $exp, "delta_milliseconds(minus_milliseconds($n))");
            }
            {
                my $got = $tm->delta_microseconds($tm->minus_microseconds($n));
                is($got, $exp, "delta_microseconds(minus_microseconds($n))");
            }
            {
                my $got = $tm->delta_nanoseconds($tm->minus_nanoseconds($n));
                is($got, $exp, "delta_nanoseconds(minus_nanoseconds($n))");
            }
        }
    }
}

{
    my $tm1 = Time::Moment->from_string('2012-12-24T15:30:45Z');
    for my $h (-10, -1, 0, 1, 10) {
        my $tm2 = $tm1->with_offset_same_instant($h*60);
        is($tm1->delta_hours($tm2),        0, "$tm1->delta_hours($tm2)");
        is($tm1->delta_minutes($tm2),      0, "$tm1->delta_minutes($tm2)");
        is($tm1->delta_seconds($tm2),      0, "$tm1->delta_seconds($tm2)");
        is($tm1->delta_milliseconds($tm2), 0, "$tm1->delta_milliseconds($tm2)");
        is($tm1->delta_microseconds($tm2), 0, "$tm1->delta_microseconds($tm2)");
        is($tm1->delta_nanoseconds($tm2),  0, "$tm1->delta_nanoseconds($tm2)");
    
        is($tm2->delta_hours($tm1),        0, "$tm2->delta_hours($tm1)");
        is($tm2->delta_minutes($tm1),      0, "$tm2->delta_minutes($tm1)");
        is($tm2->delta_seconds($tm1),      0, "$tm2->delta_seconds($tm1)");
        is($tm2->delta_milliseconds($tm1), 0, "$tm2->delta_milliseconds($tm1)");
        is($tm2->delta_microseconds($tm1), 0, "$tm2->delta_microseconds($tm1)");
        is($tm2->delta_nanoseconds($tm1),  0, "$tm2->delta_nanoseconds($tm1)");
    }
}

{
    my $tm1 = Time::Moment->from_string('2012-12-24T15:30:45Z');
    for my $h (-10, -1, 0, 1, 10) {
        my $tm2 = $tm1->with_offset_same_local($h*60);
        is($tm1->delta_hours($tm2),        -$h,           "$tm1->delta_hours($tm2)");
        is($tm1->delta_minutes($tm2),      -$h*60,        "$tm1->delta_minutes($tm2)");
        is($tm1->delta_seconds($tm2),      -$h*60*60,     "$tm1->delta_seconds($tm2)");
        is($tm1->delta_milliseconds($tm2), -$h*60*60*1E3, "$tm1->delta_milliseconds($tm2)");
        is($tm1->delta_microseconds($tm2), -$h*60*60*1E6, "$tm1->delta_microseconds($tm2)");
        is($tm1->delta_nanoseconds($tm2),  -$h*60*60*1E9, "$tm1->delta_nanoseconds($tm2)");
    
        is($tm2->delta_hours($tm1),         $h,           "$tm2->delta_hours($tm1)");
        is($tm2->delta_minutes($tm1),       $h*60,        "$tm2->delta_minutes($tm1)");
        is($tm2->delta_seconds($tm1),       $h*60*60,     "$tm2->delta_seconds($tm1)");
        is($tm2->delta_milliseconds($tm1),  $h*60*60*1E3, "$tm2->delta_milliseconds($tm1)");
        is($tm2->delta_microseconds($tm1),  $h*60*60*1E6, "$tm2->delta_microseconds($tm1)");
        is($tm2->delta_nanoseconds($tm1),   $h*60*60*1E9, "$tm2->delta_nanoseconds($tm1)");
    }
}

done_testing();
