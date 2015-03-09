package FFI::Platypus::Impl::Libffi;
use parent 'FFI::Platypus';

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );
use Carp::Always;

use FFI::Platypus::Type::Libffi;
use FFI::Platypus::Function::Libffi;

sub new
{
  my($class, %args) = @_;
  my $abi = delete $args{abi};

  my $self = $class->SUPER::base_new(%args);

  if(defined $abi)
  {
    $self->{impl_abi} = $abi;
  }
  else
  {
    $self->{impl_abi} = -1;
  }

  return $self;
}

=head2 abis

 my $href = $ffi->abis;
 my $href = FFI::Platypus->abis;

Get the legal ABIs supported by your platform and underlying
implementation.  What is supported can vary a lot by CPU and by
platform, or even between 32 and 64 bit on the same CPU and platform.
They keys are the "ABI" names, also known as "calling conventions".  The
values are integers used internally by the implementation to represent
those ABIs.

=cut

sub impl_abis
{
  require FFI::Platypus::ConfigData;
  FFI::Platypus::ConfigData->config("abi");
}

sub impl_abi
{
  my($self, $abi) = @_;

  if(defined $abi) {
    $self->{impl_abi} = $abi;
  }

  $self->{impl_abi};
}

sub impl_new_function
{
  my($self, $address, $ret, @args) = @_;

  FFI::Platypus::Function::Libffi->new($self, $address, $self->{impl_abi}, $ret, @args);
}

sub impl_new_type
{
  my($self, $name, $class) = @_;

  if(!defined($class) or
     $class eq 'FFI::Platypus::Type')
  {
    $class = 'FFI::Platypus::Type::Libffi';
  }

  return $class->new($name, $self);
}

sub impl_new_wrapped_type
{
  my($self, $type, $layer) = @_;

  croak "cannot wrap type in $layer";
}

sub custom_type
{
  my($self, $name, $cb) = @_;
  
  my $type = $cb->{native_type};
  $type ||= 'opaque';
  
  my $argument_count = $cb->{argument_count} || 1;
  
  croak "argument_count must be >= 1"
    unless $argument_count >= 1;
  
  croak "Usage: \$ffi->custom_type(\$name, { ... })"
    unless defined $name && ref($cb) eq 'HASH';
  
  croak "must define at least one of native_to_perl, perl_to_native, or perl_to_native_post"
    unless defined $cb->{native_to_perl} || defined $cb->{perl_to_native} || defined $cb->{perl_to_native_post};
  
  my $type_map = $self->_type_map;
  croak "$type is not a native type" unless defined $type_map->{$type} || $type eq 'string';
  croak "name conflicts with existing type" if defined $type_map->{$name} || defined $self->{types}->{$name};
  
  $self->{types}->{$name} = FFI::Platypus::Type->_new_custom_perl(
    $type_map->{$type},
    $cb->{perl_to_native},
    $cb->{native_to_perl},
    $cb->{perl_to_native_post},
    $argument_count,
  );
  
  $self;
}

sub impl_resolver
{
  my ($self, $path, $resolver) = @_;
  $resolver = $self->{resolver} unless defined $resolver;

  if($resolver =~ /^([^(]*)\((.*)\)$/)
  {
    my($layer, $base) = ($1, $2);
    my $base_resolver = $self->impl_resolver($path, $base);
    my $layered_resolver = FFI::Platypus::_resolver_class($layer)->new($base_resolver);

    return $layered_resolver;
  }

  return FFI::Platypus::_resolver_class($resolver)->new($path);
}

sub impl_find_symbol
{
  my($self, $name, $path, $mangler) = @_;
  my $handle = do { no warnings; $self->{handles}->{$path||0} } || $self->impl_resolver($path);

  unless($handle)
  {
    warn "error loading $path: ", FFI::Platypus::dl::dlerror()
	if $ENV{FFI_PLATYPUS_DLERROR};
    return;
  }
  my $address = $handle->find_symbol($mangler->($name));
  if($address)
  {
    $self->{handles}->{$path||0} = $handle;
    return $address;
  }
  else
  {
    return;
  }
}

1;
