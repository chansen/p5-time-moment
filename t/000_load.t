#!perl
use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok('Time::Moment');
}

diag("Time::Moment $Time::Moment::VERSION, Perl $], $^X");

