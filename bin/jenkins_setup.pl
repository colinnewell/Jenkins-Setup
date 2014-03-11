#!/usr/bin/perl

use Modern::Perl;
use Getopt::Std;

use Jenkins::Setup;

sub usage
{
    my $error = shift;
    print $error, "\n" if $error;
    print "Usage $0 -u http://jenkins:8080 [-m META.yml] [-w '../\$project/lib'] [-U username -p password]\n";
    exit 1;
}

my %opts;
getopts('u:m:w:p:U:h', \%opts);
# FIXME: add command line parsing or something.
usage if $opts{h};
my $url = $opts{u};
my $username = $opts{U};
my $password = $opts{p};
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
if($username && $password)
{
    $params->{username} = $username;
    $params->{password} = $password;
}

my $app = Jenkins::Setup->new($params);
$app->setup_module();

