package FFI::Platypus::RTypes::Impl;
use parent 'FFI::Platypus';

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );
use Carp::Always;

use FFI::Platypus::RTypes::Type;
use FFI::Platypus::RTypes::Function;
use FFI::Platypus::RTypes::Closure;
use FFI::Platypus::RTypes::Type::Wrap;
use FFI::Platypus::RTypes::Type::FFI;

# for now, we link Rtypes.o into Platypus.so rather than haing a
# per-implementation library.


# require XSLoader;
# XSLoader::load(
#   'FFI::Platypus::RTypes::Impl', eval q{ $VERSION } || do {
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

  return unless $address or $address eq '0';

  require FFI::Platypus::TinyCC::Function;

  FFI::Platypus::TinyCC::Function->new($self, $address, $self->{impl_abi}, $ret, @args);
}

sub impl_new_type
{
  my($self, $name, $class) = @_;

  if(!defined($class) or
     $class eq 'FFI::Platypus::Type')
  {
    $class = 'FFI::Platypus::RTypes::Type';
  }
  elsif($class->isa('FFI::Platypus::Type::FFI'))
  {
    $class = 'FFI::Platypus::RTypes::Type::FFI';
  }
  elsif(!$class->isa('FFI::Platypus::RTypes::Type'))
  {
    croak "type $class is not usable by the RTypes implementation";
  }

  return $class->new($name, $self);
}

sub impl_new_wrapped_type
{
  my($self, $type, $layer) = @_;

  if($layer eq 'wrap' or
     $layer eq 'debug') {
    return FFI::Platypus::RTypes::Type::Wrap->new($self, $type);
  } else {
    croak "cannot wrap type in $layer";
  }
}

sub impl_new_custom_type
{
  my($self, $types, $size, $perl_to_native, $native_to_perl, $perl_to_native_post,
     $in_argument_count, $out_argument_count) = @_;

  return FFI::Platypus::RTypes::Type::CustomPerl->_new_custom_perl(
    $types,
    $size,
    $perl_to_native,
    $native_to_perl,
    $perl_to_native_post,
    $in_argument_count,
    $out_argument_count,
  );
}

sub impl_new_constant_type
{
  my($self, $name, $cb) = @_;

  my $type = $cb->{native_type};
  $type ||= 'opaque';

  my $argument_count = $cb->{argument_count} || 1;

  croak "argument_count must be >= 1"
    unless $argument_count >= 1;

  croak "Usage: \$ffi->constant_type(\$name, { ... })"
    unless ref($cb) eq 'HASH';

  croak "must define a value"
    unless defined $cb->{value};

  my $value = $cb->{value};

  my $type_map = $self->_type_map;
  croak "name conflicts with existing type" if defined $name and ($type_map->{$name} || defined $self->{types}->{$name});

  my @types;
  my $size = 0;
  if (ref $type eq "ARRAY") {
    for my $t (@$type) {
      push @types, $type_map->{$t} || $t;
    }
  } else {
    @types = ($type_map->{$type} || $type) x $argument_count;
  }
  @types = map { $self->_type_lookup($_) } @types;
  for my $type (@types) {
    $size += $type->sizeof;
  }

  if(defined $name)
  {
    $self->{types}->{$name} = FFI::Platypus::RTypes::Type::Constant->_new_constant(
      \@types,
      $size,
      $value,
    );

    $self;
  }
  else
  {
    return FFI::Platypus::RTypes::Type::Constant->_new_constant(
      \@types,
      $size,
      $value,
    );
  }
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
  return \&FFI::Platypus::RTypes::Record::_accessor;
}

1;
