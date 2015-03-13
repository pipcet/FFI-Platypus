package FFI::Platypus;

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );

package FFI::Platypus::RTypes::Type;
use parent -norequire, 'FFI::Platypus::Type';
use FFI::Platypus::RTypes::Type::FFI;
use FFI::Platypus::RTypes::Type::SV;

use warnings;
use strict;
use Carp qw(croak);

sub new
{
  my($class, $type, $platypus) = @_;

  # the platypus object is only needed for closures, so
  # that it can lookup existing types.

  if($type =~ m/^\((.*)\)-\>\s*(.*)\s*$/)
  {
    croak "passing closure into a closure not supported" if $1 =~ /(\(|\)|-\>)/;
    my @argument_types = map { $platypus->_type_lookup($_) } map { s/^\s+//; s/\s+$//; $_ } split /,/, $1;
    my $return_type = $platypus->_type_lookup($2);
    $class .= "::Closure";
    return $class->_new_closure($return_type, @argument_types);
  }

  my $ffi_type;
  my $platypus_type;
  my $subtype;
  my $size = 0;
  my $classname;
  my $rw = 0;

  if($type =~ /^string(_rw|_ro|\s+ro|\s+rw|\s*\([0-9]+\)|)$/)
  {
    my $extra = $1;
    $ffi_type = 'pointer';
    $platypus_type = 'String';
    $rw = 1 if $extra =~ /rw$/;
    $size = $1 if $extra =~ /\(([0-9]+)\)$/;
  }
  elsif($type =~ /^(debug|wrap)\((.*)\)$/)
  {
    my $layer = $1;
    my $basename = $2;
    my $basetype = $platypus->_type_lookup($2);

    warn $platypus->impl_new_wrapped_type($basetype, $layer);;
    return $platypus->impl_new_wrapped_type($basetype, $layer);
  }
  elsif($type =~ /^record\s*\(([0-9:A-Za-z_]+)\)$/)
  {
    $ffi_type = 'pointer';
    $platypus_type = 'Record';
    if($1 =~ /^([0-9]+)$/)
    {
      $size = $1;
    }
    else
    {
      $classname = $1;
      unless($classname->can('ffi_record_size') || $classname->can('_ffi_record_size'))
      {
	eval qq{ use $classname };
	warn "error requiring $classname: $@";
      }
      if($classname->can('ffi_record_size'))
      {
	$size = $classname->ffi_record_size;
      }
      elsif($classname->can('_ffi_record_size'))
      {
	$size = $classname->_ffi_record_size;
      }
      else
      {
	croak "$classname has not ffi_record_size or _ffi_record_size method";
      }
    }
  }
  elsif($type =~ s/\s+\*$//) {
    $ffi_type = $type;
    $platypus_type = 'Pointer';
  }
  elsif($type =~ s/\s+\[([0-9]*)\]$//)
  {
    $ffi_type = $type;
    $platypus_type = 'Array';
    $size = $1 ? $1 : 0;
  }
  elsif($type eq "SV")
  {
    return FFI::Platypus::RTypes::Type::SV->new;
  }
  else
  {
    $ffi_type = $type;
    $platypus_type = 'FFI';
    if ($type eq "longdouble" or
	$type eq "complex_float" or
	$type eq "complex_double")
    {
      $platypus_type = 'ExoticFloat';
      $ffi_type = $type;
      $subtype = 'ffi';
    }
    else
    {
      return FFI::Platypus::RTypes::Type::FFI->new($type);
    }
  }

  $subtype = lc $platypus_type unless defined $subtype;

  $class .= "::$platypus_type";

  $class->_new($ffi_type, $subtype, $size, $classname, $rw);
}

sub argument_count
{
  my($self) = @_;
  my $meta = $self->meta;

  return $meta->{argument_count} ? $meta->{argument_count} : 1;
}

sub count_native_arguments
{
  my($self) = @_;

  return 1;
}

sub DESTROY
{
}

package FFI::Platypus::RTypes::Type::String;
use parent -norequire, 'FFI::Platypus::RTypes::Type';

sub perl_to_native_precondition_cexpr
{
  my($self, $expr) = @_;

  return ['char *', "SvOK(${expr})"];
}

sub perl_to_native_cexpr
{
  my($self, $expr) = @_;

  return ['char *', "SvPV_nolen(${expr})"];
}

package FFI::Platypus::RTypes::Type::Pointer;
use parent -norequire, 'FFI::Platypus::RTypes::Type';

sub count_native_arguments
{
  my($self) = @_;

  return 2;
}

package FFI::Platypus::RTypes::Type::Array;
use parent -norequire, 'FFI::Platypus::RTypes::Type';

package FFI::Platypus::RTypes::Type::Closure;
use parent -norequire, 'FFI::Platypus::RTypes::Type';

sub meta {
  my ($self) = @_;
  my $meta = $self->SUPER::meta;

  my $signature = [];
  my $argument_types = [];
  for my $argument_type (@{$self->{argument_types}}) {
    push @$argument_types, $argument_type->meta;
  }
  $signature = [$argument_types, $self->{return_type}->meta];

  $meta->{signature} = $signature;

  return $meta;
}

package FFI::Platypus::RTypes::Type::Constant;
use parent -norequire, 'FFI::Platypus::RTypes::Type';

package FFI::Platypus::RTypes::Type::CustomPerl;
use parent -norequire, 'FFI::Platypus::RTypes::Type';

sub count_native_arguments
{
  my($self) = @_;
  my $count = 0;

  for my $type (@{$self->{underlying_types}}) {
    $count += $type->count_native_arguments;
  }

  return $count;
}

sub meta {
  my ($self) = @_;
  my $meta = $self->SUPER::meta;

  $meta->{type} = "custom_perl";

  if(exists($self->{perl_to_native})) {
    $meta->{custom_perl_to_native} = $self->{perl_to_native};
  }

  if(exists($self->{native_to_perl})) {
    $meta->{custom_native_to_perl} = $self->{native_to_perl};
  }

  if(exists($self->{perl_to_native})) {
    $meta->{custom_perl_to_native_post} = $self->{perl_to_native_post};
  }

  if(exists($self->{argument_count})) {
    $meta->{argument_count} = $self->{argument_count} + 1;
  } else {
    $meta->{argument_count} = 1;
  }

  return $meta;
}

package FFI::Platypus::RTypes::Type::Record;
use parent -norequire, 'FFI::Platypus::RTypes::Type';

package FFI::Platypus::RTypes::Type::Struct;
use parent -norequire, 'FFI::Platypus::RTypes::Type';

package FFI::Platypus::RTypes::Type::ExoticFloat;
use parent -norequire, 'FFI::Platypus::RTypes::Type';

package FFI::Platypus::RTypes::Type::SV;
use parent -norequire, 'FFI::Platypus::Type::SV', 'FFI::Platypus::RTypes::Type';

1;
