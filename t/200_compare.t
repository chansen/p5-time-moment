#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Time::Moment');
}

{
    my $tm1 = Time::Moment->from_epoch(0);
    my $tm2 = Time::Moment->from_epoch(86400);
    
    is($tm1->is_before($tm2), !!1, "$tm1 is before $tm2");
    is($tm1->is_after($tm2),  !!0, "$tm1 is not after $tm2");
    is($tm1->is_equal($tm2),  !!0, "$tm1 is not equal $tm2");
    
    is($tm2->is_before($tm1), !!0, "$tm2 is not before $tm1");
    is($tm2->is_after($tm1),  !!1, "$tm2 is after $tm1");
    is($tm2->is_equal($tm1),  !!0, "$tm2 is not equal $tm1");
    
    is($tm1->is_equal($tm1),  !!1, "$tm1 is equal $tm1");
    is($tm2->is_equal($tm2),  !!1, "$tm2 is equal $tm2");
    
    cmp_ok($tm1->compare($tm2), '<',  0, "$tm1 ->compare $tm2");
    cmp_ok($tm2->compare($tm1), '>',  0, "$tm2 ->compare $tm1");
    cmp_ok($tm1->compare($tm1), '==', 0, "$tm1 ->compare $tm1");
    cmp_ok($tm2->compare($tm2), '==', 0, "$tm2 ->compare $tm2");
    
    cmp_ok($tm1, '!=', $tm2, "$tm1 != $tm2");
    cmp_ok($tm1,  '<', $tm2, "$tm1  < $tm2");
    cmp_ok($tm1, '<=', $tm2, "$tm1 <= $tm2");
    cmp_ok($tm1, '==', $tm1, "$tm1 == $tm1");
    
    cmp_ok($tm2, '!=', $tm1, "$tm2 != $tm1");
    cmp_ok($tm2,  '>', $tm1, "$tm2  > $tm1");
    cmp_ok($tm2, '>=', $tm1, "$tm2 >= $tm1");
    cmp_ok($tm2, '==', $tm2, "$tm2 == $tm2");
    
    my $s1 = '1970-01-01T00:00:00Z';
    my $s2 = '1970-01-02T00:00:00Z';
    cmp_ok($tm2, 'ne', $s1, "$tm2 ne $s1");
    cmp_ok($tm2, 'gt', $s1, "$tm2 gt $s1");
    cmp_ok($tm2, 'ge', $s1, "$tm2 ge $s1");
    cmp_ok($tm2, 'eq', $s2, "$tm2 eq $s2");
}

done_testing();

