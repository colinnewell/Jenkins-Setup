package Jenkins::Setup::META;

use v5.10;
use Moose;
use Parse::CPAN::Meta;
use Path::Tiny;

has name => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_name');
has abstract => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_abstract');
has dependencies => (is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_dependencies');
has local_deps => (is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_local_deps');
has repo_type => (is => 'ro', isa => 'Maybe[Str]', lazy => 1, builder => '_build_repo_type');
has repo_url => (is => 'ro', isa => 'Maybe[Str]', lazy => 1, builder => '_build_url');
has meta_file_name => (is => 'ro', isa => 'Str', required => 1);
has _meta => (is => 'ro', lazy => 1, builder => '_build_meta');

sub _build_meta
{
    my $self = shift;
    my $meta = Parse::CPAN::Meta->load_file($self->meta_file_name);
    die 'Unable to read ' . $self->meta_file_name unless $meta;
    return $meta;
}

sub _build_url
{
    my $self = shift;
    my $repo = $self->_meta->{resources}->{repository};
    if(ref $repo eq 'HASH')
    {
        return $repo->{url};
    }
    else
    {
        return $repo;
    }
}

sub _build_repo_type
{
    my $self = shift;
    my $repo = $self->_meta->{resources}->{repository};
    my $type;
    if(ref $repo eq 'HASH')
    {
        $type = $repo->{type};
    }
    unless($type)
    {
        if($self->repo_url =~ /git/)
        {
            $type = 'git';
        } 
        elsif ($self->repo_url =~ /svn/)
        {
            $type = 'svn';
        }
    }
    return $type;
}

sub _build_dependencies
{
    my $self = shift;
    my $dependencies = $self->_meta->{requires};
    my $build_dependencies = $self->_meta->{build_requires};
    my @deps;
    push @deps, keys %$dependencies if $dependencies;
    push @deps, keys %$build_dependencies if $build_dependencies;
    return \@deps;
}

sub _build_abstract
{
    my $self = shift;
    return $self->_meta->{abstract};
}

sub _build_name
{
    my $self = shift;
    return $self->_meta->{name};
}

sub _build_local_deps
{
    my $self = shift;
    my $path = File::Spec->rel2abs($self->meta_file_name);
    my ($vol, $dir, $file) = File::Spec->splitpath($path);
    my $proper_path = File::Spec->catpath($vol, $dir);
    my @local;
    for my $dep (@{$self->dependencies})
    {
        my $pathpart = $dep =~ s/::/-/gr;
        my $modpath = File::Spec->join($proper_path, '..', $pathpart);
        if(-d $modpath)
        {
            push @local, $pathpart;
        }
        else
        {
            # try a lowercase version of the path
            $modpath = File::Spec->join($proper_path, '..', lc $pathpart);
            if(-d $modpath)
            {
                push @local, lc $pathpart;
            }
        }
    }
    my %paths = map { $_ => 1 } @local;
    for my $path (@local)
    {
        my $meta_file = File::Spec->join('..', $path, 'META.yml');
        if(-f $meta_file)
        {
            my $module = Jenkins::Setup::META->new({meta_file_name =>  $meta_file });
            for my $path (@{$module->local_deps})
            {
                $paths{$path} = 1;
            }
        }
    }
    my @paths = keys %paths;
    return \@paths;
}

no Moose;
1;

=head1 NAME

Jenkins::Setup::META - Grab info from META.yml

=head1 DESCRIPTION

This class pulls basic distribution information from a META.yml.

    my $module = Jenkins::Setup::META->new({ 
        meta_file_name => "CodeHacks/META.yml" 
    });
    $module->name; # CodeHacks
    $module->repo_url; # git://github.com/colinnewell/CodeHacks.git 
    ...

=head1 ATTRIBUTES

=head2 name

Returns the distro name.

=head2 dependencies

Returns an array of dependencies.

=head2 repo_type

This returns the repository type.  Ideally it was specified in the 
META.yml, otherwise it's a really crude guess.

=head2 repo_url

Returns the url for the repository.

=head2 file_name

This is the filename of the META.yml file read.  This is the one 
parameter you should specify if you want the module to read it
and parse it.

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
