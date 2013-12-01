package Time::Moment;
use strict;
use warnings;

use Carp        qw[];
use Time::HiRes qw[];

BEGIN {
    our $VERSION = '0.05';
    require XSLoader; XSLoader::load(__PACKAGE__, $VERSION);
}

BEGIN {
    unless (exists &Time::Moment::now) {
        eval sprintf <<'EOC', __FILE__;
# line 17 %s

# expects normalized tm values; algorithm is only valid for tm year's [1, 199]
sub timegm {
    my ($y, $d, $h, $m, $s) = @_[5,7,2,1,0];
    return ((1461 * --$y >> 2) + $d - 25202) * 86400 + $h * 3600 + $m * 60 + $s;
}

sub now {
    @_ == 1 || Carp::croak(q/Usage: Time::Moment->now()/);
    my ($class) = @_;

    my ($sec, $usec) = Time::HiRes::gettimeofday();
    my $off = int((timegm(localtime($sec)) - $sec) / 60);
    return $class->from_epoch($sec, $usec, $off);
}
EOC
        Carp::croak($@) if $@;
    }
}

BEGIN {
    delete @Time::Moment::{qw(timegm)};
}

sub __as_DateTime {
    my ($tm) = @_;
    return DateTime->from_epoch(
        epoch     => $tm->epoch,
        time_zone => $tm->strftime('%Z'),
    )->set_nanosecond($tm->microsecond * 1000);
}

sub DateTime::__as_Time_Moment {
    my ($dt) = @_;

    (!$dt->time_zone->is_floating)
      or Carp::croak(q/Cannot coerce an instance of DateTime in the "floating" /
                    .q/time zone to an instance of Time::Moment/);

    my $usec = int($dt->nanosecond / 1000);
    my $off  = int($dt->offset / 60);
    return Time::Moment->from_epoch($dt->epoch, $usec, $off);
}

sub Time::Piece::__as_Time_Moment {
    my ($tp) = @_;
    return Time::Moment->from_epoch($tp->epoch, 0, int($tp->tzoffset / 60));
}

1;

