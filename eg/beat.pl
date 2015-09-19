#!/usr/bin/perl
use strict;
use warnings;

use Time::Moment;

# Converts the given moment to Swatch Internet Time (beat time).
# http://www.swatch.com/en/internet-time
# https://en.wikipedia.org/wiki/Swatch_Internet_Time
sub moment_to_beat {
    @_ == 1 or die q/Usage: moment_to_beat(moment)/;
    my ($tm) = @_;
    
    # Biel Meantime (BMT) is UTC+1
    my $rd = $tm->with_offset_same_instant(1*60)
                ->rd;
    return ($rd - int $rd) * 1E3;
}

my $tm = Time::Moment->now;
printf "@%3.3f\n", moment_to_beat($tm);
