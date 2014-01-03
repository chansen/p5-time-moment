#!perl
use strict;
use warnings;

use Test::More;
use Test::Requires qw[Params::Coerce DateTime];
use t::Util        qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my $dt = DateTime->from_epoch(epoch => 123456789);
    my $tm;

    lives_ok { $tm = Params::Coerce::coerce('Time::Moment', $dt) };
    isa_ok($tm, 'Time::Moment');
    is($tm->epoch, 123456789, '->epoch');
}

{
    my $dt = DateTime->new(year => 2012);
    throws_ok { 
        Params::Coerce::coerce('Time::Moment', $dt) 
    } qr/^Cannot coerce .* 'floating'/;
}

{
    my $tm = Time::Moment->from_epoch(123456789);
    my $dt;

    lives_ok { $dt = Params::Coerce::coerce('DateTime', $tm) };
    isa_ok($dt, 'DateTime');
    is($dt->epoch, 123456789, '->epoch');
}

done_testing();

