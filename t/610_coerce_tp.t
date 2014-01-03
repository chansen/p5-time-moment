#!perl
use strict;
use warnings;

use Test::More;
use Test::Requires qw[Params::Coerce Time::Piece];
use t::Util        qw[lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tp = Time::Piece::gmtime(123456789);
    my $tm;

    lives_ok { $tm = Params::Coerce::coerce('Time::Moment', $tp) };
    isa_ok($tm, 'Time::Moment');
    is($tm->epoch, 123456789, '->epoch');
}

done_testing();

