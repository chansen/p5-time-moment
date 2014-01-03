#!perl
use strict;
use warnings;

use Test::More tests => 1;
use Config;

BEGIN {
    use_ok('Time::Moment');
}

my $extra = do {
    my $bool = ($Config{d_gettimeod} ? 'true' : 'false');
    "(HAS_GETTIMEOFDAY: $bool)";
};

diag("Time::Moment $Time::Moment::VERSION, Perl $], $^X $extra");

