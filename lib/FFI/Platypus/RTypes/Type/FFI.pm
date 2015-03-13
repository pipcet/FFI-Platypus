package FFI::Platypus::RTypes::Type::FFI;
use parent 'FFI::Platypus::Type::FFI';
use Carp qw(croak);

sub count_native_arguments
{
  1;
}

use Data::Dumper;

sub perl_to_native_cexpr
{
  my($self, $expr) = @_;
  my $meta = $self->meta;

  warn Dumper($meta);

  if($meta->{size} eq '8' and $meta->{sign}) {
    return ['sint64_t', "SvIV(${expr})"];
  } elsif($meta->{size} eq '4' and $meta->{sign}) {
    return ['int', "SvIV(${expr})"];
  }

  return undef;
}

sub native_to_perl_cexpr
{
  my($self, $expr) = @_;
  my $meta = $self->meta;

  warn Dumper($meta);

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
