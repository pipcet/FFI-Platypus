package FFI::Platypus::GDB;

use strict;
use warnings;
use 5.008001;
use Carp qw(croak);
#use Carp::Always;

=head1 SYNOPSIS

 use FFI::Platypus::GDB;
 my

Why GDB?
 - it's language-agnostic, to a certain extent
 - it uses the preprocessed source code, but also gives access to macro definitions
 - it has a type model that's already working and well-tested, so modelling ours after GDB's is good

Why not GDB?
 - it's slow
 - you need to figure out how to build with debug flags
 - -g3 debug data is huge

Unfortunately, there are obvious but debilitating bugs in both the
python and the guile bindings for GDB
(https://sourceware.org/bugzilla/show_bug.cgi?id=18070 and
https://sourceware.org/bugzilla/show_bug.cgi?id=18073), so we need to
use a hacked/fixed version of GDB for now.

=cut

use IPC::Run qw(start);
use FFI::Platypus;

sub wait_for_prompt {
  my ($self) = @_;
  until ($self->{out} =~ /\(gdb\) $/) {
    $self->{ipc}->pump;
  }
}

sub run_command {
  my ($self, $command) = @_;

  warn "running command $command";
  $self->{in} = "$command\n";

  $self->wait_for_prompt;

  my $res = $self->{out};
  $self->{out} = "";
  $res =~ s/\(gdb\) $//;
  warn "result is $res";
  return $res;
}

sub handle_type {
  my ($self, $name) = @_;

  my $eval = $self->run_command("py print print_type('$name')");
  my $ffi = $self->{ffi};


  eval $eval;

  die $@;

  return $self;
}

use Data::Dumper;


sub pretype_set_name {
  my ($self, $pretype, $name) = @_;

  return if (!ref $pretype);
  return if (exists $pretype->{name});

  $pretype->{name} = $name;
  $self->{pretypes_by_name}->{$name} = $pretype;

  if ($pretype->{type} eq 'func') {
    my $arg = 0;

    for my $field (@{$pretype->{fields}}) {
      pretype_set_name($self, $field->{type}, $name . ".arg$arg");
      $arg++;
    }

    pretype_set_name($self, $pretype->{target}, $name . ".return");
  } elsif ($pretype->{type} eq 'ptr') {
    pretype_set_name($self, $pretype->{target}, $name . ".target");
  } elsif ($pretype->{type} eq 'array') {
    pretype_set_name($self, $pretype->{target}, $name . ".target");
  } elsif ($pretype->{type} eq 'struct') {
    for my $field (@{$pretype->{fields}}) {
      pretype_set_name($self, $field->{type}, $name . "." . $field->{name});
    }
  }
}

my $last_unknown_type;

sub realize_pretype {
  my ($self, $name, $attr) = @_;

  if (ref $attr) {
    if ($attr->{type} eq 'struct' or
	$attr->{type} eq 'record') {
      my @record_definition;
      for my $field (@{$attr->{fields}}) {
	if (exists $field->{bitsize}) {
	  croak unless $field->{bitsize} == 1;
	  croak unless $field->{type} eq 'unsigned int';

	  push @record_definition, 'int' => $field->{name};
	} elsif (ref $field->{type}) {
	  $self->realize_pretype($field->{type}->{name}, $field->{type});
	  push @record_definition, $field->{type}->{name} => $field->{name};
	} elsif ($field->{type} and !$self->{ffi}->{types}->{$field->{type}}) {
	  if ($self->{ffi}->{pretypes}->{$field->{type}}) {
	    $field->{type} = $self->{ffi}->{pretypes}->{$field->{type}};
	    redo;
	  }
	  warn "unknown type " . $field->{type};
	  $last_unknown_type = \$field->{type};
	  warn $last_unknown_type;
	  return;
	}
      }
      warn "record definition is " . Dumper(\@record_definition);
      my $qname = $name;
      $qname =~ s/ //g;
      if ($self->{ffi}->{types}->{$name} ||
	  "Record::$qname"->can('_ffi_record_size')) {
	return "record(Record::$qname)";
      } else {
	warn "{ package Record::$qname; use FFI::Platypus::Record; " . 'record_layout($self->{ffi}, @record_definition); }';
	eval "{ package Record::$qname; use FFI::Platypus::Record; " . 'record_layout($self->{ffi}, @record_definition); }';

	die $@ if $@;

	my $size = "Record::$qname"->_ffi_record_size;

	warn "size is $size";

	$self->{ffi}->type("record(Record::$qname)", $name);

	return "record(Record::$qname)";
      }
    } elsif ($attr->{type} eq 'typedef') {
      my $new = ref($attr->{target}) ? $attr->{target}->{name} : $attr->{target};

      if ($self->{ffi}->{types}->{$new}) {
	warn Dumper($self->{ffi});
	$self->{ffi}->type($new, $attr->{type});
	return 1;
      } else {
	$last_unknown_type = \$new;
	warn $$last_unknown_type;
	return;
      }
    } elsif ($attr->{type} eq 'ptr') {
      if ($self->{ffi}->{types}->{$name}) {
	return 1;
      } else {
	$self->{ffi}->type('opaque', $name);
	return 1;
      }
    }
  }

  return 1;
}

# we rewrite types as follows:
#  - a pointer to a struct is a record
#  - a pointer to a function is a closure
#  - it doesn't make sense to translate pointers to unions to unions of pointers, since most unions appear at an offset in a structure.

sub handle_symbol {
  my ($self, $name, $symbol) = @_;

  my $attr = $self->{pretypes_by_name}->{$name};
  my $ffi = $self->{ffi};

  if ($attr) {
    warn "defining $name to " . Dumper($attr);
    $ffi->{pretypes}->{$name} = $attr;
    while (!$self->realize_pretype($name, $attr)) {
      $self->handle_symbol($$last_unknown_type, 0);
    }
  }

  my $eval = $self->run_command($symbol ? "py print print_symbol_type('$name')" : "py print print_type('$name')");


  my $def = sub {
    my($name, $attr) = @_;

    pretype_set_name($self, $attr, $name);

    warn "defining $name to " . Dumper($attr);
    $ffi->{pretypes}->{$name} = $attr;
    while (!$self->realize_pretype($name, $attr)) {
      $self->handle_symbol($$last_unknown_type, 0);
    }
  };

  my $ptr = sub {
    my ($attr) = @_;
    if (ref($attr->{target}) and $attr->{target}->{type} eq 'func') {
      my %h = %{$attr->{target}};

      $h{type} = 'closure';
      return \%h;
    } elsif (ref($attr->{target}) and $attr->{target}->{type} eq 'struct') {
      my %h = %{$attr->{target}};

      $h{type} = 'record';
      return \%h;
    }

    my %h = %$attr;
    $h{type} = 'ptr';
    delete $h{sizeof};
    return \%h;
  };

  my $func = sub {
    my ($attr) = @_;
    my %h = %$attr;
    $h{type} = 'func';
    return \%h;
  };

  my $typedef = sub {
    my ($attr) = @_;
    my %h = %$attr;
    $h{type} = 'typedef';
    delete $h{sizeof};
    delete $h{fields};

    return \%h;
  };

  my $void = sub {
    my ($attr) = @_;
    my %h = %$attr;
    $h{type} = 'void';
    return \%h;
  };

  my $struct = sub {
    my ($attr) = @_;
    my %h = %$attr;
    $h{type} = 'struct';
    return \%h;
  };

  my $union = sub {
    my ($attr) = @_;
    my %h = %$attr;
    $h{type} = 'union';
    return \%h;
  };

  my $int = sub {
    my ($attr) = @_;
    my %h = %$attr;
    $h{type} = 'int';
    return \%h;
  };

  my $bool = sub {
    my ($attr) = @_;
    my %h = %$attr;
    $h{type} = 'bool';
    return \%h;
  };

  my $array = sub {
    my ($attr) = @_;
    my %h = %$attr;
    $h{type} = 'array';
    return \%h;
  };

  my $range = sub {
    my ($attr) = @_;
    my %h = %$attr;
    $h{type} = 'range';
    return \%h;
  };

  eval $eval;

  die $@ if $@;

  return $self;
}

sub handle_macro
{
  my ($self, $linespec, $macro, $input_type) = @_;

  $self->run_command("l $linespec"); # sets scope to the right linespec

}

sub new {
  my ($class) = @_;
  my $self = bless {}, $class;

  $self->{in} = "";
  $self->{out} = "";

  $self->{ffi} = FFI::Platypus->new();

  $self->{ipc} = start(['/home/pip/git/binutils-gdb/gdb/gdb', '/home/pip/git/FFI-Platypus/blib/arch/auto/FFI/Platypus/Platypus.so'], \$self->{in}, \$self->{out});

  $self->wait_for_prompt;
  $self->{out} = "";
  $self->run_command("py exec file('/home/pip/git/FFI-Platypus/perlify-types.py')");

  return $self;
}

my $gdb = FFI::Platypus::GDB->new;
$gdb->handle_symbol('ffi_pl_closure_call', 1);
$gdb->handle_symbol('ffi_pl_record_accessor_uint8', 1);
$gdb->handle_symbol('ffi_pl_closure');
die 'success';
