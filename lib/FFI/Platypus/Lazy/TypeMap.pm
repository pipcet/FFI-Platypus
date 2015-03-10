package FFI::Platypus::Lazy::TypeMap;
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

  eval {
    $self->[1]->type($value, $key);
  };
  warn $@ if $@;

  $self->SUPER::STORE($self,$key,$value);
}

1;
