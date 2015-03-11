package FFI::Platypus::Impl::Debug;
use parent -norequire, 'FFI::Platypus';

use strict;
use warnings;
use vars qw($AUTOLOAD);

use Data::Dumper;


sub impl_new_function {
}

sub AUTOLOAD
{
  my $method = $AUTOLOAD;
  my $self = shift;
  my @args = @_;

  $method =~ s/.*:://;

  my $ret = ref($self) ? $self->{impl_base}->$method(@args) : FFI::Platypus->new(@args);

  warn Dumper(\@args) . " -> " . Dumper($ret) . "\n";

  return $ret;
}

for my $method (keys %FFI::Platypus::) {
  next unless $method =~ /^[a-z]/;
  next if $method =~ /::$/;
  eval qq{no warnings 'redefine'; sub FFI::Platypus::Impl::Debug::$method { local \$AUTOLOAD="$method"; my \$self = shift; \$self->AUTOLOAD(\@_); }};
  die $@ if $@;
}

sub can {
  my($self, $method) = @_;

  return (ref($self) && $self->{impl_base}->can($method)) ||
	 $self->SUPER::can($method);
}

sub new
{
  my($class, %args) = @_;

  my $base = delete $args{impl};
  $base = FFI::Platypus::default_impl() unless defined $base;

  my $self = $class->SUPER::base_new(%args);

  # my %types;
  # tie %types, 'FFI::Platypus::Lazy::Types', $self->{types};

  # $self->{impl_base} = FFI::Platypus->new(impl=>$base, types => \%types);
  $self->{impl_base} = FFI::Platypus->new(impl=>$base);
  return $self;
}


1;
