use 5.006;    # our
use strict;
use warnings;

package App::cpanm::meta::checker::State::Duplicates::Dist;

our $VERSION = '0.001002';

# ABSTRACT: State information for recording seen versions of a single dist

# AUTHORITY

use Moo qw( has );

=attr C<reported>

=cut

has 'reported' => (
  is      => rw  =>,
  lazy    => 1,
  builder => sub { return; },
);

=attr C<versions>

=cut

has 'versions' => (
  is   => ro =>,
  lazy => 1,
  builder => sub { return {} },
);

=method C<has_duplicates>

  if ( $o->has_duplicates() ) {

  }

=cut

sub has_duplicates {
  my ($self) = @_;
  return ( keys %{ $self->versions } > 1 );
}

=method C<seen_version>

Mark version seen:

  $o->seen_version('1.0');

=cut

sub seen_version {
  my ( $self, $version ) = @_;
  $self->versions->{$version} = 1;
  return;
}

=method C<duplicate_versions>

  for my $version ( $o->duplicate_versions ) {

  }

=cut

sub duplicate_versions {
  my ($self) = @_;
  return keys %{ $self->versions };
}

no Moo;

1;

