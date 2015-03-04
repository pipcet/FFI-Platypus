package FFI::Platypus::Impl::LibffiPerl;

require XSLoader;
XSLoader::load(
  'FFI::Platypus::Impl::LibffiPerl', eval q{ $VERSION } || do {
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

1;


package FFI::Platypus::Impl::LibffiPerl::Type;

# VERSION

package FFI::Platypus::Impl::LibffiPerl::Type::String;

# VERSION

use parent -norequire, 'FFI::Platypus::Impl::LibffiPerl::Type';

1;
