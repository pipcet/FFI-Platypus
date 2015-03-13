# WARNING: this implementation of Platypus delays everything it does
# until the last possible moment. That includes parsing types, opening
# libraries, detecting symbols. Thus, an error early in the program
# can lead to an error message much later, and that might be
# confusing.

package FFI::Platypus::Lazy::Impl;
use parent -norequire,'FFI::Platypus';

use strict;
use warnings;

use FFI::Platypus::Lazy::Function;
use FFI::Platypus::Lazy::Type;
use FFI::Platypus::Lazy::Address;
use FFI::Platypus::Lazy::Types;
use FFI::Platypus::Lazy::TypeMap;

use FFI::Platypus::RTypes::Impl;

sub new
{
  my($class, %args) = @_;

  my $base = delete $args{impl};
  $base = FFI::Platypus::default_impl() unless defined $base;

  my $self = $class->SUPER::base_new(%args);

  my %types;
  tie %types, 'FFI::Platypus::Lazy::Types', $self->{types};

  $self->{impl_base} = FFI::Platypus->new(impl=>$base, types => \%types);

  return $self;
}

sub _new_type_map
{
  my($self, $ref) = @_;
  my %hash;

  tie %hash, 'FFI::Platypus::Lazy::TypeMap', $ref, $self->{impl_base};

  return \%hash;
}

sub abi
{
  my($self, $abi) = @_;

  $self->{impl_abi} = $abi;
}

sub impl_abis
{
  my($self) = @_;

  if(ref $self)
  {
    return $self->{impl_base}->impl_abis;
  }
  else
  {
    # XXX better than nothing.
    return FFI::Platypus::RTypes::Impl->impl_abis;
  }
}

sub impl_new_function
{
  my($self, $address, $ret, @args) = @_;

  return FFI::Platypus::Lazy::Function->new($self->{impl_base}, $address, $ret, @args);
}

sub impl_new_type
{
  my($self, $name, $class) = @_;

  return FFI::Platypus::Lazy::Type->new(
    sub {
      $self->{impl_base}->impl_new_type($name, $class);
    }
  );
}

sub impl_new_custom_type
{
  my($self, $types, @args) = @_;
  my @types = @$types;

  return FFI::Platypus::Lazy::Type->new(
    sub
    {
      @types = map { $_->can('realize') ? $_->realize : $_ } @types;
      return($self->{impl_base}->impl_new_custom_type(\@types, @args));
    }
  );
}

sub impl_new_constant_type
{
  my($self, $name, @args) = @_;

  my $ret = FFI::Platypus::Lazy::Type->new(
    sub
    {
      $self->{impl_base}->impl_new_constant_type(undef, @args);
    }
  );

  if(defined $name) {
    $self->{types}->{$name} = $ret
  }

  return $ret;
}

sub impl_find_symbol
{
  my($self, $name, $path, $mangler) = @_;

  return FFI::Platypus::Lazy::Address->new(
    sub
    {
      $self->{impl_base}->impl_find_symbol($name, $path, $mangler);
    }
  );
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

  return FFI::Platypus::Lazy::Address->new(sub
  {
    foreach my $path (@lib)
    {
      my $address = $self->impl_find_symbol($name, $path, $mangler);

      return $address if $address;
    }
  });
}

sub impl_record_accessor
{
  my($self) = @_;

  return sub {
    my($perl_name, $path_name, $type, $offset) = @_;

    $type = $type->realize if $type->can('realize');

    return $self->{impl_base}->impl_record_accessor->($perl_name, $path_name, $type, $offset);
  };
}

sub is_lazy
{
  1; # that's the point.
}

sub can
{
  my($self, $method) = @_;

  return undef if $method eq 'custom_type' and not $self->{impl_base}->can('impl_new_custom_type');
  return undef if $method eq 'impl_new_custom_type' and not $self->{impl_base}->can('impl_new_custom_type');

  return $self->SUPER::can($method);
}

1;
