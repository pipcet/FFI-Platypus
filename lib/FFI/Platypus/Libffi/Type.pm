package FFI::Platypus::Libffi::Type;

use parent -norequire, 'FFI::Platypus::Type';
use Carp qw( croak );

# VERSION

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
    return $class->_new_closure($return_type, @argument_types);
  }

  my $ffi_type;
  my $platypus_type;
  my $size = 0;
  my $classname;
  my $rw = 0;

  if($type =~ /^string(_rw|_ro|\s+ro|\s+rw|\s*\([0-9]+\)|)$/)
  {
    my $extra = $1;
    $ffi_type = 'pointer';
    $platypus_type = 'string';
    $rw = 1 if $extra =~ /rw$/;
    $size = $1 if $extra =~ /\(([0-9]+)\)$/;
  }
  elsif($type =~ /^record\s*\(([0-9:A-Za-z_]+)\)$/)
  {
    $ffi_type = 'pointer';
    $platypus_type = 'record';
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
    $platypus_type = 'pointer';
  }
  elsif($type =~ s/\s+\[([0-9]*)\]$//)
  {
    $ffi_type = $type;
    $platypus_type = 'array';
    $size = $1 ? $1 : 0;
  }
  else
  {
    $ffi_type = $type;
    $platypus_type = 'ffi';
  }

  $class->_new($ffi_type, $platypus_type, $size, $classname, $rw);
}

1;
