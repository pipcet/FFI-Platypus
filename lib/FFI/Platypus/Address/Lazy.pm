package FFI::Platypus::Address::Lazy;

use strict;
use warnings;
use Carp qw(croak);
use overload
    bool => sub { my $self = shift; $self->realize },
    '""' => sub { my $self = shift; $self->realize },
    '0+' => sub { my $self = shift; $self->realize },
    'eq' => sub {
      no warnings;
      my($self, $other) = @_;

      # if it's a lazy object stringification will force it
      $self = "$self";
      $other = "$other";

      $self eq $other;
    },
    'cmp' => sub {
      no warnings;
      my($self, $other) = @_;

      $self = "$self";
      $other = "$other";

      $self cmp $other;
    },
    '<=>' => sub {
      no warnings;
      my($self, $other) = @_;

      $self = 0+$self;
      $other = 0+$other;

      $self <=> $other;
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

  return unless $self->{realization} or defined $self->{realization} and $self->{realization} eq '0';

  my $real = $self->{realization};
  $real = $real->realize while $real->can('realize');
  $self->{realization} = $real;

  return $self->{realization};
}

sub new
{
  my($class, $sub) = @_;

  return bless { sub => $sub }, $class;
}

1;
