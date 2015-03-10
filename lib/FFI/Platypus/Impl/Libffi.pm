package FFI::Platypus::Impl::Libffi;
use parent 'FFI::Platypus';

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
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

  return unless $address or $address eq '0';

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

sub impl_record_accessor
{
  return \&FFI::Platypus::Record::_accessor;
}

1;
