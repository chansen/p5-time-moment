#!perl
use strict;
use warnings;
use lib 't';

use Test::More;
use Test::Requires { 'CBOR::XS' => '1.25' };
use Util           qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my ($tm, $encoded, $decoded);

    $tm = Time::Moment->from_string("2012-12-24T15:30:45.123456789+01:00");
    lives_ok { 
        $encoded = CBOR::XS::encode_cbor([$tm]) 
    } 'encode_cbor()';

    lives_ok {
        $decoded = CBOR::XS->new->filter(sub { return $_[1] })->decode($encoded);
    } '$cbor->decode()';

    is_deeply($decoded, ['2012-12-24T15:30:45.123456789+01:00'], 'decoded values');
}

done_testing();

