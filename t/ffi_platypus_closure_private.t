use strict;
use warnings;
use Test::More;
use FFI::Platypus;

BEGIN
{
  plan skip_all => 'internal APIs changed';
}

plan tests => 2;

my $closure = FFI::Platypus::Closure->new(sub { $_[0] + 1});
isa_ok $closure, 'FFI::Platypus::Closure';
is $closure->(1), 2, 'closure.(1) = 2';
