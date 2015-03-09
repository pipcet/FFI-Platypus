package FFI::Platypus::Type::SV;
use parent -norequire, 'FFI::Platypus::Type::FFI';

sub new {
  my($class) = @_;

  # we know what we're doing.
  return bless(FFI::Platypus::Type::FFI->new('opaque'), $class);
}

1;
