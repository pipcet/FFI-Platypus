package FFI::Platypus::Impl::RTypes;

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );

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

  return $self;
}
