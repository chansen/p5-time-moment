#!perl
use strict;
use warnings;
use lib 't';

use Test::More;
use Test::Requires qw[JSON::XS];
use Util           qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my ($tm, $json, $serialized);

    $json = JSON::XS->new->convert_blessed;
    $tm   = Time::Moment->from_string("2012-12-24T15:30:45.123456789+01:00");
    lives_ok { $serialized = $json->encode([$tm]) } '$json->encode()';
    ok(index($serialized, '2012-12-24T15:30:45.123456789+01:00') != -1, "serialized contains timestamp");
}

done_testing();

