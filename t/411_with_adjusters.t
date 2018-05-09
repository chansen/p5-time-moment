#!perl
use Test::More;

BEGIN {
  use_ok('Time::Moment');
  use_ok('Time::Moment::Adjusters');
  Time::Moment::Adjusters->import('PreviousDayOfWeek');
}

my @name = ( undef, qw/Monday Tuesday Wednesday Thursday Friday Saturday Sunday/ );
my %weekday = (
    Monday    => 1,
    Tuesday   => 2,
    Wednesday => 3,
    Thursday  => 4,
    Friday    => 5,
    Saturday  => 6,
    Sunday    => 7,
);

my $a_monday = Time::Moment->new( year => 2018, month => 1, day => 1 );

# Diagonal
for my $offset ( 0 .. 6 ) {
    my $tm = $a_monday->plus_days( $offset );
    my $previous = $tm->with( PreviousDayOfWeek( $tm->day_of_week ) );
    is( $tm->delta_days($previous), -7,
        sprintf( 'PreviousDayOfWeek(%s) from %s is 7 days prior.',
                 $name[$tm->day_of_week],
                 $name[$tm->day_of_week] ) );
}

# Horizontal
for my $offset ( 0 .. 6 ) {
    my $tm = $a_monday;
    my $previous = $tm->with( PreviousDayOfWeek( 1 + $offset ) );
    is( $tm->delta_days( $previous ), $offset - 7,
        sprintf( 'PreviousDayOfWeek(%s) from %s is %d days prior.',
                 $name[1 + $offset],
                 $name[$tm->day_of_week],
                 abs($offset - 7) ) );
}

# Vertical
for my $offset ( 0 .. 6 ) {
    my $tm = $a_monday->plus_days( $offset + 1 );
    my $previous = $tm->with( PreviousDayOfWeek($weekday{Monday}) );
    is( $tm->delta_days( $previous ), -1 - $offset,
        sprintf( 'PreviousDayOfWeek(%s) from %s is %d days prior.',
                 $name[$weekday{Monday}],
                 $name[$tm->day_of_week],
                 abs(-1 - $offset) ) );
}

done_testing;
