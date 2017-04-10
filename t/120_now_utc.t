#!perl
use strict;
use warnings;
use lib 't';

use Test::More;
use Util       qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm;
    lives_ok { $tm = Time::Moment->now_utc };
    isa_ok($tm, 'Time::Moment');
    cmp_ok($tm->epoch,  '>',  0, "epoch");
    cmp_ok($tm->offset, '==', 0, "offset");

    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday)
      = gmtime($tm->epoch);

    $year += 1900;
    $yday += 1;
    $mon  += 1;
    $wday = 1 + ($wday + 6) % 7;

    is($tm->year,          $year,  '->year');
    is($tm->month,         $mon,   '->month');
    is($tm->day_of_year,   $yday,  '->day_of_year');
    is($tm->day_of_month,  $mday,  '->day_of_month');
    is($tm->day_of_week,   $wday,  '->day_of_week');
    is($tm->hour,          $hour,  '->hour');
    is($tm->minute,        $min,   '->minute');
    is($tm->second,        $sec,   '->second');
}

done_testing();

