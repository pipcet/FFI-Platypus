package FFI::Platypus::Type::Lazy;
use parent -norequire, 'FFI::Platypus::Type';

use strict;
use warnings;
use Carp qw(croak);

sub AUTOLOAD {
  my $self = shift;
  my $method = do { no warnings; no strict; $AUTOLOAD };

  $method =~ s/.*:://;

  $self->realize->$method(@_);
}

sub realize
{
  my($self) = @_;

  return $self->{realization} if $self->{realization};

  $self->{realization} = $self->{sub}->();

  croak 'failed to realize type' unless $self->{realization};

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
