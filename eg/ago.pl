#!/usr/bin/perl
use strict;
use warnings;
use v5.10;

use Carp         qw[];
use Time::Moment qw[];

sub YEAR   () { 365 + 1/4 - 1/100 + 1/400 }
sub MONTH  () { YEAR / 12                 }
sub DAY    () { 1                         }
sub HOUR   () { DAY / 24                  }
sub MINUTE () { HOUR / 60                 }
sub SECOND () { MINUTE / 60               }

sub ago {
    @_ == 1 || @_ == 2 or Carp::croak(q/Usage: ago(since [, event])/);
    my ($since, $event) = @_;

    $event //= Time::Moment->now;

    ($since->is_before($event))
      or Carp::croak(q/Given moment is in the future/);

    my $d = $event->mjd - $since->mjd;

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
    [  10 * SECOND, 'a few seconds ago' ],
    [  75 * SECOND, 'a minute ago'      ],
    [   1 * MINUTE, 'a minute ago'      ],
    [  30 * MINUTE, '30 minutes ago'    ],
    [   1 * HOUR,   'an hour ago'       ],
    [   2 * HOUR,   '2 hours ago'       ],
    [   1 * DAY,    'a day ago'         ],
    [  20 * DAY,    '20 days ago'       ],
    [   1 * MONTH,  'a month ago'       ],
    [   2 * MONTH,  '2 months ago'      ],
    [  13 * MONTH,  'a year ago'        ],
    [   1 * YEAR,   'a year ago'        ],
    [   2 * YEAR,   '2 years ago'       ],
    [  10 * YEAR,   '10 years ago'      ],
    [ 100 * YEAR,   '100 years ago'     ],
);

use Time::Moment 0.25;
use Test::More   0.88;

my $now = Time::Moment->now;
foreach my $test (@tests) {
    my ($duration, $expected) = @$test;
    my $tm = Time::Moment->from_mjd($now->mjd - $duration);
    is(ago($tm, $now), $expected, "$tm ($duration)");
}

done_testing();
