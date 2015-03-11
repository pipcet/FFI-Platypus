package FFI::Platypus::Lazy::Type;
use parent -norequire, 'FFI::Platypus::Type';

use strict;
use warnings;
use Carp qw(croak);
use overload
    bool => sub { my $self = shift; $self->realize };

sub AUTOLOAD
{
  my $self = shift;
  my $method = do { no warnings; no strict; $AUTOLOAD };

  $method =~ s/.*:://;

  $self->realize->$method(@_);
}

sub sizeof
{
  my($self) = @_;

  return $self->realize->sizeof;
}

sub meta
{
  my($self) = @_;

  return $self->realize->meta;
}

sub realize
{
  my($self) = @_;

  return $self->{realization} if $self->{realization};

  my $real = $self;
  $real = $real->{sub}->() while ref($real) and $real->can('realize');
  $self->{realization} = $real;

  delete $self->{sub};

  return $self->{realization};
}

sub new
{
  my($class, $sub) = @_;

  return bless { sub => $sub }, $class;
}

sub DESTROY
{
}

1;
