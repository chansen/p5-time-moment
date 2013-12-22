#!perl
use strict;
use warnings;

use Test::More;
use t::Util    qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm;
    lives_ok { $tm = Time::Moment->now };
    isa_ok($tm, 'Time::Moment');
    cmp_ok($tm->epoch, '>', 0, "epoch");
}

done_testing();

