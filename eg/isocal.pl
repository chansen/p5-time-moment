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

        # Select the calendar month corresponding to a given ISO week ($week)
        # within a calendar year.
        #
        # Important distinction:
        # - Calendar year: January 1 to December 31; used when referring to months.
        # - ISO week-year: defined by ISO-8601 week numbering; it may begin in late
        #   December of the previous calendar year or extend into early January of
        #   the next calendar year.
        #
        # Key ISO rule:
        #   ISO week 1 is the week that contains January 4. Therefore, the ISO
        #   week-year associated with a calendar year is the one whose week 1
        #   includes January 4 of that year.
        #
        # Therefore:
        # 1) Set the date to January 4 of the calendar year to ensure we are within
        #    the correct ISO week-year.
        # 2) Select the requested ISO week number within that ISO week-year.
        # 3) Move to Monday of that ISO week, since ISO weeks start on Monday. 
        #    Anchoring the date to Monday ensures we stay at the start of the 
        #    ISO week, rather than on a later weekday that could fall in January 
        #    of the next calendar year.
        # 4) Force the date to the first day of its month to identify the
        #    corresponding calendar month.
        $Moment = $Moment->with_month(1)
                         ->with_day_of_month(4)
                         ->with_week($week)
                         ->with_day_of_week(1)
                         ->with_day_of_month(1);

        # Corner case handling:
        # ISO week 1 can start in late December of the previous calendar year.
        # If setting the day to the 1st put us back into the previous year,
        # move forward one month to bring the date back into the intended 
        # calendar year.
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

say align($Moment->strftime('%B %Y'), 24);
say 'Wk Mo Tu We Th Fr Sa Su';

my $this_month = $Moment;
my $next_month = $Moment->plus_months(1);
my $date       = $Moment->with_day_of_week(1);

while ($date->is_before($next_month)) {
    my @week = (sprintf('%.2d', $date->week), (('  ') x 7));
    foreach my $index (1..7) {
        if (!$date->is_before($this_month) && $date->is_before($next_month)) {
            $week[$index] = sprintf '%2d', $date->day_of_month;
        }
        $date = $date->plus_days(1);
    }
    say join ' ', @week;
}
