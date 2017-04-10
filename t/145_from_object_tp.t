#!perl
use strict;
use warnings;
use lib 't';

use Test::More;
use Test::Requires qw[Time::Piece];
use Util           qw[lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tp = Time::Piece::gmtime(123456789);
    my $tm;

    lives_ok { $tm = Time::Moment->from_object($tp) };
    isa_ok($tm, 'Time::Moment');
    is($tm->epoch,  123456789, '->epoch');
    is($tm->offset,         0, '->offset');
}

{
    my $tp = Time::Piece::localtime(123456789);
    my $tm;

    lives_ok { $tm = Time::Moment->from_object($tp) };
    isa_ok($tm, 'Time::Moment');
    is($tm->epoch,         123456789,         '->epoch');
    is($tm->year,          $tp->year,         '->year');
    is($tm->month,         $tp->mon,          '->month');
    is($tm->day_of_month,  $tp->day_of_month, '->day_of_month');
    is($tm->hour,          $tp->hour,         '->hour');
    is($tm->minute,        $tp->minute,       '->minute');
    is($tm->second,        $tp->second,       '->second');
}

done_testing();

