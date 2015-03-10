package FFI::Platypus::Record;

use strict;
use warnings;
use Carp qw( croak );
use FFI::Platypus;
use base qw( Exporter );

our @EXPORT = qw( record_layout );

# ABSTRACT: FFI support for structured records data
# VERSION

=head1 SYNOPSIS

C:

 struct my_person {
   int         age;
   const char  title[3];
   const char *name
 };
 
 void process_person(struct my_person *person)
 {
   /* ... */
 }

Perl:

 package MyPerson;
 
 use FFI::Platypus::Record;
 
 record_layout(qw(
   int       age
   string(3) title
   string_rw name
 );
 
 package main;
 
 use FFI::Platypus;
 
 my $ffi = FFI::Platypus->new;
 $ffi->lib("myperson.so");
 $ffi->type("record(MyPerson)" => 'MyPerson');
 
 my $person = MyPerson->new(
   age   => 40,
   title => "Mr.",
   name  => "John Smith",
 );
 
 $ffi->attach( process_person => [ 'MyPerson' ] => 'void' );
 
 process_person($person);
 
 $person->age($person->age + 1); # another year older
 
 process_person($person);

=head1 DESCRIPTION

[version 0.21]

This module provides a mechanism for building classes that can be used 
to mange structured data records (known as C as "structs" and in some 
languages as "records").  A structured record is a series of bytes that 
have structure understood by the C or other foreign language library 
that you are interfacing with.  It is designed for use with FFI and 
L<FFI::Platypus>, though it may have other applications.

=head1 FUNCTIONS

=head2 record_layout

 record_layout($ffi, $type => $name, ... );
 record_layout($type => $name, ... );

Define the layout of the record.  You may optionally provide an instance 
of L<FFI::Platypus> as the first argument in order to use its type 
aliases.  Then you provide members as type/name pairs.

For each member you declare, C<record_layout> will create an accessor 
which can be used to read and write its value. For example imagine a 
class C<Foo>:

 package Foo;
 
 use FFI::Platypus::Record;
 
 record_layout(
   int          => 'bar',  #  int bar;
   'string(10)' => 'baz',  #  char baz[10];
 );

You can get and set its fields with like named C<bar> and C<baz> 
accessors:

 my $foo = Foo->new;
 
 $foo->bar(22);
 my $value = $foo->bar;
 
 $foo->baz("grimlock\0\0"); # should be 10 characters long
 my $string_value = $foo->baz; # includes the trailing \0\0

You can also pass initial values in to the constructor, either passing 
as a list of key value pairs or by passing a hash reference:

 $foo = Foo->new(
   bar => 22,
   baz => "grimlock\0\0",
 );
 
 # same as:
 
 $foo = Foo->new( {
   bar => 22,
   baz => "grimlock\0\0",
 } );

If there are members of a record that you need to account for in terms 
of size and alignment, but do not want to have an accessor for, you can 
use C<:> as a place holder for its name:

 record_layout(
   'int'        => ':',
   'string(10)' => 'baz',
 );

=head3 strings

So far I've shown fixed length strings.  These are declared with the 
word C<string> followed by the length of the string in parentheticals.  
Fixed length strings are included inside the record itself and do not 
need to be allocated or deallocated separately from the record.  
Variable length strings must be allocated on the heap, and thus require 
a sense of "ownership", that is whomever allocates variable length 
strings should be responsible for also free'ing them.  To handle this, 
you can add a C<ro> or C<rw> trait to a string field.  The default is 
C<ro>, means that you can get, but not set its value:

 package Foo;
 
 record_layout(
   'string ro' => 'bar',  # same type as 'string' and 'string_ro'
 );
 
 package main;
 
 my $foo = Foo->new;
 
 my $string = $foo->bar;  # GOOD
 $foo->bar("starscream"); # BAD

If you specify a field is C<rw>, then you can set its value:

 package Foo;
 
 record_layout(
   'string rw' => 'bar',  # same type as 'string_rw'
 );
 
 package main;
 
 my $foo = Foo->new;
 
 my $string = $foo->bar;  # GOOD
 $foo->bar("starscream"); # GOOD

Any string value that is pointed to by the record will be free'd when it 
falls out of scope, so you must be very careful that any C<string rw> 
fields are not set or modified by C code.  You should also take care not 
to copy any record that has a C<rw> string in it because its values will 
be free'd twice!

 use Clone qw( clone );
 
 my $foo2 = clone $foo;  # BAD  bar will be free'd twice

=head3 arrays

Arrays of integer, floating points and opaque pointers are supported.

 package Foo;
 
 record_layout(
   'int[10]' => 'bar',
 );
 
 my $foo = Foo->new;
 
 $foo->bar([1,2,3,4,5,6,7,8,9,10]); # sets the values for the array
 my $list = $foo->bar;  # returns a list reference
 
 $foo->bar(5, -6); # sets the 5th element in the array to -6
 my $item = $foo->bar(5); gets the 5th element in the array

=cut

sub record_layout
{
  my $ffi = ref($_[0]) ? shift : FFI::Platypus->new;
  my $offset = 0;
  my $record_align = 0;
  
  croak "uneven number of arguments!" if scalar(@_) % 2;
  
  my($caller, $filename, $line) = caller;

  if($caller->can("_ffi_record_size")
  || $caller->can("ffi_record_size"))
  {
    croak "record already defined for the class $caller";
  }
  
  my @destroy;
  
  while(@_)
  {
    my $type = shift;
    my $name = shift;
    
    croak "illegal name $name"
      unless $name =~ /^[A-Za-z_][A-Za-z_0-9]*$/
      ||     $name eq ':';
    croak "accessor/method $name already exists"
      if $caller->can($name);
    
    my $size  = $ffi->sizeof($type);
    my $align = $ffi->alignof($type);
    $record_align = $align if $align > $record_align;
    my $meta  = $ffi->type_meta($type);

    $offset++ while $offset % $align;    

    if($name ne ':')
    {

      if($meta->{type} eq 'string'
      && $meta->{access} eq 'rw'
      && $meta->{fixed_size} == 0)
      {
        push @destroy, eval '# line '. __LINE__ . ' "' . __FILE__ . qq("\n) .qq{
          sub {
            shift->$name(undef);
          };
        };
        die $@ if $@;
      }

      $name = join '::', $caller, $name;
      my $error_str = $ffi->impl_record_accessor->(
        $name,
        "$filename:$line",
        $ffi->_type_lookup($type),
        $offset
      );
      croak($error_str) if $error_str;
    };
    
    $offset += $size;
  }
  
  my $size = $offset;
  
  no strict 'refs';
  *{join '::', $caller, '_ffi_record_size'}  = sub () { $size         };
  *{join '::', $caller, '_ffi_record_align'} = sub () { $record_align };
  *{join '::', $caller, 'new'} = sub {
    my $class = shift;
    my $args = ref($_[0]) ? [%{$_[0]}] : \@_;
    croak "uneven number of arguments to record constructor"
      if @$args % 2;
    my $record = "\0" x $class->_ffi_record_size;
    my $self = bless \$record, $class;
    
    while(@$args)
    {
      my $key = shift @$args;
      my $value = shift @$args;
      $self->$key($value);
    }
    
    $self;
  };
  
  my $destroy_sub = sub {};
  
  if(@destroy)
  {
    $destroy_sub = sub {
      $_->($_[0]) for @destroy;
    };
  }
  do {
    no strict 'refs';
    *{"${caller}::DESTROY"} = $destroy_sub;
  };
  ();
}

1;

=head1 TODO

These useful features (and probably more) are missing:

=over 4

=item Unions

=item Nested records

=back

=head1 SEE ALSO

=over 4

=item L<FFI::Platypus>

The main platypus documentation.

=item L<FFI::Platypus::Record::TieArray>

Tied array interface for record array members.

=item L<Convert::Binary::C>

Another method for constructing and dissecting structured data records.

=item L<pack and unpack|perlpacktut>

Built-in Perl functions for constructing and dissecting structured data 
records.

=back

=cut
