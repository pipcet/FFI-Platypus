package FFI::Platypus::Address::Lazy;

use strict;
use warnings;
use Carp qw(croak);
use overload
    bool => sub { my $self = shift; $self->realize },
    '""' => sub { my $self = shift; $self->realize },
    '0+' => sub { my $self = shift; $self->realize },
    'eq' => sub {
      my($self, $other) = @_;
      $self->realize eq ($other->can('realize') ? $other->realize : $other);
    },
    'cmp' => sub {
      my($self, $other) = @_;
      $self->realize cmp ($other->can('realize') ? $other->realize : $other);
    },
    '<=>' => sub {
      my($self, $other) = @_;
      $self->realize <=> ($other->can('realize') ? $other->realize : $other);
    };

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

  return $self->{realization};
}

sub new
{
  my($class, $sub) = @_;

  return bless { sub => $sub }, $class;
}

1;
