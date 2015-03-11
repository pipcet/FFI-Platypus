package FFI::Platypus::RTypes::Closure;
use parent -norequire, 'FFI::Platypus::Closure';

sub add_data { FFI::Platypus::Closure::add_data(@_) }
sub remove_data { FFI::Platypus::Closure::add_data(@_) }

1;
