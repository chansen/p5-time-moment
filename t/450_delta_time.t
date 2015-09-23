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
        my $x = $n * ($n ** 4);

        {
            my $exp = $x;
            {
                my $got = $tm->delta_hours($tm->plus_hours($x));
                is($got, $exp, "delta_hours(plus_hours($x))");
            }
            {
                my $got = $tm->delta_minutes($tm->plus_minutes($x));
                is($got, $exp, "delta_minutes(plus_minutes($x))");
            }
            {
                my $got = $tm->delta_seconds($tm->plus_seconds($x));
                is($got, $exp, "delta_seconds(plus_seconds($x))");
            }
            {
                my $got = $tm->delta_milliseconds($tm->plus_milliseconds($x));
                is($got, $exp, "delta_milliseconds(plus_milliseconds($x))");
            }
            {
                my $got = $tm->delta_microseconds($tm->plus_microseconds($x));
                is($got, $exp, "delta_microseconds(plus_microseconds($x))");
            }
            {
                my $got = $tm->delta_nanoseconds($tm->plus_nanoseconds($x));
                is($got, $exp, "delta_nanoseconds(plus_nanoseconds($x))");
            }
        }
        {
            my $exp = -$x;
            {
                my $got = $tm->delta_hours($tm->minus_hours($x));
                is($got, $exp, "delta_hours(minus_hours($x))");
            }
            {
                my $got = $tm->delta_minutes($tm->minus_minutes($x));
                is($got, $exp, "delta_minutes(minus_minutes($x))");
            }
            {
                my $got = $tm->delta_seconds($tm->minus_seconds($x));
                is($got, $exp, "delta_seconds(minus_seconds($x))");
            }
            {
                my $got = $tm->delta_milliseconds($tm->minus_milliseconds($x));
                is($got, $exp, "delta_milliseconds(minus_milliseconds($x))");
            }
            {
                my $got = $tm->delta_microseconds($tm->minus_microseconds($x));
                is($got, $exp, "delta_microseconds(minus_microseconds($x))");
            }
            {
                my $got = $tm->delta_nanoseconds($tm->minus_nanoseconds($x));
                is($got, $exp, "delta_nanoseconds(minus_nanoseconds($x))");
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
