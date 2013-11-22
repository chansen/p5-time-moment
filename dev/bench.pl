#!/usr/bin/perl
use strict;
use warnings;

use Benchmark     qw[];
use DateTime      qw[];
use Time::Moment  qw[];

{
    print "Benchmarking constructor: ->now()\n";
    Benchmark::cmpthese( -10, {
        'Time::Moment' => sub {
            my $tm = Time::Moment->now;
        },
        'DateTime' => sub {
            my $dt = DateTime->now;
        },
    });
}

{
    print "\nBenchmarking constructor: ->from_epoch()\n";
    Benchmark::cmpthese( -10, {
        'Time::Moment' => sub {
            my $tm = Time::Moment->from_epoch(0);
        },
        'DateTime' => sub {
            my $dt = DateTime->from_epoch(epoch => 0);
        },
    });
}

{
    print "\nBenchmarking accessor: ->year()\n";
    my $tm = Time::Moment->now;
    my $dt = DateTime->now;
    Benchmark::cmpthese( -10, {
        'Time::Moment' => sub {
            my $year = $tm->year;
        },
        'DateTime' => sub {
            my $year = $dt->year;
        },
    });
}

{
    print "\nBenchmarking strftime: ->strftime('%FT%T%z')\n";
    my $tm = Time::Moment->now;
    my $dt = DateTime->now;
    Benchmark::cmpthese( -10, {
        'Time::Moment' => sub {
            my $string = $tm->strftime('%FT%T%z');
        },
        'DateTime' => sub {
            my $string = $dt->strftime('%FT%T%z');
        },
    });
}

eval {
    require DateTime::Format::RFC3339;

    print "\nBenchmarking parsing\n";
    my $p = DateTime::Format::RFC3339->new;
    my $ts = '1970-01-01T02:00:00.123456+02:00';
    Benchmark::cmpthese( -10, {
        'Time::Moment' => sub {
            my $tm = Time::Moment->from_string($ts);
        },
        'DateTime' => sub {
            my $dt = $p->parse_datetime($ts);
        },
    });
};

