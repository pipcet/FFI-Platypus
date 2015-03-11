package main;
use Test::More;

eval { $ffi->type('SV'); };
plan(skip_all => "SV type required")
  if $@ or !$ffi->type('SV');

FFI::Platypus->new->can('attach_method') or
  plan skip_all => "attach_method not defined";

plan tests => 8;

package platypus_object;
use strict;
use warnings;
use FFI::Platypus;
use FFI::CheckLib;

my $ffi = FFI::Platypus->new;
$ffi->lib(find_lib lib => 'test', symbol => 'object_new', libpath => 'libtest');

sub new {
  my($class,$x,$y) = @_;
  my $address = $class->_new($x,$y);
  my $self = bless { address => $address, ffi => $ffi }, 'platypus_object';

  $ffi->attach_method([$self=>$address], [object_method=>'method'], ['object','int']=>'int');
  # tempting, but hard to get to work right in global destruction.
  # $ffi->attach_method([$self=>$address], [object_destroy=>'DESTROY'], ['object']=>'void');

  return $self;
}

$ffi->type('opaque' => 'object');
$ffi->attach_method('platypus_object', [object_new => '_new'], ['void','int','string'] => 'object');

package main;

my $str1 = 'oxymoron';
my $str2 = 'rad';

my $object = platypus_object->new(7,$str1);
my $object2 = platypus_object->new(3,$str2);

is $object->method(3), 106;
is $object->method(2), 126;
is $object2->method(1), 98;
is $object2->method(2), 103;
is $object->method(3), 106;
is $object2->method(1), 98;
is $object->method(2), 126;
is $object2->method(2), 103;
