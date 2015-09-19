#!/usr/bin/perl
use strict;
use warnings;

use Time::Moment;

my $tm = Time::Moment->now;

sub output {
    my ($type, $basic, $extended) = @_;

    print "\nCombinations of $type date and time of day:\n";

    print "\nBasic format:          Example:\n";
    foreach my $format (@$basic) {
        printf "%-22s %s\n", $format, $tm->strftime($format);
    }

    print "\nExtended format:       Example:\n";
    foreach my $format (@$extended) {
        printf "%-22s %s\n", $format, $tm->strftime($format);
    }
}

{
    my @basic = qw(
        %Y%m%dT%H%M%S%z
        %Y%m%dT%H%M%S%f%z
        %Y%m%dT%H%M%z
    );
    my @extended = qw(
        %Y-%m-%dT%H:%M:%S%Z
        %Y-%m-%dT%H:%M:%S%f%Z
        %Y-%m-%dT%H:%M%Z
    );
    output('calendar', \@basic, \@extended);
}

{
    my @basic = qw(
        %Y%jT%H%M%S%z
        %Y%jT%H%M%S%f%z
        %Y%jT%H%M%z
    );
    my @extended = qw(
        %Y-%jT%H:%M:%S%Z
        %Y-%jT%H:%M:%S%f%Z
        %Y-%jT%H:%M%Z
    );
    output('ordinal', \@basic, \@extended);
}

{
    my @basic = qw(
        %GW%V%uT%H%M%S%z
        %GW%V%uT%H%M%S%f%z
        %GW%V%uT%H%M%z
    );
    my @extended = qw(
        %G-W%V-%uT%H:%M:%S%Z
        %G-W%V-%uT%H:%M:%S%f%Z
        %G-W%V-%uT%H:%M%Z
    );
    output('week', \@basic, \@extended);
}
