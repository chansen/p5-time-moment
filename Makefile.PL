use strict;
use warnings;

BEGIN {
    unshift @INC, 'inc';

    my @required = (
        'inc::Module::Install'      => '1.00',
        'Module::Install::XSUtil'   => '0.36',
        'Test::More'                => '0.88',
    );

    my @missing;
    while(my($module, $version) = splice(@required, 0, 2)) {
        eval qq{use $module $version (); 1}
          or push @missing, $module;
    }

    if(@missing) {
        print qq{# The following modules are not available.\n};
        print qq{# `perl $0 | cpanm` will install them:\n};
        s/\A inc:: //x for @missing;
        print $_, "\n" for @missing;
        exit 1;
     }
}

use inc::Module::Install;

name           'Time-Moment';
all_from       'lib/Time/Moment.pm';
repository     'http://github.com/chansen/p5-time-moment';

requires       'Carp'        => '0';
requires       'Exporter'    => '0';
requires       'XSLoader'    => '0';
requires       'Time::HiRes'  => '0';

test_requires  'Test::More'  => '0.88';

cc_warnings;
cc_include_paths 'src';
cc_src_paths     '.';

ppport;
requires_external_cc;

WriteAll;
