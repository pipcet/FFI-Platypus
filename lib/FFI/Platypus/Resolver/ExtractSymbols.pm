package FFI::Platypus::Resolver::ExtractSymbols;

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );
use Carp::Always;
use FFI::ExtractSymbols;

sub new
{
  my($class, $path) = @_;
  my %symbols;

  extract_symbols($path,
      code => sub {
	$symbols{$_[0]} = \@_;
      });

  return bless \%symbols, $class;
}

sub find_symbol
{
  my($self, $symbol) = @_;

  return $self->{$symbol}->[2];
}

sub expensive
{
  'somewhat';
}

1;
