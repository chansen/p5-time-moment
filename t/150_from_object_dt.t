#!perl
use strict;
use warnings;
use lib 't';

use Test::More;
use Test::Requires qw[DateTime];
use Util           qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    my $dt = DateTime->from_epoch(epoch => 123456789);
    my $tm;

    lives_ok { $tm = Time::Moment->from_object($dt) };
    isa_ok($tm, 'Time::Moment');
    is($tm->epoch,  123456789, '->epoch');
    is($tm->offset,         0, '->offset');
}

{
    my $dt = DateTime->from_epoch(epoch => 123456789, time_zone => '+02:00');
    my $tm;

    lives_ok { $tm = Time::Moment->from_object($dt) };
    isa_ok($tm, 'Time::Moment');
    is($tm->epoch,         123456789,         '->epoch');
    is($tm->offset,        2*60,              '->offset');
    is($tm->year,          $dt->year,         '->year');
    is($tm->month,         $dt->month,        '->month');
    is($tm->day_of_month,  $dt->day_of_month, '->day_of_month');
    is($tm->hour,          $dt->hour,         '->hour');
    is($tm->minute,        $dt->minute,       '->minute');
    is($tm->second,        $dt->second,       '->second');
}

{
    my $dt = DateTime->new(year => 2012);
    throws_ok { Time::Moment->from_object($dt) } qr/^Cannot coerce .* 'floating'/;
}

done_testing();

