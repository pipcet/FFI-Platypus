use strict;
use warnings;
use Test::More;
use FFI::Platypus;
use FFI::Platypus::API qw(arguments_set_double);
use FFI::CheckLib;
use FFI::Platypus::Memory qw( malloc );

my $ffi = FFI::Platypus->new;

use FFI::Platypus::Declare
  qw( void opaque string ),
  [ '::PointerSizeBuffer' => 'buffer_t2' ];

plan skip_all => "requires custom types" unless FFI::Platypus->new->can('custom_type');

plan tests => 5;

load_custom_type '::PointerSizeBuffer' => 'buffer_t';

lib undef;
attach memcpy => [opaque, 'buffer_t'] => void;

my $string  = "luna park\0";
my $pointer = malloc length $string;
memcpy($pointer, $string);

my $string2 = cast opaque => string, $pointer;

is $string2, 'luna park';

SKIP: {

  eval { attach snprintf => ['buffer_t', string ] => 'int' };
  skip "test require working snprintf", 2 if $@;

  is snprintf($string2, "this is a very long string"), 26;
  is $string2, "this is \000";

}

lib find_lib lib => 'test', symbol => 'f0', libpath => 'libtest';

attach memcmp4 => ['buffer_t', 'buffer_t'] => 'int';

my $str1 = "test";
my $str2 = "test2";
is !!memcmp4($str1, $str2), 1;
is memcmp4($str1, $str1), 0;
