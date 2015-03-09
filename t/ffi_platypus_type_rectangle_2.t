use strict;
use warnings;
use Test::More;
use FFI::Platypus;
use FFI::Platypus::API qw(arguments_set_double);

my $ffi = FFI::Platypus->new;

plan skip_all => 'recursive types not implemented in Libffi'
  if $ffi->impl eq 'Libffi';

plan tests => 2;

$ffi->load_custom_type('::PointerSizeBuffer' => 'buffer_t');
$ffi->custom_type('rectangle_t' => {
  native_type => 'double',
  argument_count => 4,
  perl_to_native => sub {
    my ($x,$y,$width,$height) = ($_[0]->x0, $_[0]->y0, $_[0]->width, $_[0]->height);

    arguments_set_double($_[1], $x);
    arguments_set_double($_[1]+1, $y);
    arguments_set_double($_[1]+2, $width);
    arguments_set_double($_[1]+3, $height);
  },
});

$ffi->lib(undef);
$ffi->attach(snprintf => ['buffer_t', 'string', 'rectangle_t'] => 'int');

my $buf = " " x 1024;
my $n = snprintf($buf, "%f x %f %+f %+f", Rectangle->new(100, 100, 200, 200));
$buf = substr($buf, 0, $n);

is $buf, "100.000000 x 100.000000 +100.000000 +100.000000";

package Rectangle;

sub x0 {
  return $_[0]->{x0};
}

sub y0 {
  return $_[0]->{y0};
}

sub width {
  return $_[0]->{x1} - $_[0]->{x0};
}

sub height {
  return $_[0]->{y1} - $_[0]->{y0};
}

sub new {
  my ($class, $x0, $y0, $x1, $y1) = @_;

  my $self = bless { x0 => $x0, y0 => $y0, x1 => $x1, y1 => $x1 }, $class;

  return $self;
}