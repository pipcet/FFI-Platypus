package platypus_object;
use strict;
use warnings;
use Test::More tests => 20;
use FFI::Platypus;
use FFI::CheckLib;

my $ffi = FFI::Platypus->new;
$ffi->lib(find_lib lib => 'test', symbol => 'f0', libpath => 'libtest');

my $self = bless {}, 'platypus_object';

$ffi->attach_method($self, 'f0' => ['void', 'uint8'] => 'uint8');
$ffi->attach_method($self, [f0=>'f1'] => ['void', 'uint8'] => 'uint8');

is $self->f0(22), 22, 'f0(22) = 22';
is $self->f1(22), 22, 'f1(22) = 22';

my $ffi2 = FFI::Platypus->new;
$ffi2->lib(find_lib lib => 'test', symbol => 'my_atoi', libpath => 'libtest');

my $self2 = bless {}, 'platypus_object';

$ffi2->attach_method($self2, [my_atoi=>'f0'] => ['void', 'string'] => 'int');
$ffi2->attach_method($self2, [f0=>'f1'] => ['void', 'uint8'] => 'uint8');

# this might look nonsensical, but we want to test that we can switch
# between methods properly.

is $self2->f0(256), 256, 'f0(256) = 256';
is $self2->f1(256), 0, 'f1(256) = 0';
is $self->f0(22), 22, 'f0(22) = 22';
is $self->f1(22), 22, 'f1(22) = 22';
is $self->f0(22), 22, 'f0(22) = 22';
is $self->f1(22), 22, 'f1(22) = 22';
is $self->f0(22), 22, 'f0(22) = 22';
is $self->f1(22), 22, 'f1(22) = 22';
is $self2->f0(256), 256, 'f0(256) = 256';
is $self2->f1(256), 0, 'f1(256) = 0';
is $self2->f0(256), 256, 'f0(256) = 256';
is $self2->f1(256), 0, 'f1(256) = 0';
is $self2->f0(256), 256, 'f0(256) = 256';
is $self2->f1(256), 0, 'f1(256) = 0';
is $self2->f0(256), 256, 'f0(256) = 256';
is $self->f0(22), 22, 'f0(22) = 22';
is $self2->f1(256), 0, 'f1(256) = 0';
is $self->f1(22), 22, 'f1(22) = 22';

