package FFI::Platypus::Type::FFI;
use parent -norequire, 'FFI::Platypus::Type';
use Carp qw(croak);

# override this for FFI types that are allocated, such as structs.
sub DESTROY
{
}

1;
