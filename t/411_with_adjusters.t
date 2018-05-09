#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok('Time::Moment');
  use_ok('Time::Moment::Adjusters', qw[ NextDayOfWeek 
                                        PreviousDayOfWeek 
                                        NextOrSameDayOfWeek 
                                        PreviousOrSameDayOfWeek ]);
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

done_testing();
