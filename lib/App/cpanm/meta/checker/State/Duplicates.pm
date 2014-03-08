use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package App::cpanm::meta::checker::State::Duplicates;

# ABSTRACT: Data tracking for duplicate distribution metadata

# AUTHORITY

use Moo;

has 'dists' => (
    is      => ro  =>,
    lazy    => 1,
    builder => sub { {} },
);

sub seen_dist_version {
    my ( $self, $dist, $version ) = @_;
    if ( not exists $self->dists->{$dist} ) {
        $self->dists->{$dist} =
          App::cpanm::meta::checker::State::Duplicate::Dist->new();
    }
    $self->dists->{$dist}->seen_version($version);
}

sub has_duplicates {
    my ( $self, $dist ) = @_;
    return unless exists $self->dists->{$dist};
    return $self->dists->{$dist}->has_duplicates;
}

sub reported_duplicates {
    my ( $self, $dist, $set ) = @_;
    return unless exists $self->dists->{$dist};
    return $self->dists->{$dist}->reported($set) if @_ > 2;
    return $self->dists->{$dist}->reported();
}

sub duplicate_versions {
    my ( $self, $dist ) = @_;
    return unless exists $self->dists->{$dist};
    return $self->dists->{$dist}->duplicate_versions;
}

no Moo;

package    ## hide
  App::cpanm::meta::checker::State::Duplicate::Dist;

use Moo;

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
}

sub duplicate_versions {
    my ($self) = @_;
    return keys %{ $self->versions };
}

1;

