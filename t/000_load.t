#!perl
use strict;
use warnings;

use Test::More tests => 1;
use Config;

BEGIN {
    use_ok('Time::Moment');
}

my @has = qw(d_gettimeod d_localtime_r);
foreach my $var (@has) {
    $var .= '=' . ($Config{$var} ? 'true' : 'false')
}

diag("Time::Moment $Time::Moment::VERSION, Perl $], $^X (@has)");

