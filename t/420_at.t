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

