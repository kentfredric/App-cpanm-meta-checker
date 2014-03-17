use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package App::cpanm::meta::checker::State::Duplicates;

# ABSTRACT: Data tracking for duplicate distribution meta-data

# AUTHORITY

use Moo qw( has );
use App::cpanm::meta::checker::State::Duplicates::Dist;

has 'dists' => (
  is      => ro  =>,
  lazy    => 1,
  builder => sub { {} },
);

sub seen_dist_version {
  my ( $self, $dist, $version ) = @_;
  if ( not exists $self->dists->{$dist} ) {
    $self->dists->{$dist} = App::cpanm::meta::checker::State::Duplicates::Dist->new();
  }
  return $self->dists->{$dist}->seen_version($version);
}

sub has_duplicates {
  my ( $self, $dist ) = @_;
  return unless exists $self->dists->{$dist};
  return $self->dists->{$dist}->has_duplicates;
}

sub reported_duplicates {
  my ( $self, $dist, $set_reported ) = @_;
  return unless exists $self->dists->{$dist};
  return $self->dists->{$dist}->reported($set_reported) if @_ > 2;
  return $self->dists->{$dist}->reported();
}

sub duplicate_versions {
  my ( $self, $dist ) = @_;
  return unless exists $self->dists->{$dist};
  return $self->dists->{$dist}->duplicate_versions;
}

1;
