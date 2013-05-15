#!/usr/bin/perl

use Modern::Perl;

use Jenkins::Setup;

# FIXME: add command line parsing or something.
# allow config xml to be produced without pushing to 
# url
# also allow just commands to be displayed.
my $meta = 'META.yml';

my $app = Jenkins::Setup->new({ meta_file => $meta });
my $module = $app->module;
my $deps = $module->local_deps;

print "Blanking PERL5LIB\n";
$ENV{'PERL5LIB'} = '';
my $prove = "prove -l ";
if(@$deps)
{
    my $deps = join ' ', map { "-I ../$_/lib" } @$deps;
    $prove .= $deps;
}
$prove .= " t";
print "$prove\n";
system $prove;
# FIXME: add dependencies.

