# WARNING: this implementation of Platypus delays everything it does
# until the last possible moment. That includes parsing types,
# defining types, opening libraries, detecting symbols, and even
# looking up ABIs. Thus, an error early in the program can lead to an
# error message much later, and that might be confusing.

package FFI::Platypus::Impl::Lazy;
use parent -norequire,'FFI::Platypus';

use FFI::Platypus::Function::Lazy;

sub new
{
  my($class, %args) = @_;

  my $base = delete $args{$base};
  $base = 'RTypes' unless defined $base;

  my $self = $class->SUPER::base_new(%args);

  $self->{impl_base} = FFI::Platypus::_impl_class($base)->new;

  return $self;
}

sub abi
{
  my($self, $abi) = @_;

  $self->{impl_abi} = $abi;
}

sub impl_new_function
{
  my($self, $address, $ret, @args) = @_;

  return FFI::Platypus::Function::Lazy->new($self->{impl_base}, $address, $ret, @args);
}

sub impl_new_type
{
  my($self, $name) = @_;

  return FFI::Platypus::Type->new($name, $self);
}

}

1;
