#!/usr/bin/perl
use strict;
use warnings;
use v5.10;

use Getopt::Long qw[];
use Time::Moment qw[];

my $FirstDayOfWeek = 1; # Monday
my $Moment         = Time::Moment->now
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
    'f|first=i' => sub {
        my ($name, $day) = @_;

        ($day >= 1 && $day <= 7)
          or die qq/Option '$name' is out of the range [1=Monday, 7=Sunday]\n/;

        $FirstDayOfWeek = $day;
    },
) or do {
    say "usage: $0 [-y year] [-m month] [-f day]";
    say "    -y --year    the year [1, 9999]";
    say "    -m --month   the month of the year [1=January, 12=December]";
    say "    -f --first   the first day of the week [1=Monday, 7=Sunday]";
    exit(1);
};

sub align {
    @_ == 2 or die q/Usage: align(string, width)/;
    my ($string, $width) = @_;
    return sprintf "%*s", ($width + length $string) / 2, $string;
}

say align($Moment->strftime('%B %Y'), 20);
say join ' ', map {
    (qw[ Mo Tu We Th Fr Sa Su ])[ ($_ + $FirstDayOfWeek - 1) % 7 ]
} (0..6);

my $this_month = $Moment;
my $next_month = $Moment->plus_months(1);
my $date       = $Moment->minus_weeks($FirstDayOfWeek > $Moment->day_of_week)
                        ->with_day_of_week($FirstDayOfWeek);

while ($date->is_before($next_month)) {
    my @week;
    foreach my $day (1..7) {
        if ($date->is_before($this_month)) {
            push @week, '  ';
        }
        elsif ($date->is_before($next_month)) {
            push @week, sprintf '%2d', $date->day_of_month;
        }
        $date = $date->plus_days(1);
    }
    say join ' ', @week;
}
