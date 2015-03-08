package FFI::Platypus::Types::Lazy;
use Tie::Hash;
use parent -norequire, 'Tie::ExtraHash';

use strict;
use warnings;

sub TIEHASH {
  my $p = shift;
  bless \@_, $p;
}

sub FETCH {
  my($self,$key) = @_;

  my $ret = $self->SUPER::FETCH($key);

  return unless defined $ret;

  $ret->can('realize') ? $ret->realize : $ret;
}

1;
