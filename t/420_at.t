#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm = Time::Moment->from_string('2012-12-24T12:30:45.123456789Z');
    is($tm->at_noon,     '2012-12-24T12:00:00Z',           '->at_noon');
    is($tm->at_midnight, '2012-12-24T00:00:00Z',           '->at_midnight');
    is($tm->at_utc,      '2012-12-24T12:30:45.123456789Z', '->at_utc');
}

{
    my $tm = Time::Moment->from_string('2012-12-24T12:30:45.123456789+02:00');
    is($tm->at_noon,     '2012-12-24T12:00:00+02:00',      '->at_noon');
    is($tm->at_midnight, '2012-12-24T00:00:00+02:00',      '->at_midnight');
    is($tm->at_utc,      '2012-12-24T10:30:45.123456789Z', '->at_utc');
}

{
    my $tm = Time::Moment->from_string('2012-12-24T12:30:45.123456789-02:00');
    is($tm->at_noon,     '2012-12-24T12:00:00-02:00',      '->at_noon');
    is($tm->at_midnight, '2012-12-24T00:00:00-02:00',      '->at_midnight');
    is($tm->at_utc,      '2012-12-24T14:30:45.123456789Z', '->at_utc');
}


{
    my $tm = Time::Moment->new(year => 2012);
    my $exp = $tm->with_day_of_year(366);
    my $got = $tm->at_last_day_of_year;
    is($got, $exp, "->at_last_day_of_year (leap year)");
}

{
    my $tm = Time::Moment->new(year => 2013);
    my $exp = $tm->with_day_of_year(365);
    my $got = $tm->at_last_day_of_year;
    is($got, $exp, "->at_last_day_of_year (common year)");
}

{
               #  Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
    my @months = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    my $year   = Time::Moment->new(year => 2012);
    my $month  = 0;
    foreach my $day (@months) {
        ++$month;
        my $exp = $year->with_month($month)
                       ->with_day_of_month($day);
        my $got = $year->with_month($month)
                       ->at_last_day_of_month;
        is($got, $exp, "->at_last_day_of_month (leap year)");
    }
}

{
               #  Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
    my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    my $year   = Time::Moment->new(year => 2013);
    my $month  = 0;
    foreach my $day (@months) {
        ++$month;
        my $exp = $year->with_month($month)
                       ->with_day_of_month($day);
        my $got = $year->with_month($month)
                       ->at_last_day_of_month;
        is($got, $exp, "->at_last_day_of_month (common year)");
    }
}

{
                 #  Q1  Q2  Q3  Q4
    my @quarters = (91, 91, 92, 92);
    my $year     = Time::Moment->new(year => 2012);
    my $quarter  = 0;
    foreach my $day (@quarters) {
        ++$quarter;
        my $exp = $year->with_month(3 * $quarter)
                       ->with_day_of_quarter($day);
        my $got = $year->with_month(3 * $quarter)
                       ->at_last_day_of_quarter;
        is($got, $exp, "->at_last_day_of_quarter (leap year)");
    }
}

{
                 #  Q1  Q2  Q3  Q4
    my @quarters = (90, 91, 92, 92);
    my $year     = Time::Moment->new(year => 2013);
    my $quarter  = 0;
    foreach my $day (@quarters) {
        ++$quarter;
        my $exp = $year->with_month(3 * $quarter)
                       ->with_day_of_quarter($day);
        my $got = $year->with_month(3 * $quarter)
                       ->at_last_day_of_quarter;
        is($got, $exp, "->at_last_day_of_quarter (common year)");
    }
}

{
    my $tm = Time::Moment->from_string('2012-12-24T12:30:45.123+02:00');
    is($tm->at_last_day_of_year,    '2012-12-31T12:30:45.123+02:00', '->at_last_day_of_year');
    is($tm->at_last_day_of_quarter, '2012-12-31T12:30:45.123+02:00', '->at_last_day_of_quarter');
    is($tm->at_last_day_of_month,   '2012-12-31T12:30:45.123+02:00', '->at_last_day_of_month');
}

{
    my $tm = Time::Moment->from_string('2012-01-24T12:30:45.123-02:00');
    is($tm->at_last_day_of_year,    '2012-12-31T12:30:45.123-02:00', '->at_last_day_of_year');
    is($tm->at_last_day_of_quarter, '2012-03-31T12:30:45.123-02:00', '->at_last_day_of_quarter');
    is($tm->at_last_day_of_month,   '2012-01-31T12:30:45.123-02:00', '->at_last_day_of_month');
}

{
    my $tm = Time::Moment->from_string('2012-07-24T12:30:45.123Z');
    is($tm->at_last_day_of_year,    '2012-12-31T12:30:45.123Z', '->at_last_day_of_year');
    is($tm->at_last_day_of_quarter, '2012-09-30T12:30:45.123Z', '->at_last_day_of_quarter');
    is($tm->at_last_day_of_month,   '2012-07-31T12:30:45.123Z', '->at_last_day_of_month');
}

done_testing();

