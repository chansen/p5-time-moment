#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok('Time::Moment');
  use_ok('Time::Moment::Adjusters', qw[ NextDayOfWeek 
                                        PreviousDayOfWeek 
                                        NextOrSameDayOfWeek 
                                        PreviousOrSameDayOfWeek
                                        FirstDayOfWeekInMonth
                                        LastDayOfWeekInMonth
                                        NthDayOfWeekInMonth
                                      ]);
}

my $Sunday = Time::Moment->from_string('2018-W02-7T00Z');

{
    my @M = (
    # M T W T F S S
      7,1,2,3,4,5,6, # M
      6,7,1,2,3,4,5, # T
      5,6,7,1,2,3,4, # W
      4,5,6,7,1,2,3, # T
      3,4,5,6,7,1,2, # F
      2,3,4,5,6,7,1, # S
      1,2,3,4,5,6,7, # S
    );

    foreach my $d1 (1..7) {
        my $tm = $Sunday->plus_days($d1);
        foreach my $d2 (1..7) {
            my $got = $tm->with(NextDayOfWeek($d2));
            my $exp = $tm->plus_days($M[7 * $d1 + $d2 - 8]);
            is($got, $exp, "$tm->with(NextDayOfWeek($d2))");
        }
    }

    foreach my $d1 (1..7) {
        my $tm = $Sunday->plus_days($d1);
        foreach my $d2 (1..7) {
            my $got = $tm->with(PreviousDayOfWeek($d2));
            my $exp = $tm->minus_days($M[7 * $d2 + $d1 - 8]);
            is($got, $exp, "$tm->with(PreviousDayOfWeek($d2))");
        }
    }
}

{
    my @M = (
    # M T W T F S S
      0,1,2,3,4,5,6, # M
      6,0,1,2,3,4,5, # T
      5,6,0,1,2,3,4, # W
      4,5,6,0,1,2,3, # T
      3,4,5,6,0,1,2, # F
      2,3,4,5,6,0,1, # S
      1,2,3,4,5,6,0, # S
    );

    foreach my $d1 (1..7) {
        my $tm = $Sunday->plus_days($d1);
        foreach my $d2 (1..7) {
            my $got = $tm->with(NextOrSameDayOfWeek($d2));
            my $exp = $tm->plus_days($M[7 * $d1 + $d2 - 8]);
            is($got, $exp, "$tm->with(NextOrSameDayOfWeek($d2))");
        }
    }

    foreach my $d1 (1..7) {
        my $tm = $Sunday->plus_days($d1);
        foreach my $d2 (1..7) {
            my $got = $tm->with(PreviousOrSameDayOfWeek($d2));
            my $exp = $tm->minus_days($M[7 * $d2 + $d1 - 8]);
            is($got, $exp, "$tm->with(PreviousOrSameDayOfWeek($d2))");
        }
    }
}

my $Monday = Time::Moment->from_string('1996-01-01T00Z');

{
    my @M = (undef, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);

    for (my $tm = $Monday; $tm->year == $Monday->year; $tm = $tm->plus_days(1)) {
        foreach my $d1 (1..7) {
            my $got = $tm->with(FirstDayOfWeekInMonth($d1));
            is($got->day_of_week, $d1, "$tm->with(FirstDayOfWeekInMonth($d1))->day_of_week == $d1");
            is($got->month, $tm->month, "$tm->with(FirstDayOfWeekInMonth($d1))->month == $tm->month");

            my $got2 = $got->minus_days(7);
            is($got2->month, $M[$got->month], "$tm->with(FirstDayOfWeekInMonth($d1))->minus_days(7)->month == $M[$got->month]");
        }
    }
}

{
    my @M = (undef, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1);

    for (my $tm = $Monday; $tm->year == $Monday->year; $tm = $tm->plus_days(1)) {
        foreach my $d1 (1..7) {
            my $got = $tm->with(LastDayOfWeekInMonth($d1));
            is($got->day_of_week, $d1, "$tm->with(LastDayOfWeekInMonth($d1))->day_of_week == $d1");
            is($got->month, $tm->month, "$tm->with(LastDayOfWeekInMonth($d1))->month == $tm->month");

            my $got2 = $got->plus_days(7);
            is($got2->month, $M[$got->month], "$tm->with(LastDayOfWeekInMonth($d1))->plus_days(7)->month == $M[$got->month]");
        }
    }

}

{
    for my $m1 (1..12) {
        my $tm = $Monday->with_month($m1);
        for my $d1 (1..7) {
            for my $o1 (1..4) {
                my $got = $tm->with(NthDayOfWeekInMonth($o1, $d1));
                is($got->day_of_week, $d1, "$tm->with(NthDayOfWeekInMonth($o1, $d1))->day_of_week == $d1");
                is($got->month, $tm->month, "$tm->with(NthDayOfWeekInMonth($o1, $d1))->month == $tm->month");

                for my $o2 (1..$o1-1) {
                    my $got2 = $got->minus_days(7 * $o2);
                    is($got2->month, $tm->month, "$got->minus_days(7 * $o2)->month == $tm->month")
                        or done_testing, exit;
                }
            }
        }
    }
}

done_testing();
