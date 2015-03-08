package FFI::Platypus::Resolver::dl;

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );
use Carp::Always;

sub new
{
  my($class, $path) = @_;

  my $self = bless { handle => FFI::Platypus::dl::dlopen($path) }, $class;

  return $self;
}

sub find_symbol
{
  my($self, $symbol) = @_;

  return FFI::Platypus::dl::dlsym($self->{handle}, $symbol);
}

sub expensive
{
  0;
}

sub DESTROY
{
  my($self) = @_;

  FFI::Platypus::dl::dlclose($self->{handle})
      if defined $self->{handle};
}

1;
