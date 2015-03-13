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
  my @argexpr;
  my $retexpr;

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
    my $args = join(", ", map { $_->[1] } @argexpr);
    my $argtypes = join(", ", map { $_->[0] } @argexpr);
    my $address = $self->{address};
    my $function = "((${rettype} (\*)(${argtypes}))(unsigned long)${address}UL)";
    my $fallback_stmt = "*(int *)0 = 0;";
    my $items = scalar @argexpr;

    return qq{
XS(${name})
{
  dVAR; dXSARGS; dXSTARG;

  ${rettype} RETVAL;

  if(items != ${items})
    ${fallback_stmt}
  RETVAL = ${function}(${args});
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
