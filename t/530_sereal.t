#!perl
use strict;
use warnings;
use lib 't';

use Test::More;
use Test::Requires { Sereal => '2.060' };
use Util           qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my ($tm, $encoded, $decoded);
    
    my @moments = map { 
        Time::Moment->from_string($_) 
    } qw[2012-12-24T15:30:45.123456789+01:00 
         2012-12-24T15:30:45.987654321+01:00];

    lives_ok { 
        $encoded = Sereal::encode_sereal([@moments], { freeze_callbacks => 1 })
    } 'Sereal::encode_sereal()';
    
    lives_ok {
        $decoded = Sereal::decode_sereal($encoded);
    } 'Sereal::decode_sereal()';
    
    isa_ok($decoded, 'ARRAY');
    is(scalar @$decoded, 2, 'ARRAY has two elements');
    isa_ok($decoded->[0], 'Time::Moment', 'first element');
    isa_ok($decoded->[1], 'Time::Moment', 'second element');
    is($decoded->[0]->to_string, $moments[0]->to_string, 'first element has right time');
    is($decoded->[1]->to_string, $moments[1]->to_string, 'second element has right time');
}

done_testing();

