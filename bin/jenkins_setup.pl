#!/usr/bin/perl

use Modern::Perl;
use Getopt::Std;

use Jenkins::Setup;

sub usage
{
    my $error = shift;
    print $error, "\n" if $error;
    print "Usage $0 -u http://jenkins:8080 [-m META.yml] [-w '../\$project/lib'] [-U username -p password] [-e username]\n";
    exit 1;
}

my %opts;
getopts('e:u:m:w:p:U:h', \%opts);
usage if $opts{h};
my $url = $opts{u};
my $username = $opts{U};
my $password = $opts{p};
my $email = $opts{e};
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
$params->{email_recipient} = $email;

my $app = Jenkins::Setup->new($params);
$app->setup_module();

