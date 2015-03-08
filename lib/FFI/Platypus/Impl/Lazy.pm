# WARNING: this implementation of Platypus delays everything it does
# until the last possible moment. That includes parsing types, opening
# libraries, detecting symbols. Thus, an error early in the program
# can lead to an error message much later, and that might be
# confusing.

package FFI::Platypus::Impl::Lazy;
use parent -norequire,'FFI::Platypus';

use strict;
use warnings;

use FFI::Platypus::Function::Lazy;
use FFI::Platypus::Type::Lazy;
use FFI::Platypus::Address::Lazy;

sub new
{
  my($class, %args) = @_;

  my $base = delete $args{base};
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

sub impl_abis
{
  my($self) = @_;

  return $self->{impl_base}->impl_abis;
}

sub impl_new_function
{
  my($self, $address, $ret, @args) = @_;

  return FFI::Platypus::Function::Lazy->new($self->{impl_base}, $address, $ret, @args);
}

sub impl_new_type
{
  my($self, $name) = @_;

  return $self->{impl_base}->impl_new_type($name);
}

sub impl_new_custom_type
{
  my($self, $types, @args) = @_;

  return FFI::Platypus::Type::Lazy->new(
    sub {
      my @types = map { $_->can('realize') ? $_->realize : $_ } @$types;
      return($self->{impl_base}->impl_new_custom_type(\@types, @args)); }
  );
}

sub impl_find_symbol
{
  my($self, $name, $path, $mangler) = @_;

  return $self->{impl_base}->impl_find_symbol($name, $path, $mangler);
}

sub find_symbol
{
  my($self, $name) = @_;

  my @lib = @{$self->{lib}};

  unless(defined $self->{mangler})
  {
    my $class = FFI::Platypus::_lang_class($self->{lang});
    if($class->can('mangler'))
    {
      $self->{mangler} = $class->mangler($self->lib);
    }
    else
    {
      $self->{mangler} = sub { $_[0] };
    }
  }

  my $mangler = $self->{mangler};

  return FFI::Platypus::Address::Lazy->new(sub
  {
    foreach my $path (@lib)
    {
      my $address = $self->impl_find_symbol($name, $path, $mangler);

      return $address if $address;
    }
  });
}

1;
