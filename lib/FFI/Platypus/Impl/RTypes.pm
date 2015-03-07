package FFI::Platypus::Impl::RTypes;

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );
use Carp::Always;

require XSLoader;
XSLoader::load(
  'FFI::Platypus::Impl::RTypes', eval q{ $VERSION } || do {
    # this is for testing without dzil
    # it expects MYMETA.json for FFI::Platypus
    # to be in the current working directory.
    require JSON::PP;
    my $fh;
    open($fh, '<', 'MYMETA.json') || die "unable to read MYMETA.json";
    my $config = JSON::PP::decode_json(do { local $/; <$fh> });
    close $fh;
    $config->{version};
  }
);

sub new
{
  my($class, %args) = @_;
  my $self = bless {}, $class;

  my $abi = delete $args{abi};

  if(defined $abi)
  {
    $self->{abi} = $abi;
  }
  else
  {
    $self->{abi} = -1;
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

sub abis
{
  require FFI::Platypus::ConfigData;
  FFI::Platypus::ConfigData->config("abi");
}

sub abi
{
  my($self, $abi) = @_;

  $self->{abi} = $abi;

  $self;
}

sub new_function
{
  my($self, $address, $ret, @args) = @_;

  warn "address $address";
  FFI::Platypus::Function->new($self, $address, $self->{abi}, $ret, @args);
}
