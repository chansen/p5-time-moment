#!/usr/bin/perl
use strict;
use warnings;

use Benchmark     qw[];
use DateTime      qw[];
use Time::Moment  qw[];
use Time::Piece   qw[];
use POSIX         qw[];

{
    print "Benchmarking constructor: ->now()\n";
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $dt = DateTime->now;
        },
        'Time::Moment' => sub {
            my $tm = Time::Moment->now;
        },
        'Time::Piece' => sub {
            my $tp = Time::Piece::localtime();
        },
        'localtime()' => sub {
            my @tm = localtime();
        },
    });
}

{
    print "\nBenchmarking constructor: ->from_epoch()\n";
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $dt = DateTime->from_epoch(epoch => 0);
        },
        'Time::Moment' => sub {
            my $tm = Time::Moment->from_epoch(0);
        },
        'Time::Piece' => sub {
            my $tp = Time::Piece::gmtime(0);
        },
    });
}

{
    print "\nBenchmarking accessor: ->year()\n";
    my $dt = DateTime->now;
    my $tm = Time::Moment->now;
    my $tp = Time::Piece::localtime();
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $year = $dt->year;
        },
        'Time::Moment' => sub {
            my $year = $tm->year;
        },
        'Time::Piece' => sub {
            my $year = $tp->year;
        },
    });
}

{
    print "\nBenchmarking strftime: ->strftime('%FT%T')\n";
    my $dt = DateTime->now;
    my $tm = Time::Moment->now;
    my $tp = Time::Piece::localtime();
    my @lt = localtime();
    Benchmark::cmpthese( -10, {
        'DateTime' => sub {
            my $string = $dt->strftime('%FT%T');
        },
        'Time::Moment' => sub {
            my $string = $tm->strftime('%FT%T');
        },
        'Time::Piece' => sub {
            my $string = $tp->strftime('%FT%T');
        },
        'POSIX::strftime' => sub {
            my $string = POSIX::strftime('%FT%T', @lt);
        },
    });
}

eval {
    require DateTime::Format::ISO8601;
    require DateTime::Format::RFC3339;

    my $string = '2013-12-24T12:34:56.123456+02:00';

    print "\nBenchmarking parsing: '$string'\n";
    my $rfc_p  = DateTime::Format::RFC3339->new;
    my $iso_p  = DateTime::Format::ISO8601->new;
    Benchmark::cmpthese( -10, {
        'Time::Moment' => sub {
            my $tm = Time::Moment->from_string($string);
        },
        'DT::F::ISO8601' => sub {
            my $dt = $iso_p->parse_datetime($string);
        },
        'DT::F::RFC3339' => sub {
            my $dt = $rfc_p->parse_datetime($string);
        },
    });
};

