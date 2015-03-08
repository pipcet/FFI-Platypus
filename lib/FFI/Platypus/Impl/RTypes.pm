package FFI::Platypus::Impl::RTypes;
use parent 'FFI::Platypus';

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );
use Carp::Always;

# for now, we link Rtypes.o into Platypus.so rather than haing a
# per-implementation library.


# require XSLoader;
# XSLoader::load(
#   'FFI::Platypus::Impl::RTypes', eval q{ $VERSION } || do {
#     # this is for testing without dzil
#     # it expects MYMETA.json for FFI::Platypus
#     # to be in the current working directory.
#     require JSON::PP;
#     my $fh;
#     open($fh, '<', 'MYMETA.json') || die "unable to read MYMETA.json";
#     my $config = JSON::PP::decode_json(do { local $/; <$fh> });
#     close $fh;
#     $config->{version};
#   }
# );

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

  FFI::Platypus::Function::RTypes->new($self, $address, $self->{impl_abi}, $ret, @args);
}

sub impl_new_type
{
  my($self, $name) = @_;

  return FFI::Platypus::Type::RTypes->new($name, $self);
}

sub impl_new_custom_type
{
  my($self, $types, $size,     $perl_to_native, $native_to_perl, $perl_to_native_post,
     $in_argument_count, $out_argument_count) = @_;

  return FFI::Platypus::Type::RTypes::CustomPerl->_new_custom_perl(
    $types,
    $size,
    $perl_to_native,
    $native_to_perl,
    $perl_to_native_post,
    $in_argument_count,
    $out_argument_count,
  );
}

sub impl_find_symbol
{
  my($self, $name, $path, $mangler) = @_;
  my $handle = do { no warnings; $self->{handles}->{$path||0} } || FFI::Platypus::_resolver_class($self->{resolver})->new($path);
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
