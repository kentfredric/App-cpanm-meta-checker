use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package App::cpanm::meta::checker;
$App::cpanm::meta::checker::VERSION = '0.001000';
# ABSTRACT: Verify and sanity check your installation verses cpanm metafiles

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

























use Moo 1.000008 qw( has );
use Path::Tiny qw( path );
use App::cpanm::meta::checker::State;
use Config qw();
use Getopt::Long;

has 'search_dirs' => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        my @paths;
        push @paths,
          path( $Config::Config{sitelibexp} )
          ->child( $Config::Config{archname} )->child('.meta');
        return \@paths;
    },
);

sub all_search_dirs {
    return @{ $_[0]->search_dirs };
}

sub all_search_dir_child {
    my ( $self, @childpath ) = @_;
    my @answers = grep { -e $_ }
      map { path($_)->child(@childpath) } @{ $_[0]->search_dirs };
    return @answers unless $self->sorted;
    return ( my @sorted = sort @answers );
}

sub all_search_dir_children {
    my ($self) = @_;
    my @answers = map { path($_)->children } @{ $_[0]->search_dirs };
    return @answers unless $self->sorted;
    return ( my @sorted = sort @answers );
}

has 'tests' => (
    is      => ro =>,
    lazy    => 1,
    builder => sub {
        return [ 'list_empty', 'list_duplicates', ];
    },
);

has 'sorted' => (
    is      => ro  =>,
    lazy    => 1,
    builder => sub { return; }
);

has 'mode' => (
    is => ro =>,
    lazy => 1,
    builder => sub { return 'all' },
);









sub check_path {
    my ( $self, $path ) = @_;
    my $state = App::cpanm::meta::checker::State->new( tests => $self->tests );
    return $state->check_path($path);
}









sub check_release {
    my ( $self, $releasename ) = @_;
    my $state = App::cpanm::meta::checker::State->new( tests => $self->tests );
    for my $dir ( $self->all_search_dir_child($releasename) ) {
        $state->check_path($dir);
    }
    return;
}











sub check_distname {
    my ( $self, $distname ) = @_;
    my $state = App::cpanm::meta::checker::State->new( tests => $self->tests );

    for my $dir (
        grep { path($_)->basename =~ /\A\Q$distname\E-[^-]+(?:TRIAL)?\z/ }
        $self->all_search_dir_children )
    {
        $state->check_path($dir);
    }
    return;
}









sub check_all {
    my ($self) = @_;

    my $state = App::cpanm::meta::checker::State->new( tests => $self->tests );
    for my $dir ( $self->all_search_dir_children ) {
        $state->check_path($dir);
    }
    return;
}


sub run_command {
    my ( $self ) = @_;
    if ( $self->mode eq 'all' ) {
        return $self->check_all;
    }
    return;
}
sub new_from_command {
    my ( $class , %defaults ) = @_;

    my $config = {};

    Getopt::Long::Configure('auto_version','auto_help');

    Getopt::Long::GetOptions(
        's|sort!' => \$config->{sort},
        'A|all!'  => sub { $config->{mode} = 'all' },
        'verbose!' => \$config->{verbose},
    );

    return $class->new( { %defaults, %{$config}} );
}
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::cpanm::meta::checker - Verify and sanity check your installation verses cpanm metafiles

=head1 VERSION

version 0.001000

=head1 SYNOPSIS

    cpanm-meta-checker --all --verbose

=head1 DESCRIPTION

C<cpanm> installs a few auxilary files:

    $SITELIB/.meta/DISTNAME-DISTVERSION/MYMETA.json
    $SITELIB/.meta/DISTNAME-DISTVERSION/install.json

These files describe several things, such as dependencies
declared by upstream, and sniffed extra context.

This tool exists to read those files, and verify that their dependencies
are still holding true, that no new conflicting dependencies have
been installed and are silently sitting there broken.

Also, as C<cpanm>'s auxilary files are really a prototype
for what may eventually become a toolchain standard, this tool
is also a prototype for a toolchain standard checker.

=head1 METHODS

=head2 C<check_path>

    ->check_path('./foo/bar/baz');

Read the content from C<./foo/bar/baz> and check its consistency.

=head2 C<check_release>

    ->check_release('Moose-2.000000')

Read the metadata for the exact release stated and perform checks on it.

=head2 C<check_distname>

    ->check_distname('Moose')

Check metadata for any C<dist(s)> named C<Moose>

Note: There may be directories residual from past installs.

=head2 C<check_all>

    ->check_all

Check metadata for all installed dists.

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
