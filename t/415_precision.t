#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm = Time::Moment->from_string('2012-12-24T12:30:45.123456789Z');
    my @tests = (
        [  9, '2012-12-24T12:30:45.123456789Z' ],
        [  9, '2012-12-24T12:30:45.123456780Z' ],
        [  9, '2012-12-24T12:30:45.123456700Z' ],
        [  6, '2012-12-24T12:30:45.123456Z'    ],
        [  6, '2012-12-24T12:30:45.123450Z'    ],
        [  6, '2012-12-24T12:30:45.123400Z'    ],
        [  3, '2012-12-24T12:30:45.123Z'       ],
        [  3, '2012-12-24T12:30:45.120Z'       ],
        [  3, '2012-12-24T12:30:45.100Z'       ],
        [  0, '2012-12-24T12:30:45Z'           ],
        [ -1, '2012-12-24T12:30:00Z'           ],
        [ -2, '2012-12-24T12:00:00Z'           ],
        [ -3, '2012-12-24T00:00:00Z'           ],
    );

    for my $precision (-3..9) {
        my $test = $tests[9 - $precision];
        my $got = $tm->with_precision($precision);
        is($got->to_string, $test->[1], "->with_precision($precision)");
        is($got->precision, $test->[0], "$got->precision");
    }
}

done_testing();

