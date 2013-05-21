#!/usr/bin/perl

use Modern::Perl;
use Getopt::Std;

use Jenkins::Setup;

sub usage
{
    my $error = shift;
    print $error, "\n" if $error;
    print "Usage $0 -u http://jenkins:8080 [-m META.yml] [-w '../\$project/lib']\n";
    exit 1;
}

my %opts;
getopts('u:m:w:h', \%opts);
usage if $opts{h};
my $url = $opts{u};
usage('Must specify jenkins url') unless $url;
my $meta = $opts{m} || 'META.yml';
usage('Can not find META file') unless -f $meta;

my $params = { 
    meta_file => $meta, 
    url => $url 
};
if($opts{w})
{
    $params->{workspace_dir} = $opts{w};
}

my $app = Jenkins::Setup->new($params);
$app->setup_module();

