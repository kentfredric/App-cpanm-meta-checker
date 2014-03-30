use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package App::cpanm::meta::checker::State::Duplicates::Dist;
$App::cpanm::meta::checker::State::Duplicates::Dist::VERSION = '0.001001';
# ABSTRACT: State information for recording seen versions of a single dist

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

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

__END__

=pod

=encoding UTF-8

=head1 NAME

App::cpanm::meta::checker::State::Duplicates::Dist - State information for recording seen versions of a single dist

=head1 VERSION

version 0.001001

=head1 METHODS

=head2 C<has_duplicates>

  if ( $o->has_duplicates() ) {

  }

=head2 C<seen_version>

Mark version seen:

  $o->seen_version('1.0');

=head2 C<duplicate_versions>

  for my $version ( $o->duplicate_versions ) {

  }

=head1 ATTRIBUTES

=head2 C<reported>

=head2 C<versions>

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
