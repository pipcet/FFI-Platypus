use strict;
use warnings;
use FFI::Platypus::Memory qw( malloc free );
use Test::More tests => 4;

do {
  package
    Foo1;
  
  use FFI::Platypus::Record;
  
  record_layout(
    uint8 => 'first',
    uint32 => 'second',
  );

};

subtest 'integer accessor' => sub {
  plan tests => 6;

  my $foo = Foo1->new( first => 1, second => 2 );
  isa_ok $foo, 'Foo1';
  
  my $size = $foo->_ffi_record_size;
  like $size, qr{^[0-9]+$}, "foo._record_size = $size";

  is $foo->first,  1, 'foo.first   = 1';
  is $foo->second, 2, 'foo.second  = 2';

  $foo->first(22);
  is $foo->first, 22, 'foo.first   = 22';
  
  $foo->second(42);
  is $foo->second, 42, 'foo.second = 42';

};

do {
  package
    Color;
  
  use FFI::Platypus;
  use FFI::Platypus::Record;
  
  my $ffi = FFI::Platypus->new;
  $ffi->find_lib(lib => 'test', symbol => 'f0', libpath => 'libtest');
  
  record_layout($ffi, qw(
    uint8 red
    uint8 green
    uint8 blue
  ));
  
  $ffi->type('record(Color)' => 'Color');
  $ffi->attach( [ color_get_red   => 'get_red'   ] => [ 'Color' ] => 'int' );
  $ffi->attach( [ color_get_green => 'get_green' ] => [ 'Color' ] => 'int' );
  $ffi->attach( [ color_get_blue  => 'get_blue'  ] => [ 'Color' ] => 'int' );
};

subtest 'values match in C' => sub {
  plan tests => 4;

  my $color = Color->new(
    red   => 50,
    green => 100,
    blue  => 150,
  );
  
  isa_ok $color, 'Color';
  
  is $color->get_red,    50, "color.get_red   =  50";
  is $color->get_green, 100, "color.get_green = 100";
  is $color->get_blue,  150, "color.get_blue  = 150";
  
};

do {
  package
    Foo2;

  use FFI::Platypus::Record;
  
  record_layout(qw(
    char     x1
    uint64_t uint64
    char     x2
    uint32_t uint32
    char     x3
    uint16_t uint16
    char x4
    uint8_t uint8

    char x5
    int64_t sint64
    char x6
    int32_t sint32
    char x7
    int16_t sint16
    char x8
    int8_t sint8

    char x9
    float float
    char x10
    double double 

    char x11
    opaque opaque
  ));
  
  my $ffi = FFI::Platypus->new;
  $ffi->find_lib(lib => 'test', symbol => 'f0', libpath => 'libtest');
  
  $ffi->attach(["align_get_$_" => "get_$_"] => [ 'record(Foo2)' ] => $_)
    for qw( uint8 sint8 uint16 sint16 uint32 sint32 uint64 sint64 float double opaque );
};

subtest 'complex alignment' => sub {
  plan tests => 15;
  
  my $foo = Foo2->new;
  isa_ok $foo, 'Foo2';

  $foo->uint64(512);
  is $foo->get_uint64, 512, "uint64 = 512";
  
  $foo->sint64(-512);
  is $foo->get_sint64, -512, "sint64 = -512";

  $foo->uint32(1024);
  is $foo->get_uint32, 1024, "uint32 = 1024";
  
  $foo->sint32(-1024);
  is $foo->get_sint32, -1024, "sint32 = -1024";

  $foo->uint16(2048);
  is $foo->get_uint16, 2048, "uint16 = 2048";
  
  $foo->sint16(-2048);
  is $foo->get_sint16, -2048, "sint16 = -2048";

  $foo->uint8(48);
  is $foo->get_uint8, 48, "uint8 = 48";
  
  $foo->sint8(-48);
  is $foo->get_sint8, -48, "sint8 = -48";

  $foo->float(1.5);
  is $foo->get_float, 1.5, "float = 1.5";

  $foo->double(-1.5);
  is $foo->get_double, -1.5, "double = -1.5";

  my $ptr = malloc 32;
  
  $foo->opaque($ptr);
  is $foo->get_opaque, $ptr, "get_opaque = $ptr";
  is $foo->opaque, $ptr, "opaque = $ptr";

  $foo->opaque(undef);
  is $foo->get_opaque, undef,  "get_opaque = undef";
  is $foo->opaque, undef,  "opaque = undef";
  
};

subtest 'same name' => sub {
  plan tests => 1;

  eval {
    package
      Foo3;
      
    use FFI::Platypus::Record;
    
    record_layout
      int => 'foo',
      int => 'foo',
    ;
  };
  
  isnt $@, '', 'two members of the same name not allowed';
  note $@ if $@;
};
