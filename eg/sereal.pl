#!/usr/bin/perl
use strict;
use warnings;

use Time::Moment qw[];
use Sereal       2.030 qw[encode_sereal decode_sereal];

my @moments = (Time::Moment->now, Time::Moment->now_utc);
my $encoded = encode_sereal([ @moments ], { freeze_callbacks => 1 });
my $decoded = decode_sereal($encoded);

foreach my $moment (@$decoded) {
    print $moment->to_string, "\n";
}
