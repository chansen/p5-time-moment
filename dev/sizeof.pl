#!/usr/bin/perl
use strict;
use warnings;

use DateTime      qw[];
use Time::Moment  qw[];
use Time::Piece   qw[];

use Devel::Size   qw[total_size];
use Storable      qw[nfreeze];

my $tm = Time::Moment->now;
my $tp = Time::Piece::localtime();
my $dt = DateTime->now;
my $lt = [localtime()];

print  "Comparing instance size:\n";
printf "Time::Moment ............... : %4d B\n", total_size($tm);
printf "Time::Piece ................ : %4d B\n", total_size($tp);
printf "localtime() ................ : %4d B\n", total_size($lt) - total_size([]);
printf "DateTime ................... : %4d B\n", total_size($dt);
printf "DateTime w/o zone and locale : %4d B\n", total_size do {
    my $clone = $dt->clone;
    delete @{$clone}{qw(time_zone locale)}; $clone;
};

print  "\nComparing Storable::nfreeze() size:\n";
printf "Time::Moment ............... : %4d B\n", length nfreeze $tm;
printf "DateTime ................... : %4d B\n", length nfreeze $dt;

