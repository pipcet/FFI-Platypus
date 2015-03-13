package FFI::Platypus::RTypes::Function;
use parent -norequire, 'FFI::Platypus::Function';

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );

sub xs_cdecl
{
  my($self, $name) = @_;
  my $i = 0;
  my @argcond;
  my @argexpr;
  my $retexpr;

  for my $argtype (@{$self->{argument_types}})
  {
    if($argtype->can('perl_to_native_precondition')) {
      my $cexpr = $argtype->perl_to_native_precondition("ST($i)");

      return undef unless $cexpr;

      push @argcond, $cexpr;
    }

    $i++;
  }

  $i = 0;
  for my $argtype (@{$self->{argument_types}})
  {
    if($argtype->can('perl_to_native_cexpr')) {
      my $cexpr = $argtype->perl_to_native_cexpr("ST($i)");

      return undef unless $cexpr;

      push @argexpr, $cexpr;
    }
    else
    {
      return undef;
    }

    $i++;
  }

  my $rettype = $self->{return_type};
  if($rettype->can('native_to_perl_cexpr'))
  {
    $retexpr = $rettype->native_to_perl_cexpr;

    return undef unless $retexpr;

    my $rettype = $retexpr->[0];
    my $retsigil = "i";
    my $cond = join("||", map { $_->[1] } @argcond);
    my $args = join(", ", map { $_->[1] } @argexpr);
    my $argtypes = join(", ", map { $_->[0] } @argexpr);
    my $address = $self->{address};
    my $function = "${rettype} (\*f)(${argtypes}) = ${address}UL";
    my $fallback_stmt = "*(int *)0 = 0;";
    my $items = scalar @argexpr;

    return qq{
XS(${name})
{
  dVAR; dXSARGS; dXSTARG;
  ${function};

  ${rettype} RETVAL;

  if(items != ${items})
    ${fallback_stmt}
  RETVAL = f(${args});
  SPAGAIN;
  XSprePUSH;
  PUSH${retsigil}(RETVAL);
  XSRETURN(1);
}
};
  }

  return undef;
}

1;
