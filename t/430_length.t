#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm = Time::Moment->new(year => 2012);
    is($tm->length_of_year, 366, "length of year in a leap year is 366");
}

{
    my $tm = Time::Moment->new(year => 2013);
    is($tm->length_of_year, 365, "length of year in a common year is 365");
}

{
               #  Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
    my @lengths = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    my $year    = Time::Moment->new(year => 2012);
    my $month   = 1;
    foreach my $length (@lengths) {
        my $tm = $year->with_month($month++);
        is($tm->length_of_month, $length, "length of month $month is $length in a leap year");
    }
}

{
               #  Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
    my @lengths = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    my $year    = Time::Moment->new(year => 2013);
    my $month   = 1;
    foreach my $length (@lengths) {
        my $tm = $year->with_month($month++);
        is($tm->length_of_month, $length, "length of month $month is $length in a common year");
    }
}

{
                #  Q1  Q2  Q3  Q4
    my @lengths = (91, 91, 92, 92);
    my $year    = Time::Moment->new(year => 2012);
    my $quarter = 1;
    foreach my $length (@lengths) {
        my $tm = $year->with_month(3 * $quarter++);
        is($tm->length_of_quarter, $length, "length of quarter $quarter is $length in a leap year");
    }
}

{
                #  Q1  Q2  Q3  Q4
    my @lengths = (90, 91, 92, 92);
    my $year    = Time::Moment->new(year => 2013);
    my $quarter = 1;
    foreach my $length (@lengths) {
        my $tm = $year->with_month(3 * $quarter++);
        is($tm->length_of_quarter, $length, "length of quarter $quarter is $length in a common year");
    }
}

done_testing();
