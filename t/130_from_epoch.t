#!perl
use strict;
use warnings;

use Test::More;
use t::Util    qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

my @tests = (
    [ -62135596800,         0, '0001-01-01T00:00:00Z'           ],
    [ -62135596800, 123456789, '0001-01-01T00:00:00.123456789Z' ],
    [ -62135596800, 123456000, '0001-01-01T00:00:00.123456Z'    ],
    [ -62135596800, 123000000, '0001-01-01T00:00:00.123Z'       ],
    [            0,         0, '1970-01-01T00:00:00Z'           ],
    [ 253402300799,         0, '9999-12-31T23:59:59Z'           ],
    [ 253402300799, 987654321, '9999-12-31T23:59:59.987654321Z' ],
    [ 253402300799, 987654000, '9999-12-31T23:59:59.987654Z'    ],
    [ 253402300799, 987000000, '9999-12-31T23:59:59.987Z'       ],
);

foreach my $test (@tests) {
    my ($secs, $nos, $string) = @$test;
    my $tm;
    lives_ok { $tm = Time::Moment->from_epoch($secs, $nos) } "from_epoch($secs, $nos)";
    is($tm->epoch,       $secs,   "from_epoch($secs, $nos)->epoch");
    is($tm->nanosecond,  $nos,    "from_epoch($secs, $nos)->nanosecond");
    is($tm->offset,      0,       "from_epoch($secs, $nos)->offset");
    is($tm->to_string,   $string, "from_epoch($secs, $nos)->to_string");
}

done_testing();

