#!/usr/bin/perl
use strict;
use warnings;

use Carp         qw[];
use Time::Moment qw[];

sub YEAR   () { 365 + 1/4 - 1/100 + 1/400 }
sub MONTH  () { YEAR / 12                 }
sub DAY    () { 1                         }
sub HOUR   () { DAY / 24                  }
sub MINUTE () { HOUR / 60                 }
sub SECOND () { MINUTE / 60               }

sub ago {
    @_ == 1 or Carp::croak(q/Usage: ago(moment)/);
    my ($moment) = @_;

    my $now = Time::Moment->now;

    ($now->compare($moment) >= 0)
      or Carp::croak(q/Given moment is in the future/);

    my $d = $now->mjd - $moment->mjd;

    if ($d < 0.75 * DAY) {
        if ($d < 0.75 * MINUTE) {
            return 'a few seconds ago';
        }
        elsif ($d < 1.5 * MINUTE) {
            return 'a minute ago';
        }
        elsif ($d < 0.75 * HOUR) {
            return sprintf '%d minutes ago', $d / MINUTE + 0.5;
        }
        elsif ($d < 1.5 * HOUR) {
            return 'an hour ago';
        }
        else {
            return sprintf '%d hours ago', $d / HOUR + 0.5;
        }
    }
    else {
        if ($d < 1.5 * DAY) {
            return 'a day ago';
        }
        elsif ($d < 0.75 * MONTH) {
            return sprintf '%d days ago', $d / DAY + 0.5;
        }
        elsif ($d < 1.5 * MONTH) {
            return 'a month ago';
        }
        elsif ($d < 0.75 * YEAR) {
            return sprintf '%d months ago', $d / MONTH + 0.5;
        }
        elsif ($d < 1.5 * YEAR) {
            return 'a year ago';
        }
        else {
            return sprintf '%d years ago', $d / YEAR + 0.5;
        }
    }
}

my @tests = (
    [ SECOND  *  10, 'a few seconds ago' ],
    [ MINUTE  *   1, 'a minute ago'      ],
    [ SECOND  *  75, 'a minute ago'      ],
    [ MINUTE  *  30, '30 minutes ago'    ],
    [ HOUR    *   1, 'an hour ago'       ],
    [ HOUR    *   2, '2 hours ago'       ],
    [ DAY     *   1, 'a day ago'         ],
    [ DAY     *  20, '20 days ago'       ],
    [ MONTH   *   1, 'a month ago'       ],
    [ MONTH   *   2, '2 months ago'      ],
    [ MONTH   *  13, 'a year ago'        ],
    [ YEAR    *   1, 'a year ago'        ],
    [ YEAR    *   2, '2 years ago'       ],
    [ YEAR    *  10, '10 years ago'      ],
    [ YEAR    * 100, '100 years ago'     ],
);

use Time::Moment 0.25;
use Test::More   0.88;

my $now = Time::Moment->now;
foreach my $test (@tests) {
    my ($duration, $expected) = @$test;
    my $tm = Time::Moment->from_mjd($now->mjd - $duration);
    is(ago($tm), $expected, "$tm ($duration)");
}

done_testing();
