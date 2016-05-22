#!/usr/bin/perl
use strict;
use warnings;

use Time::Moment qw[];
use Time::HiRes  qw[];
use CBOR::XS     qw[encode_cbor];

sub filter {
    my ($tag) = @_;
    # http://www.iana.org/assignments/cbor-tags/cbor-tags.xhtml
    if    ($tag == 0) { return Time::Moment->from_string($_[1]) }
    elsif ($tag == 1) { return Time::Moment->from_epoch($_[1])  }
    else              { return &CBOR::XS::default_filter        }
}

my $encoded = encode_cbor([
    # Tag 0 is standard date/time string; see Section 2.4.1
    CBOR::XS::tag(0, '2013-12-24T12:30:45.123456789+01:00'),
    # Tag 1 is epoch-based date/time; see Section 2.4.1
    CBOR::XS::tag(1, time),
    CBOR::XS::tag(1, Time::HiRes::time),
    # Serializes as tag 0
    Time::Moment->now,
]);

my $decoded = CBOR::XS->new->filter(\&filter)->decode($encoded);
foreach my $moment (@$decoded) {
    print $moment->to_string, "\n";
}
