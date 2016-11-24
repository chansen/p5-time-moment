#!/usr/bin/perl
use strict;
use warnings;

use Time::Moment;
use Time::Moment::Adjusters qw[ NextOrSameDayOfWeek
                                WesternEasterSunday ];

use enum qw[ Monday=1 Tuesday Wednesday Thursday Friday Saturday Sunday ];

# Lag (1989:253) om allmänna helgdagar (Act (1989:253) on public holidays)
# https://lagen.nu/1989:253
sub compute_public_holidays {
    @_ == 1 or die q<Usage: compute_public_holidays(year)>;
    my ($year) = @_;

    my @dates;
    my $tm     = Time::Moment->new(year => $year);
    my $easter = $tm->with(WesternEasterSunday);

    # Nyårsdagen (New Year's Day), January 1.
    push @dates, $tm->with_month(1)
                    ->with_day_of_month(1);

    # Trettondagen (Epiphany), January 6.
    push @dates, $tm->with_month(1)
                    ->with_day_of_month(6);

    # Långfredagen (Good Friday), the Friday preceding Easter Sunday.
    push @dates, $easter->minus_days(2);

    # Påskdagen (Easter Sunday), the Sunday immediately following 
    # the full moon that occurs on or next after 21 March.
    push @dates, $easter;

    # Annandag påsk (Easter Monday), the day after Easter Sunday.
    push @dates, $easter->plus_days(1);

    # Kristi himmelsfärds dag (Ascension Day), sixth Thursday 
    # after Easter Sunday.
    push @dates, $easter->plus_days(5*7+4);

    # Pingstdagen (Pentecost), seventh Sunday after Easter Sunday.
    push @dates, $easter->plus_days(7*7);

    # Annandag pingst (Whit Monday), the day after Pentecost.
    if ($year <= 2004) {
        push @dates, $easter->plus_days(7*7+1);
    }

    # Första maj (First of May), May 1.
    push @dates, $tm->with_month(5)
                    ->with_day_of_month(1);

    # Sveriges nationaldag (National Day of Sweden), June 6.
    if ($year >= 2005) {
        push @dates, $tm->with_month(6)
                        ->with_day_of_month(6);
    }

    # Midsommardagen (Midsummer's Day), Saturday that falls 
    # between June 20th to 26th.
    push @dates, $tm->with_month(6)
                    ->with_day_of_month(20)
                    ->with(NextOrSameDayOfWeek(Saturday));

    # Alla helgons dag (All Saints' Day), Saturday that falls 
    # between Oct 31st to Nov 6th.
    push @dates, $tm->with_month(10)
                    ->with_day_of_month(31)
                    ->with(NextOrSameDayOfWeek(Saturday));

    # Juldagen (Christmas Day), December 25.
    push @dates, $tm->with_month(12)
                    ->with_day_of_month(25);

    # Annandag jul (Boxing Day), December 26.
    push @dates, $tm->with_month(12)
                    ->with_day_of_month(26);

    return @dates;
}

# Swedish bank holidays
# All days except Saturdays, Sundays, Epiphany, Good Friday,
# Easter Monday, First of May, Ascension Day, Sweden's National
# Day, Midsummer Eve, Christmas Eve, Christmas Day, Boxing
# Day, New Year's Eve and New Year's Day (all according to the
# Swedish calendar), as well as any other days currently stipulated
# by the Swedish Act (1989:253) on Public Holidays.
sub compute_bank_holidays {
    @_ == 1 or die q<Usage: compute_bank_holidays(year)>;
    my ($year) = @_;

    my @dates = compute_public_holidays($year);
    my $tm    = Time::Moment->new(year => $year);

    # Midsommarafton (Midsummer's Eve), Friday that falls 
    # between June 19th to 25th.
    push @dates, $tm->with_month(6)
                    ->with_day_of_month(19)
                    ->with(NextOrSameDayOfWeek(Friday));

    # Julafton (Christmas Eve), December 24.
    push @dates, $tm->with_month(12)
                    ->with_day_of_month(24);

    # Nyårsafton (New Year's Eve), December 31.
    push @dates, $tm->with_month(12)
                    ->with_day_of_month(31);

    return sort { $a <=> $b }
           grep { $_->day_of_week <= Friday } @dates;
}

my @tests = (
    [ 2000, '2000-01-06', '2000-04-21', '2000-04-24', '2000-05-01', '2000-06-01', 
            '2000-06-12', '2000-06-23', '2000-12-25', '2000-12-26'               ],
    [ 2001, '2001-01-01', '2001-04-13', '2001-04-16', '2001-05-01', '2001-05-24', 
            '2001-06-04', '2001-06-22', '2001-12-24', '2001-12-25', '2001-12-26', 
            '2001-12-31'                                                         ],
    [ 2002, '2002-01-01', '2002-03-29', '2002-04-01', '2002-05-01', '2002-05-09', 
            '2002-05-20', '2002-06-21', '2002-12-24', '2002-12-25', '2002-12-26', 
            '2002-12-31'                                                         ],
    [ 2003, '2003-01-01', '2003-01-06', '2003-04-18', '2003-04-21', '2003-05-01', 
            '2003-05-29', '2003-06-09', '2003-06-20', '2003-12-24', '2003-12-25', 
            '2003-12-26', '2003-12-31'                                           ],
    [ 2004, '2004-01-01', '2004-01-06', '2004-04-09', '2004-04-12', '2004-05-20', 
            '2004-05-31', '2004-06-25', '2004-12-24', '2004-12-31'               ],
    [ 2005, '2005-01-06', '2005-03-25', '2005-03-28', '2005-05-05', '2005-06-06', 
            '2005-06-24', '2005-12-26'                                           ],
    [ 2006, '2006-01-06', '2006-04-14', '2006-04-17', '2006-05-01', '2006-05-25', 
            '2006-06-06', '2006-06-23', '2006-12-25', '2006-12-26'               ],
    [ 2007, '2007-01-01', '2007-04-06', '2007-04-09', '2007-05-01', '2007-05-17', 
            '2007-06-06', '2007-06-22', '2007-12-24', '2007-12-25', '2007-12-26', 
            '2007-12-31'                                                         ],
    [ 2008, '2008-01-01', '2008-03-21', '2008-03-24', '2008-05-01', '2008-05-01', 
            '2008-06-06', '2008-06-20', '2008-12-24', '2008-12-25', '2008-12-26', 
            '2008-12-31'                                                         ],
    [ 2009, '2009-01-01', '2009-01-06', '2009-04-10', '2009-04-13', '2009-05-01', 
            '2009-05-21', '2009-06-19', '2009-12-24', '2009-12-25', '2009-12-31' ],
    [ 2010, '2010-01-01', '2010-01-06', '2010-04-02', '2010-04-05', '2010-05-13', 
            '2010-06-25', '2010-12-24', '2010-12-31'                             ],
    [ 2011, '2011-01-06', '2011-04-22', '2011-04-25', '2011-06-02', '2011-06-06', 
            '2011-06-24', '2011-12-26'                                           ],
    [ 2012, '2012-01-06', '2012-04-06', '2012-04-09', '2012-05-01', '2012-05-17', 
            '2012-06-06', '2012-06-22', '2012-12-24', '2012-12-25', '2012-12-26', 
            '2012-12-31'                                                         ],
    [ 2013, '2013-01-01', '2013-03-29', '2013-04-01', '2013-05-01', '2013-05-09', 
            '2013-06-06', '2013-06-21', '2013-12-24', '2013-12-25', '2013-12-26', 
            '2013-12-31'                                                         ],
    [ 2014, '2014-01-01', '2014-01-06', '2014-04-18', '2014-04-21', '2014-05-01', 
            '2014-05-29', '2014-06-06', '2014-06-20', '2014-12-24', '2014-12-25', 
            '2014-12-26', '2014-12-31'                                           ],
    [ 2015, '2015-01-01', '2015-01-06', '2015-04-03', '2015-04-06', '2015-05-01', 
            '2015-05-14', '2015-06-19', '2015-12-24', '2015-12-25', '2015-12-31' ],
    [ 2016, '2016-01-01', '2016-01-06', '2016-03-25', '2016-03-28', '2016-05-05', 
            '2016-06-06', '2016-06-24', '2016-12-26'                             ],
    [ 2017, '2017-01-06', '2017-04-14', '2017-04-17', '2017-05-01', '2017-05-25', 
            '2017-06-06', '2017-06-23', '2017-12-25', '2017-12-26'               ],
    [ 2018, '2018-01-01', '2018-03-30', '2018-04-02', '2018-05-01', '2018-05-10', 
            '2018-06-06', '2018-06-22', '2018-12-24', '2018-12-25', '2018-12-26', 
            '2018-12-31'                                                         ],
    [ 2019, '2019-01-01', '2019-04-19', '2019-04-22', '2019-05-01', '2019-05-30', 
            '2019-06-06', '2019-06-21', '2019-12-24', '2019-12-25', '2019-12-26', 
            '2019-12-31'                                                         ],
    [ 2020, '2020-01-01', '2020-01-06', '2020-04-10', '2020-04-13', '2020-05-01', 
            '2020-05-21', '2020-06-19', '2020-12-24', '2020-12-25', '2020-12-31' ],
);

use Test::More 0.88;

foreach my $test (@tests) {
    my ($year, @exp) = @$test;
    my @got = map {
        $_->strftime('%Y-%m-%d')
    } compute_bank_holidays($year);
    is_deeply([@got], [@exp], "Swedish bank holidays for year $year");
}

done_testing();

