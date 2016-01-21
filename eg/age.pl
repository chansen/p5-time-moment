#!/usr/bin/perl
use strict;
use warnings;

use Time::Moment;

# Calculates age of a person in calendar years.
#
# Where a person has been born on February 29th in a leap year, the
# anniversary in a non-leap year can be taken to be February 28th or
# March 1st. Some countries have laws defining which date a person
# born on February 29th comes of age in legal terms. In England and 
# Wales, for example, the legal age of a leapling is March 1st in 
# common years. The same applies in Hong Kong. In Taiwan and in 
# New Zealand, the legal age of a leapling is February 28th in 
# common years.
# https://en.wikipedia.org/wiki/February_29#Births
sub calculate_age {
    @_ == 2 or @_ == 3 or die q/Usage: calculate_age($birth, $event [, $march])/;
    my ($birth, $event, $march) = @_;

    my $years = $birth->delta_years($event);

    unless ($march) {
        # Increment if birth is 02-29 and event is 02-28 in a non-leap year
        ++$years if $birth->day_of_year == 31 + 29 &&  $birth->is_leap_year
                 && $event->day_of_year == 31 + 28 && !$event->is_leap_year;
    }
    return $years;
}

my @tests = (
    [ '2008-02-28T00Z', '2015-02-27T00Z', 0, 6 ],
    [ '2008-02-28T00Z', '2015-02-28T00Z', 0, 7 ],
    [ '2008-02-28T00Z', '2015-03-01T00Z', 0, 7 ],
    [ '2008-02-29T00Z', '2015-02-27T00Z', 0, 6 ],
    [ '2008-02-29T00Z', '2015-02-28T00Z', 0, 7 ],
    [ '2008-02-29T00Z', '2015-03-01T00Z', 0, 7 ],
    [ '2008-03-01T00Z', '2015-02-27T00Z', 0, 6 ],
    [ '2008-03-01T00Z', '2015-02-28T00Z', 0, 6 ],
    [ '2008-03-01T00Z', '2015-03-01T00Z', 0, 7 ],
    [ '2008-02-29T00Z', '2016-02-27T00Z', 0, 7 ],
    [ '2008-02-29T00Z', '2016-02-28T00Z', 0, 7 ],
    [ '2008-02-29T00Z', '2016-02-29T00Z', 0, 8 ],
    [ '2008-02-29T00Z', '2016-03-01T00Z', 0, 8 ],

    [ '2008-02-28T00Z', '2015-02-27T00Z', 1, 6 ],
    [ '2008-02-28T00Z', '2015-02-28T00Z', 1, 7 ],
    [ '2008-02-28T00Z', '2015-03-01T00Z', 1, 7 ],
    [ '2008-02-29T00Z', '2015-02-27T00Z', 1, 6 ],
    [ '2008-02-29T00Z', '2015-02-28T00Z', 1, 6 ],
    [ '2008-02-29T00Z', '2015-03-01T00Z', 1, 7 ],
    [ '2008-03-01T00Z', '2015-02-27T00Z', 1, 6 ],
    [ '2008-03-01T00Z', '2015-02-28T00Z', 1, 6 ],
    [ '2008-03-01T00Z', '2015-03-01T00Z', 1, 7 ],
    [ '2008-02-29T00Z', '2016-02-27T00Z', 1, 7 ],
    [ '2008-02-29T00Z', '2016-02-28T00Z', 1, 7 ],
    [ '2008-02-29T00Z', '2016-02-29T00Z', 1, 8 ],
    [ '2008-02-29T00Z', '2016-03-01T00Z', 1, 8 ],
);

use Test::More 0.88;

foreach my $test (@tests) {
    my ($birth, $event, $march, $age) = @$test;
    my $got = calculate_age(Time::Moment->from_string($birth),
                            Time::Moment->from_string($event),
                            $march);
    is($got, $age, "calculate_age($birth, $event, $march)");
}

done_testing();
