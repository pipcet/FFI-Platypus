use strict;
use warnings;
use Test::More tests => 2;
use File::Spec;
use FFI::Platypus;
use FFI::CheckLib;

subtest external => sub {
  plan tests => 3;

  my $ffi = FFI::Platypus->new;
  $ffi->lib(find_lib lib => 'test', symbol => 'f0', libpath => 'libtest');

  my $good = $ffi->find_symbol('f0');
  ok $good, "ffi.find_symbol(f0) = $good";

  SKIP: {
    skip "lazy bogus symbols are defined" => 2 if FFI::Platypus->new->impl eq 'Lazy';
    my $bad  = $ffi->find_symbol('bogus');
    is $bad, undef, 'ffi.find_symbol(bogus) = undef';
    is !$bad, 1, 'ffi.find_symbol(bogus) false';
  }
};

subtest internal => sub {
  plan tests => 3;
  
  my $ffi = FFI::Platypus->new;
  $ffi->lib(undef);
  
  my $good = $ffi->find_symbol('printf');
  ok $good, "ffi.find_symbol(printf) = $good";

  my $bad  = $ffi->find_symbol('bogus');
  SKIP: {
    skip "invalid lazy functions are false but defined", 1 if $ffi->impl eq 'Lazy';
    is $bad, undef, 'ffi.find_symbol(bogus) = undef';
  };
  is !$bad, 1, 'ffi.find_symbol(bogus) false';
};
