use strict;
use warnings;
use Test::More tests => 4;
use FFI::Platypus;

my $ffi = FFI::Platypus->new(impl => 'Lazy');

$ffi->lib(undef);
$ffi->attach_method('main', 'strstr', ['void', 'string', 'string'] => 'string');
my $str = 'hi there';
my $substr = 'there';
is main::strstr('main', $str, $substr), 'there';
is main::strstr('main', $str, $substr), 'there';
is main::strstr('main', $str, $substr), 'there';
is 'main'->strstr($str, $substr), 'there';
