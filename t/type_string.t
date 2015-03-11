use strict;
use warnings;
use Test::More tests => 19;
use FFI::CheckLib;
use FFI::Platypus::Declare
  'string', 'int', 'void',
  ['string(10)' => 'string_10'],
  ['string(5)'  => 'string_5'];

lib find_lib lib => 'test', symbol => 'f0', libpath => 'libtest';

attach 'string_matches_foobarbaz'     => [string] => int;
attach 'string_return_foobarbaz'      => []       => string;
attach [pointer_null => 'null']       => []       => string;
attach [pointer_is_null => 'is_null'] => [string] => int;

ok string_matches_foobarbaz("foobarbaz"), "string_matches_foobarbaz(foobarbaz) = true";
ok !string_matches_foobarbaz("x"), "string_matches_foobarbaz(foobarbaz) = false";
is string_return_foobarbaz(), "foobarbaz", "string_return_foobarbaz() = foobarbaz";

is null(), undef, 'null() = undef';
is is_null(undef), 1, 'is_null(undef) = 1';
is is_null(), 1, 'is_null() = 1';
is is_null("foo"), 0, 'is_null("foo") = 0';

attach [string_set_closure => 'set_closure']   => ['(string)->void'] => void;
attach [string_call_closure => 'call_closure'] => [string]=>void;

my $save = 1;
my $closure = closure { $save = $_[0] };

set_closure($closure);
call_closure("hey there");
is $save, "hey there", "\$save = hey there";

call_closure(undef);
is $save, undef, "\$save = undef";


attach ['string_matches_foobarbaz' => 'fixed_input_test'] => ['string_10'] => int;
attach ['pointer_is_null'          => 'fixed_input_is_null'] => ['string_10'] => int;

is fixed_input_test("foobarbaz\0"), 1, "fixed_input_test(foobarbaz\\0)";
is fixed_input_is_null(undef), 1, "fixed_input_is_null(undef)";

attach string_fixed_test => [int] => 'string_5';

is string_fixed_test(0), "zero ", "string_fixed_text(0) = zero";
is string_fixed_test(1), "one  ", "string_fixed_text(1) = one";
is string_fixed_test(2), "two  ", "string_fixed_text(2) = two";
is string_fixed_test(3), "three", "string_fixed_text(3) = three";

attach [pointer_null => 'fixed_output_null'] => [] => 'string_5';

is fixed_output_null(), undef, 'fixed_output_null()';

attach [string_set_closure => 'set_closure_fixed'] => ['(string_5)->void'] => void;

my $closure_fixed = closure { $save = $_[0] };

set_closure_fixed($closure_fixed);
call_closure("zero one  two  three");
is $save, "zero ", "save=zero ";

SKIP: {
  skip "no custom types" => 2 unless FFI::Platypus->new->can('custom_type');
  skip "no custom strings in Libffi", 2 if FFI::Platypus->new->impl =~ 'Libffi';

  subtest 'custom type input' => sub {
    plan tests => 1;
    custom_type type1 => { native_type => 'string', perl_to_native => sub { $_[0] x 3 } };
    attach_cast custom1 => 'type1' => 'string';
    is custom1("x"), "xxx";
  };

  subtest 'strings as char arrays' => sub {
    plan tests => 1;
    custom_type type2 => { native_type => 'uint8[3]', perl_to_native => sub { return [ map { ord $_ } split('', $_[0]) ] } };
    attach_cast custom2 => 'type2' => 'uint8[3]';
    like join(":", map { chr($_) } @{custom2("abc")}), qr{^a:b:c$};
  };
}
