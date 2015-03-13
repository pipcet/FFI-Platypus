package FFI::Platypus::RTypes::Type::FFI;
use parent 'FFI::Platypus::Type::FFI';
use Carp qw(croak);

sub count_native_arguments
{
  1;
}

sub DESTROY
{
}

1;
