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
    my $offset = int($zone->offset_for_datetime($now) / 60);
    my $time   = $now->with_offset($offset);
    $name =~ s![^/]+/!!;
    $name =~ s!_!\x20!g;
    push @clocks, [$name, $time];
}

for my $clock (sort { $a->[1]->offset <=> $b->[1]->offset } @clocks) {
    my ($name, $time) = @$clock;
    my $diff = ($time->local_rd_as_seconds - $now->local_rd_as_seconds) / 60;
    printf "%-12s %-16s %s\n", $name, $time->strftime("%a %H:%M %Z"),
      $diff ? sprintf "(%+dm)", $diff : '';
}


