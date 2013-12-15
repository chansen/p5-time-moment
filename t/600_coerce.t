#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    package MyTime;

    sub new {
        my ($class, %p) = @_;
        return bless \%p, $class;
    }

    sub epoch { return $_[0]->{epoch} }

    sub __as_Time_Moment {
        my ($self) = @_;
        return Time::Moment->from_epoch($self->epoch);
    }
}

{
    my $object = MyTime->new(
        epoch => 123456789,
    );

    my $tm = Time::Moment->from_object($object);
    isa_ok($tm, 'Time::Moment');
    is($tm->epoch, 123456789, '->epoch');
}

done_testing();

