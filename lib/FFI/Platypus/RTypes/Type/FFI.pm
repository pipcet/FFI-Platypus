package FFI::Platypus::RTypes::Type::FFI;
use parent 'FFI::Platypus::Type::FFI';
use Carp qw(croak);

sub count_native_arguments
{
  1;
}

sub perl_to_native_precondition_cexpr
{
  my($self, $expr) = @_;

  return [undef, "SvOK(${expr})"];
}

sub perl_to_native_cexpr
{
  my($self, $expr) = @_;
  my $meta = $self->meta;

  if($meta->{size} eq '8') {
    return ['long int', "SvIV(${expr})"];
  } elsif($meta->{size} eq '4' and $meta->{sign}) {
    return ['int', "SvIV(${expr})"];
  }

  return undef;
}

sub native_to_perl_cexpr
{
  my($self, $expr) = @_;
  my $meta = $self->meta;

  if($meta->{size} eq '8' and $meta->{sign}) {
    return ['sint64_t', "SvIV(${expr})"];
  } elsif($meta->{size} eq '4' and $meta->{sign}) {
    return ['int', "SvIV(${expr})"];
  }

  return undef;
}

sub DESTROY
{
}

1;
