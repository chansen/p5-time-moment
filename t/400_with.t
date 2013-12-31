#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789Z");
    for my $year (1, 100, 1000, 2000, 9999) {
        my $got = $tm->with_year($year);
        is($got->year,            $year, "$tm->with_year($year)->year");
        is($got->month,              12, "$tm->with_year($year)->month");
        is($got->day_of_month,       24, "$tm->with_year($year)->day_of_month");
        is($got->hour,               12, "$tm->with_year($year)->hour");
        is($got->minute,             30, "$tm->with_year($year)->minute");
        is($got->second,             45, "$tm->with_year($year)->second");
        is($got->millisecond,       123, "$tm->with_year($year)->millisecond");
        is($got->microsecond,    123456, "$tm->with_year($year)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_year($year)->nanosecond");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789Z");
    for my $month (1..12) {
        my $got = $tm->with_month($month);
        is($got->year,             2012, "$tm->with_month($month)->year");
        is($got->month,          $month, "$tm->with_month($month)->month");
        is($got->day_of_month,       24, "$tm->with_month($month)->day_of_month");
        is($got->hour,               12, "$tm->with_month($month)->hour");
        is($got->minute,             30, "$tm->with_month($month)->minute");
        is($got->second,             45, "$tm->with_month($month)->second");
        is($got->millisecond,       123, "$tm->with_month($month)->millisecond");
        is($got->microsecond,    123456, "$tm->with_month($month)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_month($month)->nanosecond");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789Z");
    for my $day (1..31) {
        my $got = $tm->with_day_of_month($day);
        is($got->year,             2012, "$tm->with_day_of_month($day)->year");
        is($got->month,              12, "$tm->with_day_of_month($day)->month");
        is($got->day_of_month,     $day, "$tm->with_day_of_month($day)->day_of_month");
        is($got->hour,               12, "$tm->with_day_of_month($day)->hour");
        is($got->minute,             30, "$tm->with_day_of_month($day)->minute");
        is($got->second,             45, "$tm->with_day_of_month($day)->second");
        is($got->millisecond,       123, "$tm->with_day_of_month($day)->millisecond");
        is($got->microsecond,    123456, "$tm->with_day_of_month($day)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_day_of_month($day)->nanosecond");
    }
}

{
    my $tm = Time::Moment->from_string("2012-359T12:30:45.123456789Z");
    for my $day (1..366) {
        my $got = $tm->with_day_of_year($day);
        is($got->year,             2012, "$tm->with_day_of_year($day)->year");
        is($got->day_of_year,      $day, "$tm->with_day_of_year($day)->day_of_year");
        is($got->hour,               12, "$tm->with_day_of_year($day)->hour");
        is($got->minute,             30, "$tm->with_day_of_year($day)->minute");
        is($got->second,             45, "$tm->with_day_of_year($day)->second");
        is($got->millisecond,       123, "$tm->with_day_of_year($day)->millisecond");
        is($got->microsecond,    123456, "$tm->with_day_of_year($day)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_day_of_year($day)->nanosecond");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789Z");
    for my $hour (0..23) {
        my $got = $tm->with_hour($hour);
        is($got->year,             2012, "$tm->with_hour($hour)->year");
        is($got->month,              12, "$tm->with_hour($hour)->month");
        is($got->day_of_month,       24, "$tm->with_hour($hour)->day_of_month");
        is($got->hour,            $hour, "$tm->with_hour($hour)->hour");
        is($got->minute,             30, "$tm->with_hour($hour)->minute");
        is($got->second,             45, "$tm->with_hour($hour)->second");
        is($got->millisecond,       123, "$tm->with_hour($hour)->millisecond");
        is($got->microsecond,    123456, "$tm->with_hour($hour)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_hour($hour)->nanosecond");
        is($got->offset,              0, "$tm->with_hour($hour)->offset");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789+12:34");
    for my $hour (0..23) {
        my $got = $tm->with_hour($hour);
        is($got->year,             2012, "$tm->with_hour($hour)->year");
        is($got->month,              12, "$tm->with_hour($hour)->month");
        is($got->day_of_month,       24, "$tm->with_hour($hour)->day_of_month");
        is($got->hour,            $hour, "$tm->with_hour($hour)->hour");
        is($got->minute,             30, "$tm->with_hour($hour)->minute");
        is($got->second,             45, "$tm->with_hour($hour)->second");
        is($got->millisecond,       123, "$tm->with_hour($hour)->millisecond");
        is($got->microsecond,    123456, "$tm->with_hour($hour)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_hour($hour)->nanosecond");
        is($got->offset,       12*60+34, "$tm->with_hour($hour)->offset");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789Z");
    for my $minute (0..59) {
        my $got = $tm->with_minute($minute);
        is($got->year,             2012, "$tm->with_minute($minute)->year");
        is($got->month,              12, "$tm->with_minute($minute)->month");
        is($got->day_of_month,       24, "$tm->with_minute($minute)->day_of_month");
        is($got->hour,               12, "$tm->with_minute($minute)->hour");
        is($got->minute,        $minute, "$tm->with_minute($minute)->minute");
        is($got->second,             45, "$tm->with_minute($minute)->second");
        is($got->millisecond,       123, "$tm->with_minute($minute)->millisecond");
        is($got->microsecond,    123456, "$tm->with_minute($minute)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_minute($minute)->nanosecond");
        is($got->offset,              0, "$tm->with_minute($minute)->offset");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789+12:34");
    for my $minute (0..59) {
        my $got = $tm->with_minute($minute);
        is($got->year,             2012, "$tm->with_minute($minute)->year");
        is($got->month,              12, "$tm->with_minute($minute)->month");
        is($got->day_of_month,       24, "$tm->with_minute($minute)->day_of_month");
        is($got->hour,               12, "$tm->with_minute($minute)->hour");
        is($got->minute,        $minute, "$tm->with_minute($minute)->minute");
        is($got->second,             45, "$tm->with_minute($minute)->second");
        is($got->millisecond,       123, "$tm->with_minute($minute)->millisecond");
        is($got->microsecond,    123456, "$tm->with_minute($minute)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_minute($minute)->nanosecond");
        is($got->offset,       12*60+34, "$tm->with_minute($minute)->offset");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789Z");
    for my $second (0..59) {
        my $got = $tm->with_second($second);
        is($got->year,             2012, "$tm->with_second($second)->year");
        is($got->month,              12, "$tm->with_second($second)->month");
        is($got->day_of_month,       24, "$tm->with_second($second)->day_of_month");
        is($got->hour,               12, "$tm->with_second($second)->hour");
        is($got->minute,             30, "$tm->with_second($second)->minute");
        is($got->second,        $second, "$tm->with_second($second)->second");
        is($got->millisecond,       123, "$tm->with_second($second)->millisecond");
        is($got->microsecond,    123456, "$tm->with_second($second)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_second($second)->nanosecond");
        is($got->offset,              0, "$tm->with_second($second)->offset");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789+12:34");
    for my $second (0..59) {
        my $got = $tm->with_second($second);
        is($got->year,             2012, "$tm->with_second($second)->year");
        is($got->month,              12, "$tm->with_second($second)->month");
        is($got->day_of_month,       24, "$tm->with_second($second)->day_of_month");
        is($got->hour,               12, "$tm->with_second($second)->hour");
        is($got->minute,             30, "$tm->with_second($second)->minute");
        is($got->second,        $second, "$tm->with_second($second)->second");
        is($got->millisecond,       123, "$tm->with_second($second)->millisecond");
        is($got->microsecond,    123456, "$tm->with_second($second)->microsecond");
        is($got->nanosecond,  123456789, "$tm->with_second($second)->nanosecond");
        is($got->offset,       12*60+34, "$tm->with_second($second)->offset");
    }
}

{
    my $tm = Time::Moment->from_string("2012-12-24T12:30:45.123456789+12:34");
    for my $nanosecond (0, 123, 456, 123456, 123456789) {
        my $got = $tm->with_nanosecond($nanosecond);
        is($got->year,               2012, "$tm->with_nanosecond($nanosecond)->year");
        is($got->month,                12, "$tm->with_nanosecond($nanosecond)->month");
        is($got->day_of_month,         24, "$tm->with_nanosecond($nanosecond)->day_of_month");
        is($got->hour,                 12, "$tm->with_nanosecond($nanosecond)->hour");
        is($got->minute,               30, "$tm->with_nanosecond($nanosecond)->minute");
        is($got->second,               45, "$tm->with_nanosecond($nanosecond)->second");
        is($got->nanosecond,  $nanosecond, "$tm->with_nanosecond($nanosecond)->nanosecond");
        is($got->offset,         12*60+34, "$tm->with_nanosecond($nanosecond)->offset");
    }
}

done_testing();

