use strict;
use warnings;
use Test::More;
use FFI::Platypus;
use FFI::Platypus::API qw(arguments_set_double);

my $ffi = FFI::Platypus->new;

plan skip_all => 'recursive types not implemented in Libffi'
  if $ffi->impl =~ 'Libffi';

plan skip_all => "requires custom types" unless FFI::Platypus->new->can('custom_type');

plan tests => 2;

$ffi->load_custom_type('::PointerSizeBuffer' => 'buffer_t');
$ffi->custom_type('point_t' => {
  native_type => 'double',
  argument_count => 2,
  perl_to_native => sub {
    my ($self) = @_;

    return ($self->x, $self->y);
  },
});
$ffi->custom_type('rectangle_t' => {
  native_type => ['point_t', 'point_t'],
  argument_count => 2,
  perl_to_native => sub {
    my ($self) = @_;

    return ($self->point0, $self->point1-$self->point0);
  },
});
$ffi->custom_type('format1' => {
  native_type => ['string'],
  in_argument_count => 0,
  argument_count => 1,
  perl_to_native => sub {
    return "%f x %f %+f %+f",
  },
});

$ffi->lib(undef);
$ffi->attach(snprintf => ['buffer_t', 'string', 'rectangle_t'] => 'int');
$ffi->attach([snprintf=>'snprintf_rectangle'] => ['buffer_t', 'format1', 'rectangle_t'] => 'int');

my $buf = " " x 1024;
my $n = snprintf($buf, "%f x %f %+f %+f", Rectangle->new(Point->new(100, 100), Point->new(200, 200)));
$buf = substr($buf, 0, $n);

is $buf, "100.000000 x 100.000000 +100.000000 +100.000000";

$buf = " " x 1024;
$n = snprintf_rectangle($buf, Rectangle->new(Point->new(100, 100), Point->new(200, 200)));
$buf = substr($buf, 0, $n);

is $buf, "100.000000 x 100.000000 +100.000000 +100.000000";

package Point;
use overload "-" => sub { Point->new($_[0]->x - $_[1]->x, $_[0]->y - $_[1]->y); };

sub x {
  return $_[0]->[0];
}

sub y {
  return $_[0]->[1];
}

sub new {
  my($class, $x, $y) = @_;

  return bless [ $x, $y ], $class; 
}

package Rectangle;

sub point0 {
  return $_[0]->[0];
}

sub point1 {
  return $_[0]->[1];
}

sub width {
  my ($self) = @_;

  return $self->point1->x - $self->point0->x;
}

sub height {
  my ($self) = @_;

  return $self->point1->y - $self->point0->y;
}

sub new {
  my ($class, $point0, $point1) = @_;
  
  my $self = bless [$point0, $point1], $class;

  return $self;
}