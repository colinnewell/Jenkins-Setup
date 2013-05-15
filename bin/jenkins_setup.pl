#!/usr/bin/perl

use Modern::Perl;

use Jenkins::Setup;

# FIXME: add command line parsing or something.
my $url = shift;
die 'Must specify jenkins url' unless $url;
my $meta = shift;
die 'Must specify META.yml' unless $meta;

my $app = Jenkins::Setup->new({ meta_file => $meta, url => $url });
$app->setup_module();

