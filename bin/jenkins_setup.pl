#!/usr/bin/perl

use Modern::Perl;

use Jenkins::Setup;

my $app = Jenkins::Setup->new();

# FIXME: add command line parsing or something.
my $meta = shift;
die 'Must specify META.yml' unless $meta;

$app->setup_module($meta);

