package FFI::Platypus::TypeMap::Lazy;
use Tie::Hash;
use parent -norequire, 'Tie::ExtraHash';

use strict;
use warnings;

sub TIEHASH
{
  my $p = shift;
  bless \@_, $p;
}

sub STORE
{
  my($self,$key,$value) = @_;

  $self->[1]->type($value, $key);

  $self->SUPER::STORE($self,$key,$value);
}

sub FETCH
{
  my($self,$key) = @_;

  my $ret = $self->SUPER::FETCH($key);

  $ret->can('realize') ? $ret->realize : $ret;
}

1;
