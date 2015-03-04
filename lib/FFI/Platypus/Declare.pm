package FFI::Platypus::Declare;

use strict;
use warnings;
use FFI::Platypus;

# ABSTRACT: Declarative interface to FFI::Platypus
# VERSION

=head1 SYNOPSIS

 use FFI::Platypus::Declare 'string', 'int';

 lib undef; # use libc
 attach puts => [string] => int;
 
 puts("hello world");

=head1 DESCRIPTION

This module provides a declarative interface to L<FFI::Platypus>. It 
provides a more concise interface at the cost of a little less power, 
and a little more namespace pollution.

Any strings passed into the C<use> line will be declared as types and 
exported as constants into your namespace, so that you can use them 
without quotation marks.

Aliases can be declared using a list reference:

 use FFI::Platypus [ 'int[48]' => 'my_integer_array' ];

Custom types can also be declared as a list reference (the type name
must include a ::):

 use FFI::Platypus [ '::StringPointer' => 'my_string_pointer' ];
 # short for FFI::Platypus::Type::StringPointer

=cut

our $ffi    = {};
our $types  = {};

sub _ffi_object
{
  my($package, $filename) = caller(1);
  $ffi->{$package} ||= FFI::Platypus::Impl::LibffiPerl->new->package($package,$filename);
}

=head1 FUNCTIONS

All functions are exported into your namespace.  If you do not want that,
then use the OO interface (see L<FFI::Platypus>).

=head2 lib

 lib $libpath;

Specify one or more dynamic libraries to search for symbols. If you are 
unsure of the location / version of the library then you can use 
L<FFI::CheckLib#find_lib>.

=cut

sub lib (@)
{
  _ffi_object->lib(@_);
}

=head2 type

 type $type;
 type $type = $alias;

Declare the given type.

Examples:

 type 'uint8'; # only really checks that uint8 is a valid type
 type 'uint8' => 'my_unsigned_int_8';

=cut

sub type ($;$)
{
  _ffi_object->type(@_);
}

=head2 custom_type

 custom_type $alias => \%args;

Declare the given custom type.  See L<FFI::Platypus::Type#Custom-Types> 
for details.

=cut

sub custom_type ($$)
{
  _ffi_object->custom_type(@_);
}

=head2 load_custom_type

 load_custom_type $name => $alias, @type_args;

Load the custom type defined in the module I<$name>, and make an alias 
with the name I<$alias>. If the custom type requires any arguments, they 
may be passed in as I<@type_args>. See L<FFI::Platypus::Type#Custom 
Types> for details.

If I<$name> contains C<::> then it will be assumed to be a fully 
qualified package name. If not, then C<FFI::Platypus::Type::> will be 
prepended to it.

=cut

sub load_custom_type ($$;@)
{
  _ffi_object->load_custom_type(@_);
}

=head2 type_meta

 my $meta = type_meta $type;

Get the type meta data for the given type.

Example:

 my $meta = type_meta 'int';

=cut

sub type_meta($)
{
  _ffi_object->type_meta(@_);
}

=head2 attach

 attach $name => \@argument_types => $return_type;
 attach [$c_name => $perl_name] => \@argument_types => $return_type;
 attach [$address => $perl_name] => \@argument_types => $return_type;

Find and attach a C function as a Perl function as a real live xsub.

If just one I<$name> is given, then the function will be attached in 
Perl with the same name as it has in C.  The second form allows you to 
give the Perl function a different name.  You can also provide a memory 
address (the third form) of a function to attach.

Examples:

 attach 'my_function', ['uint8'] => 'string';
 attach ['my_c_function_name' => 'my_perl_function_name'], ['uint8'] => 'string';
 my $string1 = my_function($int);
 my $string2 = my_perl_function_name($int);

=cut

my $inner_counter = 0;

sub attach ($$$;$$)
{
  my($caller, $filename, $line) = caller;
  my $wrapper;
  $wrapper = pop if ref($_[-1]) eq 'CODE';
  my($name, $args, $ret, $proto) = @_;
  my($symbol_name, $perl_name) = ref $name ? (@$name) : ($name, $name);
  my $function = _ffi_object->function($symbol_name, $args, $ret);
  my $attach_name = $perl_name = join '::', $caller, $perl_name;
  if($wrapper)
  {
    $attach_name = "FFI::Platypus::Declare::Inner::xsub$inner_counter";
    $inner_counter++;
  }
  $function->attach($attach_name, "$filename:$line", $proto);
  if($wrapper)
  {
    my $inner = \&{$attach_name};
    no strict 'refs';
    *{$perl_name} = sub { $wrapper->($inner, @_) };
  }
  ();
}

=head2 closure

 my $closure = closure $codeblock;

Create a closure that can be passed into a C function.  For details on closures, see L<FFI::Platypus::Type#Closures>.

Example:

 my $closure1 = closure { return $_[0] * 2 };
 my $closure2 = closure sub { return $_[0] * 4 };

=cut

sub closure (&)
{
  my($coderef) = @_;
  FFI::Platypus::Closure->new($coderef);
}

=head2 sticky

 my $closure = sticky closure $codeblock;

Keyword to indicate the closure should not be deallocated for the life 
of the current process.

If you pass a closure into a C function without saving a reference to it 
like this:

 foo(closure { ... });         # BAD

Perl will not see any references to it and try to free it immediately.  
(this has to do with the way Perl and C handle responsibilities for 
memory allocation differently).  One fix for this is to make sure the 
closure remains in scope using either C<my> or C<our>.  If you know the 
closure will need to remain in existence for the life of the process (or 
if you do not care about leaking memory), then you can add the sticky 
keyword to tell L<FFI::Platypus> to keep the thing in memory.

 foo(sticky closure { ... });  # OKAY

=head2 cast

 my $converted_value = cast $original_type, $converted_type, $original_value;

The C<cast> function converts an existing I<$original_value> of type 
I<$original_type> into one of type I<$converted_type>.  Not all types 
are supported, so care must be taken.  For example, to get the address 
of a string, you can do this:

 my $address = cast 'string' => 'opaque', $string_value;

=cut

sub cast ($$$)
{
  _ffi_object->cast(@_);
}

=head2 attach_cast

 attach_cast "cast_name", $original_type, $converted_type;
 my $converted_value = cast_name($original_value);

This function creates a subroutine which can be used to convert 
variables just like the L<cast|FFI::Platypus::Declare#cast> function 
above.  The above synopsis is roughly equivalent to this:

 sub cast_name { cast($original_type, $converted_type, $_[0]) }
 my $converted_value = cast_name($original_value);

Except that the L<attach_cast|FFI::Platypus::Declare#attach_cast> 
variant will be much faster if called multiple times since the cast does 
not need to be dynamically allocated on each instance.

=cut

sub attach_cast ($$$)
{
  my($name, $type1, $type2) = @_;
  my $caller = caller;
  $name = join '::', $caller, $name;
  _ffi_object->attach_cast($name, $type1, $type2);
}

=head2 sizeof

 my $size = sizeof $type;

Returns the total size of the given type.  For example to get the size 
of an integer:

 my $intsize = sizeof 'int'; # usually 4 or 8 depending on platform

You can also get the size of arrays

 my $intarraysize = sizeof 'int[64]';

Keep in mind that "pointer" types will always be the pointer / word size 
for the platform that you are using.  This includes strings, opaque and 
pointers to other types.

This function is not very fast, so you might want to save this value as 
a constant, particularly if you need the size in a loop with many 
iterations.

=cut

sub sizeof ($)
{
  _ffi_object->sizeof($_[0]);
}

=head2 lang

 lang $language;

Specifies the foreign language that you will be interfacing with. The 
default is C.  The foreign language specified with this attribute 
changes the default native types (for example, if you specify 
L<Rust|FFI::Platypus::Lang::Rust>, you will get C<i32> as an alias for 
C<sint32> instead of C<int> as you do with L<C|FFI::Platypus::Lang::C>).

In the future this may attribute may offer hints when doing demangling
of languages that require it like L<C++|FFI::Platypus::Lang::CPP>.

=cut

sub lang ($)
{
  _ffi_object->lang($_[0]);
}

=head2 abi

 abi $abi;

Set the ABI or calling convention for use in subsequent calls
to L</attach>.  May be either a string name or integer value
from L<FFI::Platypus#abis>.

=cut

sub abi ($)
{
  _ffi_object->abi($_[0]);
}

sub import
{
  my $caller = caller;
  shift; # class
  
  foreach my $arg (@_)
  {
    if(ref $arg)
    {
      if($arg->[0] =~ /::/)
      {
        _ffi_object->load_custom_type(@$arg);
        no strict 'refs';
        *{join '::', $caller, $arg->[1]} = sub () { $arg->[1] };
      }
      else
      {
        _ffi_object->type(@$arg);
        no strict 'refs';
        *{join '::', $caller, $arg->[1]} = sub () { $arg->[0] };
      }
    }
    else
    {
      _ffi_object->type($arg);
      no strict 'refs';
      *{join '::', $caller, $arg} = sub () { $arg };
    }
  }
  
  no strict 'refs';
  *{join '::', $caller, 'lib'} = \&lib;
  *{join '::', $caller, 'type'} = \&type;
  *{join '::', $caller, 'type_meta'} = \&type_meta;
  *{join '::', $caller, 'custom_type'} = \&custom_type;
  *{join '::', $caller, 'load_custom_type'} = \&load_custom_type;
  *{join '::', $caller, 'attach'} = \&attach;
  *{join '::', $caller, 'closure'} = \&closure;
  *{join '::', $caller, 'sticky'} = \&sticky;
  *{join '::', $caller, 'cast'} = \&cast;
  *{join '::', $caller, 'attach_cast'} = \&attach_cast;
  *{join '::', $caller, 'sizeof'} = \&sizeof;
  *{join '::', $caller, 'lang'} = \&lang;
  *{join '::', $caller, 'abi'} = \&abi;
}

1;

=head1 SEE ALSO

=over 4

=item L<FFI::Platypus>

Object oriented interface to Platypus.

=item L<FFI::Platypus::Type>

Type definitions for Platypus.

=item L<FFI::Platypus::API>

Custom types API for Platypus.

=item L<FFI::Platypus::Memory>

memory functions for FFI.

=item L<FFI::CheckLib>

Find dynamic libraries in a portable way.

=item L<FFI::TinyCC>

JIT compiler for FFI.

=item L<FFI::Raw>

Alternate interface to libffi with fewer features.  It notably lacks the 
ability to create real xsubs, which may make L<FFI::Platypus> much 
faster.

=back

=cut
