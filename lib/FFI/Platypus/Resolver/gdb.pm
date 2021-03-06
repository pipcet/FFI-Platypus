package FFI::Platypus::Resolver::gdb;

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );
use Carp::Always;
use IPC::Run;package FFI::Platypus::Handle::dl;

sub new
{
  my($class, $path) = @_;

  my $self = bless { handle => FFI::Platypus::dl::dlopen($path) }, $class;

  return $self;
}

sub find_symbol
{
  my($self, $symbol) = @_;

  return FFI::platypus::dl::dlsym($self->{handle}, $symbol);
}

sub expensive
{
  'very';
}

sub DESTROY
{
  my($self) = @_;

  FFI::Platypus::dl::dlclose($self->{handle});
}

1;
