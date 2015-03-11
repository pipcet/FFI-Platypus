package FFI::Platypus::Impl::Debug;
use parent -norequire, 'FFI::Platypus';

use strict;
use warnings;
use vars qw($AUTOLOAD);

use Data::Dumper;


sub impl_new_function {
  my($self, @args) = @_;
  local $AUTOLOAD = 'impl_new_function';
  $self->AUTOLOAD(@args);
}

sub AUTOLOAD
{
  my $method = $AUTOLOAD;
  my $self = shift;
  my @args = @_;

  $method =~ s/.*:://;

  eval qq{package } . caller;
  die $@ if $@;
  my @ret = ref($self) ? $self->{impl_base}->$method(@args) : FFI::Platypus->new(impl=>'RTypes')->$method(@args);
  eval qq{package FFI::Platypus::Impl::Debug};

  #warn "$method: " . Dumper(\@args) . " -> " . Dumper(\@ret) . "\n";

  return wantarray ? (@ret) : $ret[0];
}

for my $method (keys %FFI::Platypus::) {
  next unless $method =~ /^[a-z]/;
  next if $method =~ /::$/;
  # special methods need access to caller()
  next if $method =~ /^attach/ or $method eq 'package';
  next if $method eq "new";
  next if exists $FFI::Platypus::Impl::Debug::{$method};
  eval qq{no warnings 'redefine'; sub FFI::Platypus::Impl::Debug::$method { local \$AUTOLOAD="$method"; my \$self = shift; \$self->AUTOLOAD(\@_); }};
  die $@ if $@;
}

sub attach {
  my($self, @args) = @_;
  my @caller_data = caller;
  $self->_attach(\@caller_data, @args);
}

sub can {
  my($self, $method) = @_;

  return (ref($self) && $self->{impl_base}->can($method)) ||
	 $self->SUPER::can($method);
}

sub is_lazy {
  my($self) = @_;

  return 1; # XXX hack to skip some tests

  return $self->{impl_base}->is_lazy if ref($self);

  return 0;
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
  delete $args{impl_name};
  $self->{impl_base} = FFI::Platypus->new(impl=>$base, types=>$self->{types}, %args);
  return $self;
}


1;
