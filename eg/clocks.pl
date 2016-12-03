#!/usr/bin/perl
use strict;
use warnings;

use Time::Moment;
use DateTime::TimeZone;

my @zones = qw(
    Africa/Cairo
    America/Chicago
    America/Los_Angeles
    America/New_York
    Asia/Dubai
    Asia/Hong_Kong
    Asia/Kathmandu
    Asia/Tokyo
    Australia/Sydney
    Europe/Brussels
    Europe/London
    Europe/Moscow
    Europe/Paris
    Europe/Stockholm
    Pacific/Apia
);

my $now = Time::Moment->now;
my @clocks;
foreach my $name (@zones) {
    my $zone   = DateTime::TimeZone->new(name => $name);
    my $offset = $zone->offset_for_datetime($now) / 60;
    my $time   = $now->with_offset_same_instant($offset);
    $name =~ s![^/]+/!!;
    $name =~ s!_!\x20!g;
    push @clocks, [$name, $time];
}

@clocks = sort { 
       $a->[1]->offset <=> $b->[1]->offset 
    or $a->[0]         cmp $b->[0]
} @clocks;

for my $clock (@clocks) {
    my ($name, $time) = @$clock;
    my $delta = $time->offset - $now->offset;
    printf "%-12s %-16s (%+.2d:%.2d)\n",
      $name, $time->strftime("%a %H:%M %:z"), $delta / 60, abs($delta) % 60;
}
