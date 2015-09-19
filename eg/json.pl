#!/usr/bin/perl
use strict;
use warnings;

use Time::Moment qw[];
use JSON::XS     qw[];

print JSON::XS->new->convert_blessed->encode([ Time::Moment->now ]), "\n";
