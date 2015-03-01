use strict;
use warnings;
use Test::More tests => 1;
use FFI::Platypus;
use FFI::Platypus::API qw(arguments_set_double);

my $ffi = FFI::Platypus->new;

eval {
  arguments_set_double(0, 0);
};

like $@, qr{^Not in custom type handler};
