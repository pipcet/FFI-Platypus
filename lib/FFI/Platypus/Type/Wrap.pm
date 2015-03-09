package FFI::Platypus::Type::Wrap;
use parent -norequire, 'FFI::Platypus::Type';

sub new {
  my($class, $ffi, $basetype) = @_;

  return bless { underlying_types => [$basetype], ffi => $ffi }, $class;
}

1;
