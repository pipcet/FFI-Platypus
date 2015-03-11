package FFI::Platypus::Lazy::Types;
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

  if($ret->can('realize'))
  {
    local $self->[0]->{$key} = undef;

    return $self->SUPER::STORE($key, $ret->realize);
  }
  else
  {
    return $ret;
  }
}

1;
