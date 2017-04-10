#!perl
use strict;
use warnings;
use lib 't';

use Test::More;
use Util       qw[throws_ok lives_ok];

BEGIN {
    use_ok('Time::Moment');
}

{
    package MyFoo;

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
    package MyBar;

    sub new {
        my ($class, %p) = @_;
        return bless \%p, $class;
    }
}

{
    my $mf = MyFoo->new(epoch => 123456789);
    my $tm;

    lives_ok { $tm = Time::Moment->from_object($mf) };
    isa_ok($tm, 'Time::Moment');
    is($tm->epoch,  123456789, '->epoch');
    is($tm->offset, 0,         '->offset');
}

{
    my $mb = MyBar->new(epoch => 123456789);
    throws_ok { Time::Moment->from_object($mb) } q/^Cannot coerce object of type MyBar/;
}

done_testing();

