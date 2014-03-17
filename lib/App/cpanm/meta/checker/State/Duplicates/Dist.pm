use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package App::cpanm::meta::checker::State::Duplicate::Dist;

# ABSTRACT: State information for recording seen versions of a single dist

# AUTHORITY

use Moo qw( has );

has 'reported' => (
    is      => rw  =>,
    lazy    => 1,
    builder => sub { return; },
);

has 'versions' => (
    is   => ro =>,
    lazy => 1,
    builder => sub { return {} },
);

sub has_duplicates {
    my ($self) = @_;
    return ( keys %{ $self->versions } > 1 );
}

sub seen_version {
    my ( $self, $version ) = @_;
    $self->versions->{$version} = 1;
    return;
}

sub duplicate_versions {
    my ($self) = @_;
    return keys %{ $self->versions };
}

no Moo;

1;

