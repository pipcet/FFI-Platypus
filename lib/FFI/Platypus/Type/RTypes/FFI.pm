package FFI::Platypus::Type::RTypes::FFI;
use parent 'FFI::Platypus::Type::FFI', 'FFI::Platypus';
use Carp qw(croak);

sub count_native_arguments
{
  1;
}

sub DESTROY
{
}

1;
