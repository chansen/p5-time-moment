#!/usr/bin/perl
use strict;
use warnings;
use v5.10;

use Getopt::Long qw[];
use Time::Moment qw[];

my $Moment = Time::Moment->now
                         ->with_day_of_month(1)
                         ->at_midnight;

Getopt::Long::GetOptions(
    'y|year=i' => sub {
        my ($name, $year) = @_;

        ($year >= 1 && $year <= 9999)
          or die qq/Option '$name' is out of the range [1, 9999]\n/;

        $Moment = $Moment->with_year($year);
    },
    'm|month=i' => sub {
        my ($name, $month) = @_;

        ($month >= 1 && $month <= 12)
          or die qq/Option '$name' is out of the range [1=January, 12=December]\n/;

        $Moment = $Moment->with_month($month);
    },
    'w|week=i' => sub {
        my ($name, $week) = @_;

        my $year   = $Moment->year;
        my $length = $Moment->with_day_of_month(4)
                            ->length_of_week_year;

        ($week >= 1 && $week <= $length)
          or die qq/Option '$name' is out of the range [1, $length] for year $year\n/;

        # Select the calendar month associated with a given week number ($week)
        # in the ISO 8601 week-date system, for a given calendar year.
        #
        # Terminology:
        # - Calendar year: January 1 to December 31; months are defined in this
        #   frame.
        # - Week-year: the year used by the ISO 8601 week date. Week 1 is the
        #   week containing 4 January, and weeks begin on Monday. A week-year
        #   may begin in late December of the previous calendar year or extend
        #   into early January of the next.
        #
        # Procedure:
        # 1) Set the date to 4 January of the target calendar year. This
        #    guarantees being inside Week 1 of the correct week-year.
        # 2) Select the requested week number within that week-year.
        # 3) Move to Monday of that week (weekday 1). Anchoring to Monday
        #    ensures the date remains at the start of the week, avoiding a
        #    later weekday that might fall in January of the next calendar
        #    year.
        # 4) Set the day of month to 1 to obtain the first day of the
        #    corresponding calendar month.
        $Moment = $Moment->with_month(1)
                         ->with_day_of_month(4)
                         ->with_week($week)
                         ->with_day_of_week(1)
                         ->with_day_of_month(1);

        # Corner case:
        # Week 1 may begin in December of the previous calendar year. If
        # moving to the first day of the month places the date in the previous
        # calendar year, advance one month to return to the intended calendar
        # year.
        if ($Moment->year < $year) {
          $Moment = $Moment->plus_months(1);
        }
    },
) or do {
    say "usage: $0 [-y year] [-m month]";
    say "    -y --year    the year [1, 9999]";
    say "    -m --month   the month of the year [1=January, 12=December]";
    say "    -w --week    month by the week of the year [1, 53]";
    exit(1);
};

sub align {
    @_ == 2 or die q/Usage: align(string, width)/;
    my ($string, $width) = @_;
    return sprintf "%*s", ($width + length $string) / 2, $string;
}

say align($Moment->strftime('%B %Y'), 25);
say 'Wk  Mo Tu We Th Fr Sa Su';

my $this_month = $Moment;
my $next_month = $Moment->plus_months(1);
my $date       = $Moment->with_day_of_week(1);

while ($date->is_before($next_month)) {
    my @week = ($date->strftime('%V '), (('  ') x 7));
    foreach my $index (1..7) {
        if (!$date->is_before($this_month) && $date->is_before($next_month)) {
            $week[$index] = $date->strftime('%d');
        }
        $date = $date->plus_days(1);
    }
    say join ' ', @week;
}
