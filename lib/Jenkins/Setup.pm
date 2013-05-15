package Jenkins::Setup;

use 5.010;
use strict;
use warnings FATAL => 'all';
use Moose;
use Jenkins::Config;
use Jenkins::Setup::META;
use Jenkins::API;

=head1 NAME

Jenkins::Setup - Script for settin up perl repo's in Jenkins

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

has url => (is => 'ro', isa => 'Str', required => 1);
has meta_file => (is => 'ro', isa => 'Str', required => 1);


sub setup_module
{
    my $self = shift;

    my $module = Jenkins::Setup::META->new({ meta_file_name => $self->meta_file });
    my $deps = $module->local_deps;
    for my $key (qw/name repo_url repo_type/)
    {
        unless($module->$key)
        {
            die "Unable to setup module in jenkins because we are missing the $key";
        }
    }
    my $cb = Jenkins::Config->new();
    my $hash = $cb->default_project;
    $hash->{description} = $module->abstract;
    # FIXME: add svn support
    if($module->repo_type eq 'git')
    {
        $hash->{scm}->{userRemoteConfigs}->{'hudson.plugins.git.UserRemoteConfig'}->{url} = $module->repo_url;
    }
    my $shell_commands = $hash->{builders}->{'hudson.tasks.Shell'};
    if(@$deps)
    {
        my $cpan_line = $shell_commands->[1]->{command};
        my $lib = join ':', map { "../$_/lib" } @$deps;
        $cpan_line = sprintf "PERL5LIB=%s %s", $lib, $cpan_line;
        $shell_commands->[1]->{command} = $cpan_line;
        print "$cpan_line\n";
        my $prove_line = $shell_commands->[2]->{command};
        my $deps = join ' ', map { "-I ../$_/lib" } @$deps;
        $prove_line =~ s|(/opt/perl5/bin/prove)|$1 $deps|;
        print "$prove_line\n";
        $shell_commands->[2]->{command} = $prove_line;
    }
    # FIXME: add dependencies.

    my $xml = $cb->to_xml($hash);

    my $jenkins = Jenkins::API->new({ base_url => $self->url });
    die 'Jenkins not running on ' . $self->url unless $jenkins->check_jenkins_url;
    unless($jenkins->create_job($module->name, $xml))
    {
        $jenkins->set_project_config($module->name, $xml) || die 'Unable to set config';
    }
    print "Project created\n";
}


=head1 SYNOPSIS

This script assumes that you have all your local modules within a 
single directory, e.g.

    src/
        Module1/
        Module2/
        Module3/

It assumes that you have those local module dependencies in your
requires too, and also that your META.yml has been generated by
running the make file or build script of the module.

The META.yml should contain the repository details too.  The 3 items
that are absolutely required in the META.yml are the C<required>,
C<repository> and C<name>.  If you want a sane choice of repository
type you should really specify the repository type too along with
the url.  The guessing of the type is really lame, so the least left
to guess work the better.

=head1 METHODS

=head2 setup_module



=head1 AUTHOR

Colin Newell, C<< <colin.newell at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-jenkins-setup at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Jenkins-Setup>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Jenkins::Setup


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Jenkins-Setup>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Jenkins-Setup>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Jenkins-Setup>

=item * Search CPAN

L<http://search.cpan.org/dist/Jenkins-Setup/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Colin Newell.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Jenkins::Setup
