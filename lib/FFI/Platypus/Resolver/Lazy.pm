package FFI::Platypus::Resolver::Lazy;

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );
use Carp::Always;

use FFI::Platypus::Lazy::Address;

sub new
{
  my($class, $base) = @_;
  my $self = bless { base => $base }, $class;

  return $self;
}

sub find_symbol
{
  my($self, $symbol) = @_;

  return FFI::Platypus::Lazy::Address->new(
    sub
    {
      warn "realizing";

      return $self->{base}->find_symbol($symbol);
    }
  );
}

sub expensive
{
  my($self) = @_;
  return $self->{base}->expensive;
}

1;
