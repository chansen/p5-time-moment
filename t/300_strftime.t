#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my @tests = (
        # Combinations of calendar date and time of day
        [ '%Y%m%dT%H%M%S%z',        '20121224T153045+0100'          ],
        [ '%Y%m%dT%H%M%S%f%z',      '20121224T153045.500+0100'      ],
        [ '%Y%m%dT%H%M%z',          '20121224T1530+0100'            ],
        [ '%Y-%m-%dT%H:%M:%S%Z',    '2012-12-24T15:30:45+01:00'     ],
        [ '%Y-%m-%dT%H:%M:%S%f%Z',  '2012-12-24T15:30:45.500+01:00' ],
        [ '%Y-%m-%dT%H:%M%Z',       '2012-12-24T15:30+01:00'        ],

        # Combinations of ordinal date and time of day
        [ '%Y%jT%H%M%S%z',          '2012359T153045+0100'           ],
        [ '%Y%jT%H%M%S%f%z',        '2012359T153045.500+0100'       ],
        [ '%Y%jT%H%M%z',            '2012359T1530+0100'             ],
        [ '%Y-%jT%H:%M:%S%Z',       '2012-359T15:30:45+01:00',      ],
        [ '%Y-%jT%H:%M:%S%f%Z',     '2012-359T15:30:45.500+01:00'   ],
        [ '%Y-%jT%H:%M%Z',          '2012-359T15:30+01:00'          ],

        # Combinations of week date and time of day
        [ '%GW%V%uT%H%M%S%z',       '2012W521T153045+0100'          ],
        [ '%GW%V%uT%H%M%S%f%z',     '2012W521T153045.500+0100'      ],
        [ '%GW%V%uT%H%M%f%z',       '2012W521T1530+0100'            ],
        [ '%G-W%V-%uT%H:%M:%S%Z',   '2012-W52-1T15:30:45+01:00'     ],
        [ '%G-W%V-%uT%H:%M:%S%f%Z', '2012-W52-1T15:30:45.500+01:00' ],
        [ '%G-W%V-%uT%H:%M%Z',      '2012-W52-1T15:30+01:00'        ],
    );

    foreach my $test (@tests) {
        my ($format, $string) = @$test;
        my $tm = Time::Moment->from_string($string);
        is($tm->strftime($format), $string, "$string '$format'");
    }
}

{
    my $string = '0001-01-01T01:01:01Z';
    my $tm     = Time::Moment->from_string($string);
    my @single = (
        # Years
        [ '0001', [ qw( Y 0Y G 0G             ) ] ],
        [ '   1', [ qw( _Y _G                 ) ] ],
        [ '1',    [ qw( -Y -G                 ) ] ],
        [ '01',   [ qw( y 0y g 0g             ) ] ],
        [ ' 1',   [ qw( _y _g                 ) ] ],
        [ '1',    [ qw( -y -g                 ) ] ],

        [ '00',   [ qw( C 0C                  ) ] ],
        [ ' 0',   [ qw( _C                    ) ] ],
        [ '0',    [ qw( -C                    ) ] ],

        # Month of year
        [ '01',   [ qw( m 0m                  ) ] ],
        [ ' 1',   [ qw( _m                    ) ] ],
        [ '1',    [ qw( -m                    ) ] ],

        # Week numbers
        [ '01',   [ qw( V 0V W 0W             ) ] ],
        [ ' 1',   [ qw( _V _W                 ) ] ],
        [ '1',    [ qw( -V -W                 ) ] ],
        [ '00',   [ qw( U 0U                  ) ] ],
        [ ' 0',   [ qw( _U                    ) ] ],
        [ '0',    [ qw( -U                    ) ] ],

        # Day of month
        [ '01',   [ qw( d 0d 0e               ) ] ],
        [ ' 1',   [ qw( _d e _e               ) ] ],
        [ '1',    [ qw( -d -e                 ) ] ],

        # Day of year
        [ '001',  [ qw( j 0j                  ) ] ],
        [ '  1',  [ qw( _j                    ) ] ],
        [ '1',    [ qw( -j                    ) ] ],

        # Day of week
        [ '1',    [ qw( u w                   ) ] ],

        # Time components
        [ '01',   [ qw( H 0H M 0M S 0S 0k     ) ] ],
        [ ' 1',   [ qw( _H _M _S _k           ) ] ],
        [ '1',    [ qw( -H -M -S -k           ) ] ],
        [ '01',   [ qw( I 0I 0l               ) ] ],
        [ ' 1',   [ qw( l _l _I               ) ] ],
        [ '1',    [ qw( -l -I                 ) ] ],
    );

    foreach my $test (@single) {
        my ($exp, @specifiers) = ($test->[0], @{$test->[1]});
        foreach my $specifier (@specifiers) {
            is($tm->strftime("%${specifier}"), $exp, "$string '%${specifier}'");
        }
    }

    my @combined = (
        [ 'c', 'Mon Jan  1 01:01:01 0001'   ],
        [ 'D', '01/01/01'                   ],
        [ 'F', '0001-01-01'                 ],
        [ 'r', '01:01:01 AM'                ],
        [ 'R', '01:01'                      ],
        [ 'T', '01:01:01'                   ],
        [ 'X', '01:01:01'                   ],
        [ 'x', '01/01/01'                   ],
    );

    foreach my $test (@combined) {
        my ($specifier, $exp) = @$test;
        is($tm->strftime("%${specifier}"), $exp, "$string '%${specifier}'");
    }
}

{
    my $string = '9999-12-31T23:59:59Z';
    my $tm     = Time::Moment->from_string($string);
    my @single = (
        # Years
        [ '9999', [ qw( Y 0Y G 0G             ) ] ],
        [ '9999', [ qw( _Y _G                 ) ] ],
        [ '9999', [ qw( -Y -G                 ) ] ],
        [ '99',   [ qw( y 0y g 0g             ) ] ],
        [ '99',   [ qw( _y _g                 ) ] ],
        [ '99',   [ qw( -y -g                 ) ] ],

        [ '99',   [ qw( C 0C _C -C            ) ] ],

        # Month of year
        [ '12',   [ qw( m 0m _m -m            ) ] ],

        # Week numbers
        [ '52',   [ qw( V 0V W 0W U 0U        ) ] ],
        [ '52',   [ qw( _V _W _U              ) ] ],
        [ '52',   [ qw( -V -W -U              ) ] ],

        # Day of month
        [ '31',   [ qw( d 0d _d -d e 0e _e -e ) ] ],

        # Day of year
        [ '365',  [ qw( j 0j _j -j            ) ] ],

        # Day of week
        [ '5',    [ qw( u w                   ) ] ],

        # Time components
        [ '23',   [ qw( H 0H _H -H k 0k _k -k ) ] ],
        [ '59',   [ qw( M 0M S 0S             ) ] ],
        [ '59',   [ qw( _M _S                 ) ] ],
        [ '59',   [ qw( -M -S                 ) ] ],
        [ '11',   [ qw( I 0I 0l               ) ] ],
        [ '11',   [ qw( l _l _I               ) ] ],
        [ '11',   [ qw( -l -I                 ) ] ],
    );

    foreach my $test (@single) {
        my ($exp, @specifiers) = ($test->[0], @{$test->[1]});
        foreach my $specifier (@specifiers) {
            is($tm->strftime("%${specifier}"), $exp, "$string '%${specifier}'");
        }
    }

    my @combined = (
        [ 'c', 'Fri Dec 31 23:59:59 9999'   ],
        [ 'D', '12/31/99'                   ],
        [ 'F', '9999-12-31'                 ],
        [ 'r', '11:59:59 PM'                ],
        [ 'R', '23:59'                      ],
        [ 'T', '23:59:59'                   ],
        [ 'X', '23:59:59'                   ],
        [ 'x', '12/31/99'                   ],
    );

    foreach my $test (@combined) {
        my ($specifier, $exp) = @$test;
        is($tm->strftime("%${specifier}"), $exp, "$string '%${specifier}'");
    }
}

{
    my @times = map {
        Time::Moment->new(year => 1, month => 1, day => $_)
    } (1..7);

    my @DayShort = qw(
        Mon
        Tue
        Wed
        Thu
        Fri
        Sat
        Sun
    );

    my @DayFull = qw(
        Monday
        Tuesday
        Wednesday
        Thursday
        Friday
        Saturday
        Sunday
    );

    for (my $i = 0; $i < @times; $i++) {
        my $tm = $times[$i];
        is($tm->strftime('%a'), $DayShort[$i], "$tm '%a'");
        is($tm->strftime('%A'), $DayFull[$i],  "$tm '%A'");
    }
}

{
    my @times = map {
        Time::Moment->new(year => 1, month => $_, day => 1)
    } (1..12);

    my @MonthShort = qw(
        Jan
        Feb
        Mar
        Apr
        May
        Jun
        Jul
        Aug
        Sep
        Oct
        Nov
        Dec
    );

    my @MonthFull = qw(
        January
        February
        March
        April
        May
        June
        July
        August
        September
        October
        November
        December
    );

    for (my $i = 0; $i < @times; $i++) {
        my $tm = $times[$i];
        is($tm->strftime('%h'), $MonthShort[$i], "$tm '%h'");
        is($tm->strftime('%b'), $MonthShort[$i], "$tm '%b'");
        is($tm->strftime('%B'), $MonthFull[$i],  "$tm '%B'");
    }
}

{
    my @hours   = (0, 3, 6, 9, 12, 15, 17);
    my @minutes = (0, 1, 15, 30, 45, 59);
    my @sign    = qw(- +);

    foreach my $h (@hours) {
        foreach my $m (@minutes) {
            my $n = $h * 60 + $m;
            foreach my $off ($n == 0 ? ($n) : ($n, -$n)) {
                my $tm = Time::Moment->new(year => 2000, offset => $off);
                my $exp;

                $exp = sprintf '%s%02d%02d',  $sign[$off >= 0], $h, $m;
                is($tm->strftime('%z'),  $exp, "$tm '%z'"); 

                $exp = sprintf '%s%02d:%02d', $sign[$off >= 0], $h, $m;
                is($tm->strftime('%:z'), $exp, "$tm '%:z'");

                $exp = $off == 0 ? 'Z' : $exp;
                is($tm->strftime('%Z'),  $exp, "$tm '%Z'");
            }
        }
    }
}

done_testing();

