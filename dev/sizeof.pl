#!/usr/bin/perl
use strict;
use warnings;

use DateTime      qw[];
use Time::Moment  qw[];
use Time::Piece   qw[];

use Devel::Size   qw[total_size];

my $tm = Time::Moment->now;
my $tp = Time::Piece::localtime();
my $dt = DateTime->now;
my $lt = [localtime()];

printf "Time::Moment ............... : %4d B\n", total_size($tm);
printf "Time::Piece ................ : %4d B\n", total_size($tp);
printf "localtime() ................ : %4d B\n", total_size($lt) - total_size([]);
printf "DateTime ................... : %4d B\n", total_size($dt);
printf "DateTime w/o zone and locale : %4d B\n", total_size do {
    delete @{$dt}{qw(time_zone locale)}; $dt;
};

