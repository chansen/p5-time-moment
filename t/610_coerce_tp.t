#!perl
use strict;
use warnings;
use lib 't';

use Test::More;
use Test::Requires qw[Params::Coerce Time::Piece];
use Util           qw[lives_ok];

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

{
    my $tm = Time::Moment->from_epoch(123456789);
    my $tp;

    lives_ok { $tp = Params::Coerce::coerce('Time::Piece', $tm) };
    isa_ok($tp, 'Time::Piece');
    is($tp->epoch, 123456789, '->epoch');
}

done_testing();

