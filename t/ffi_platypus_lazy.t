use strict;
use warnings;
use Test::More;
use FFI::Platypus;

my $ffi = FFI::Platypus->new;

plan skip_all => "no lazy implementation of Libffi yet"
  if $ffi->impl eq 'Libffi';

$ffi = FFI::Platypus->new(impl=>'Lazy');

plan tests => 4;
$ffi->lib(undef);
$ffi->attach_method('main', 'strstr', ['void', 'string', 'string'] => 'string');
my $str = 'hi there';
my $substr = 'there';
is main::strstr('main', $str, $substr), 'there';
is main::strstr('main', $str, $substr), 'there';
is main::strstr('main', $str, $substr), 'there';
is 'main'->strstr($str, $substr), 'there';
