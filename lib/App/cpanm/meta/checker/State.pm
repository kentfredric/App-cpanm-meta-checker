use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package App::cpanm::meta::checker::State;

# ABSTRACT: Shared state for a single test run

# AUTHORITY

use Moo qw(has);
use App::cpanm::meta::checker::State::Duplicates;
use Path::Tiny qw(path);

has 'tests' => (
    is      => ro =>,
    lazy    => 1,
    builder => sub {
        return [ 'list_empty', 'list_duplicates', ];
    },
);

has 'list_fd' => (
    is      => ro =>,
    lazy    => 1,
    builder => sub {
        \*STDERR;
    }
);

has '_duplicates' => (
    is      => ro =>,
    lazy    => 1,
    builder => sub {
        return App::cpanm::meta::checker::State::Duplicates->new();
    },
);

sub x_test_list {
    my ( $self, $path, $state ) = @_;
    $self->list_fd->printf( "list:%s\n", path($path)->basename );
}

sub x_test_list_nonempty {
    my ( $self, $path, $state ) = @_;
    return unless path($path)->children;
    $self->list_fd->printf( "nonempty:%s\n", path($path)->basename );
}

sub x_test_list_empty {
    my ( $self, $path, $state ) = @_;
    return if path($path)->children;
    $self->list_fd->printf( "empty:%s\n", path($path)->basename );
}

sub x_test_list_duplicates {
    my ( $self, $path, $state ) = @_;
    my $basename = path($path)->basename;
    my ( $dist, $version ) = $basename =~ /\A(.*)-([^-]+(?:-TRIAL)?)\z/;

    $self->_duplicates->seen_dist_version( $dist, $version );

    return unless $self->_duplicates->has_duplicates($dist);

    my $fmt = "duplicate:%s-%s\n";

    if ( $self->_duplicates->reported_duplicates($dist) ) {
        printf $fmt, $dist, $version;
        return;
    }

    $self->list_fd->printf( $fmt, $dist, $_ )
      for $self->_duplicates->duplicate_versions($dist);

    $self->_duplicates->reported_duplicates( $dist, 1 );

    return;
}

=method C<check_path>

    ->check_path('./foo/bar/baz');

Read the content from C<./foo/bar/baz> and check its consistency.

=cut

sub check_path {
    my ( $self, $path ) = @_;
    my $state = {};
    for my $test ( @{ $self->tests } ) {
        my $method = 'x_test_' . $test;
        if ( not $self->can($method) ) {
            die "no method $method for test $test";
        }
        $self->$method( $path, $state );
    }
}

no Moo;

1;

