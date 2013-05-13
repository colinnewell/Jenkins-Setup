use Test::Most;

use Jenkins::Setup::META;
use FindBin;

my $module = Jenkins::Setup::META->new({ meta_file_name => "$FindBin::Bin/META.yml" });
is $module->name, 'CodeHacks';
is $module->repo_url, 'git://github.com/colinnewell/CodeHacks.git';
is $module->repo_type, 'git';
is $module->abstract, 'Scripts for the lazy programmer';
my @deps = sort @{$module->dependencies};
my @expected = sort qw/
    File::ShareDir
    File::Slurp
    Modern::Perl
    Template
    YAML::Tiny
    perl
/;
eq_or_diff \@deps, \@expected;


done_testing;

