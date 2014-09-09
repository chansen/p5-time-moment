#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

# Test cases for issue #7
# https://github.com/chansen/p5-time-moment/issues/7

{
    package MyObject;

    sub new {
        @_ == 2 || die;
        my ($class, $moment) = @_;
        return bless { moment => $moment }, $class;
    }

    sub moment {
        return $_[0]->{moment};
    }
}

{
    my $tm1 = Time::Moment->from_string('0001-01-01T00:00:00Z');
    my $obj = MyObject->new($tm1);
    my $tm2 = $obj->moment->plus_seconds(1);
    
    is($tm1, '0001-01-01T00:00:00Z', '$tm1');
    is($tm2, '0001-01-01T00:00:01Z', '$tm2');
}

{
    my $tm      = Time::Moment->from_string('0001-01-01T00:00:00Z');
    my @moments = map { sub { $tm }->()->plus_seconds($_) } (0..3);
    
    is($moments[0], '0001-01-01T00:00:00Z', '$moments[0]');
    is($moments[1], '0001-01-01T00:00:01Z', '$moments[1]');
    is($moments[2], '0001-01-01T00:00:02Z', '$moments[2]');
    is($moments[3], '0001-01-01T00:00:03Z', '$moments[4]');
}

done_testing();

