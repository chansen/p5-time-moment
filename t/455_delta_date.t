#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm = Time::Moment->from_string('2012-12-24T15:30:45.123456789Z');
    for my $n (-10..10) {
        my $x = $n * ($n ** 2);

        {
            my $exp = $x;
            {
                my $got = $tm->delta_years($tm->plus_years($x));
                is($got, $exp, "delta_years(plus_years($x))");
            }
            {
                my $got = $tm->delta_months($tm->plus_months($x));
                is($got, $exp, "delta_months(plus_months($x))");
            }
            {
                my $got = $tm->delta_weeks($tm->plus_weeks($x));
                is($got, $exp, "delta_weeks(plus_weeks($x))");
            }
            {
                my $got = $tm->delta_days($tm->plus_days($x));
                is($got, $exp, "delta_days(plus_days($x))");
            }
        }
        {
            my $exp = -$x;
            {
                my $got = $tm->delta_years($tm->minus_years($x));
                is($got, $exp, "delta_years(minus_years($x))");
            }
            {
                my $got = $tm->delta_months($tm->minus_months($x));
                is($got, $exp, "delta_months(minus_months($x))");
            }
            {
                my $got = $tm->delta_weeks($tm->minus_weeks($x));
                is($got, $exp, "delta_weeks(minus_weeks($x))");
            }
            {
                my $got = $tm->delta_days($tm->minus_days($x));
                is($got, $exp, "delta_days(minus_days($x))");
            }
        }
    }
}

{
    my $tm1 = Time::Moment->from_string('2012-12-23T15:30:45+12');
    my $tm2 = Time::Moment->from_string('2012-12-24T15:30:45-12');
    is($tm1->delta_days($tm2), 1, "$tm1->delta_days($tm2)");
}

{
    my $tm1 = Time::Moment->from_string('2012-10-23T15:30:45+12');
    my $tm2 = Time::Moment->from_string('2012-12-22T15:30:45-12');
    is($tm1->delta_months($tm2), 1, "$tm1->delta_months($tm2)");
}

{
    my $tm1 = Time::Moment->from_string('2012-10-23T15:30:45+12');
    my $tm2 = Time::Moment->from_string('2012-12-23T15:30:45-12');
    is($tm1->delta_months($tm2), 2, "$tm1->delta_months($tm2)");
}

done_testing();
