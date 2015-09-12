#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm = Time::Moment->from_string('2012-12-24T12:30:45.123456789Z');
    my @exp = (
        '2012-12-24T12:30:45.123456789Z',
        '2012-12-24T12:30:45.123456780Z',
        '2012-12-24T12:30:45.123456700Z',
        '2012-12-24T12:30:45.123456Z',
        '2012-12-24T12:30:45.123450Z',
        '2012-12-24T12:30:45.123400Z',
        '2012-12-24T12:30:45.123Z',
        '2012-12-24T12:30:45.120Z',
        '2012-12-24T12:30:45.100Z',
        '2012-12-24T12:30:45Z',
        '2012-12-24T12:30:00Z',
        '2012-12-24T12:00:00Z',
        '2012-12-24T00:00:00Z',
    );

    for my $precision (-3..9) {
        my $got = $tm->with_precision($precision);
        is($got->to_string, $exp[9 - $precision], "->with_precision($precision)");
    }
}

done_testing();

