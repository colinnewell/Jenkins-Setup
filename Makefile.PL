use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'Jenkins-Setup';
all_from 'lib/Jenkins/Setup.pm';
author   q{Colin Newell <colin.newell@gmail.com>};
license  'artistic2';

perl_version 5.010;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#Jenkins-Setup',
   license    => 'http://www.perlfoundation.org/artistic_license_2_0',
   repository => 'ssh://git-server/srv/git/Jenkins-Setup',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Jenkins-Setup',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   'Moose' => 0,
   'Parse::CPAN::Meta' => 0,
   'Path::Tiny' => 0,
   'Jenkins::API' => 0,
   'Jenkins::Config' => 0,
);

install_as_cpan;
auto_install;
WriteAll;
