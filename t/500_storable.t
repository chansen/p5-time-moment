#!perl
use strict;
use warnings;
use lib 't';

use Test::More;
use Test::Requires qw[Storable];
use Util           qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my ($tm, $freezed, $thawed);

    $tm = Time::Moment->from_string("2012-12-24T15:30:45.123456789+01:00");
    lives_ok { $freezed = Storable::nfreeze($tm)   } 'Storable::nfreeze()';
    lives_ok { $thawed  = Storable::thaw($freezed) } 'Storable::thaw()';
    isa_ok($thawed, 'Time::Moment');
    is($thawed, '2012-12-24T15:30:45.123456789+01:00');
}

{
    my ($tm, $freezed, $thawed);

    $tm = Time::Moment->from_string("2012-12-24T15:30:45.123456789-01:00");
    lives_ok { $freezed = Storable::nfreeze($tm)   } 'Storable::nfreeze()';
    lives_ok { $thawed  = Storable::thaw($freezed) } 'Storable::thaw()';
    isa_ok($thawed, 'Time::Moment');
    is($thawed, '2012-12-24T15:30:45.123456789-01:00');
}

{
    my ($tm, $cloned);

    $tm = Time::Moment->from_string("2012-12-24T15:30:45.123456789+01:00");
    lives_ok { $cloned = Storable::dclone($tm) } 'Storable::dclone()';
    isa_ok($cloned, 'Time::Moment');
    is($cloned, '2012-12-24T15:30:45.123456789+01:00');
}

done_testing();

