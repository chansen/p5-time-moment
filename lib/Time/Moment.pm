package Time::Moment;
use strict;
use warnings;

use Carp        qw[];
use Time::HiRes qw[];

BEGIN {
    our $VERSION = '0.01';
    require XSLoader; XSLoader::load(__PACKAGE__, $VERSION);
}

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

sub leap_year {
    my ($y) = @_;
    return (($y & 3) == 0 && ($y % 100 != 0 || $y % 400 == 0));
}

sub days_in_month {
    my ($y, $m) = @_;
    return 29 if $m == 2 && leap_year($y);
    return (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[$m];
}

my @DayOffset = (0, 306, 337, 0, 31, 61, 92, 122, 153, 184, 214, 245, 275);

my $Rx = qr/
    \A
    ([0-9]{4}) - ([0-9]{2}) - ([0-9]{2})
    [T]
    ([0-9]{2}) : ([0-9]{2}) : ([0-9]{2}) (?: [.,] ([0-9]{1,6}) )?
    (?:
         [Z]
      | ([+-]) ([0-1][0-9]) : ([0-5][0-9])
    )
    \z
/x;

sub parse {
    return
      unless (defined $_[0])
          && (my ($Y, $M, $D, $h, $m, $s, $fs, $zs, $zh, $zm) = $_[0] =~ $Rx);
    return
      unless ($Y >= 1)
          && ($M >= 1 && $M <= 12)
          && ($D >= 1 && ($D <= 28 || $D <= days_in_month($Y, $M)))
          && ($h <= 23)
          && ($m <= 59)
          && ($s <= 59);

    my $usec = $fs ? $fs * (10 ** (6 - length $fs)) : 0;
    my $off  = $zs ? ($zs eq '-' ? -1 : 1) * ($zh * 60 + $zm) : 0;
    my $sec  = do {
        use integer;
        $Y-- if $M < 3;
        (1461 * $Y >> 2) - $Y/100 + $Y/400 + $DayOffset[$M] + $D - 719469;
    } * 86400 + $h * 3600 + $m * 60 + $s - $off * 60;

    return ($sec, $usec, $off);
}

sub from_string {
    @_ == 2 || Carp::croak(q/Usage: Time::Moment->from_string($string)/);
    my ($class, $string) = @_;

    my ($sec, $usec, $off) = parse($string)
      or Carp::croak(q/Cannot parse the given string/);

    return $class->from_epoch($sec, $usec, $off);
}

BEGIN {
    delete @Time::Moment::{qw(timegm parse leap_year days_in_month)};
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

sub __as_Time_Piece {
    my ($tm) = @_;
    return scalar Time::Piece::localtime($tm->epoch);
}

sub Time::Piece::__as_Time_Moment {
    my ($tp) = @_;
    return Time::Moment->from_epoch($tp->epoch, 0, int($tp->tzoffset / 60));
}

1;

