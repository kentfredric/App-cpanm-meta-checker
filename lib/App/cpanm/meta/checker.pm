use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package App::cpanm::meta::checker;
$App::cpanm::meta::checker::VERSION = '0.001000';
# ABSTRACT: Verify and sanity check your installation verses cpanm meta files

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY








































































use Moo 1.000008 q();
use Moo qw( has );
use Path::Tiny qw( path );
use App::cpanm::meta::checker::State;
use Config qw(%Config);
use Carp qw(croak);
use Getopt::Long;

has 'search_dirs' => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        my @paths;
        push @paths,
          path( $Config{sitelibexp} )->child( $Config{archname} )
          ->child('.meta');
        return \@paths;
    },
);

sub all_search_dirs {
    my ($self) = @_;
    return @{ $self->search_dirs };
}

sub all_search_dir_child {
    my ( $self, @childpath ) = @_;
    my @answers = grep { -e $_ }
      map { path($_)->child(@childpath) } @{ $self->search_dirs };
    return @answers unless $self->sorted;
    return @{ [ sort @answers ] };
}

sub all_search_dir_children {
    my ($self) = @_;
    my @answers = map { path($_)->children } @{ $self->search_dirs };
    return @answers unless $self->sorted;
    return @{ [ sort @answers ] };
}

has 'tests' => (
    is      => ro =>,
    lazy    => 1,
    builder => sub {
        return [
            'list_empty',             'list_duplicates',
            'check_runtime_requires', 'check_runtime_recommends',
            'check_runtime_suggests', 'check_runtime_conflicts',
        ];
    },
);

has 'sorted' => (
    is      => ro  =>,
    lazy    => 1,
    builder => sub { return; },
);

has 'mode' => (
    is      => ro  =>,
    lazy    => 1,
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
    my ($self) = @_;
    return $self->check_all if 'all' eq $self->mode;
    return;
}

sub new_from_command {
    my ( $class, %defaults ) = @_;

    my $config = {};
    my $verbose;

    Getopt::Long::Configure( 'auto_version', 'auto_help' );

    Getopt::Long::GetOptions(
        's|sort!'  => \$config->{sorted},
        'A|all!'   => sub { $config->{mode} = 'all' },
        'verbose!' => sub {
            $verbose = $_[0];
        },
        'test=s' => sub {
            if (
                not App::cpanm::meta::checker::State->can( 'x_test_' . $_[1] ) )
            {
                croak("No such test $_[1]");
            }
            push @{ $config->{tests} }, $_[1];
        },
    ) or croak(Getopt::Long::HelpMessage);

    my $app_obj = $class->new( +{ %defaults, %{$config} } );
    if ($verbose) {
        unshift @{ $app_obj->tests }, 'list';
    }
    return $app_obj;
}
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::cpanm::meta::checker - Verify and sanity check your installation verses cpanm meta files

=head1 VERSION

version 0.001000

=head1 SYNOPSIS

    cpanm-meta-checker --all --verbose

=head1 DESCRIPTION

C<cpanm> installs a few auxiliary files:

    $SITELIB/.meta/DISTNAME-DISTVERSION/MYMETA.json
    $SITELIB/.meta/DISTNAME-DISTVERSION/install.json

These files describe several things, such as dependencies
declared by upstream, and sniffed extra context.

This tool exists to read those files, and verify that their dependencies
are still holding true, that no new conflicting dependencies have
been installed and are silently sitting there broken.

Also, as C<cpanm>'s auxiliary files are really a prototype
for what may eventually become a tool-chain standard, this tool
is also a prototype for a tool-chain standard checker.

=head1 METHODS

=head2 C<check_path>

    ->check_path('./foo/bar/baz');

Read the content from C<./foo/bar/baz> and check its consistency.

=head2 C<check_release>

    ->check_release('Moose-2.000000')

Read the meta-data for the exact release stated and perform checks on it.

=head2 C<check_distname>

    ->check_distname('Moose')

Check meta-data for any C<dist(s)> named C<Moose>

Note: There may be directories residual from past installs.

=head2 C<check_all>

    ->check_all

Check meta-data for all installed distributions.

=head1 DEFAULT TEST SET

    list_empty
    list_duplicates
    check_runtime_requires
    check_runtime_recommends
    check_runtime_suggests
    check_runtime_conflicts

=head1 AVAILABLE TEST SET

=head2 C<list_duplicates>

For now, it includes output about every instance where there are more than one
set of meta files.

This occurs, because installing a new version of something doesn't purge the data ( or all the files ) of the old one.

=head2 C<list>

This lists all distributions seen.

=head2 C<list_empty>

This lists distributions that have a directory for a meta file, but have no meta file in them. ( Rare )

=head2 C<list_nonempty>

This lists distributions that have meta files.

=head2 C<check_PHASE_TYPE>

There is a check for each combination of:

    PHASE: configure build runtime test develop
    TYPE:  requires recommends suggests conflicts

Each checks the meta-data for conforming dependencies.

For instance:

    check_runtime_requires # Report Runtime requirements that are unsatisfied
    check_develop_requires # Report Develop requiremetns that are unsatisifed

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
