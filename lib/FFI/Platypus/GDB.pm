package PartialType;
use strict;
use warnings;
use 5.008001;
use Carp qw(croak);
use Carp::Always;

sub new {
  my($class, $type) = @_;
  my $self = bless {}, $class;

  return $self unless defined $type;

  $self->{type} = $type;

  return $self;
}

sub describe {
  my($self,$seen,$indent) = @_;
  my $ret = "";

  $indent = "" unless defined $indent;
  $seen = {} unless $seen;

  if($self->{name}) {
    $ret .= $indent . "partial type " . $self->{name};
  } else {
    $ret .= $indent . "anonymous partial type $self";
  }
  $ret .=  ($indent eq "" ? ":": ", which:") . "\n";

  $indent .= "  ";

  if($seen->{$self}++) {
    $ret .= $indent . "was seen before\n";
  } else {
    if($self->{is_pointer}) {
      $ret .= $indent . "is a pointer to:\n";

      $ret .= $self->{target}->describe($seen, $indent . "  ");
    }
    for my $field (keys %{$self->{fields}}) {
      $ret .= $indent . "has a field named $field of type:\n";
      $ret .= $self->{fields}->{$field}->describe($seen, $indent . "  ");
    }
    if($self->{type}) {
      $ret .= $indent . "is known exactly to be:\n";
      $ret .= $self->{type}->describe($seen, $indent . "  ");
    }
    for my $cast (values %{$self->{casts_to}}) {
      $ret .= $indent . "casts to:\n";
      $ret .= $cast->describe($seen, $indent . "  ");
    }
    for my $cast (values %{$self->{casts_from}}) {
      $ret .= $indent . "casts from:\n";
      $ret .= $cast->describe($seen, $indent . "  ");
    }
  }

  return $ret;
}

sub casts_to {
  my($self, $cast) = @_;

  $self->{casts_to}->{$cast} = $cast;
  $cast->{casts_from}->{$self} = $self;
}

sub intersection_type_cast {
  my($self,$other) = @_;
  my $ret = PartialType->new();

  $self->casts_to($ret);
  $other->casts_to($ret);

  return $ret;
}

sub intersection_type_nocast {
  my($self,$other) = @_;

  return $self unless $other;

  my $ret = PartialType->new();

  if($self->{type} and $other->{type}) {
    warn "I hope they match!";
    $ret->{type} = $self->{type};
  } else {
    $ret->{type} = $self->{type} if $self->{type};
    $ret->{type} = $other->{type} if $other->{type};
  }

  for my $cast (values %{$self->{casts_to}}) {
    $ret->{casts_to}->{$cast} = $cast;
  }

  for my $cast (values %{$self->{casts_from}}) {
    $ret->{casts_from}->{$cast} = $cast;
  }

  if ($self->{fields}) {
    for my $field (keys %{$self->{fields}}) {
      $ret->{fields}->{$field} = $self->{fields}->{$field};
    }
  }

  if ($other->{fields} and $self->{fields}) {
    for my $field (keys %{$other->{fields}}) {
      $ret->{fields}->{$field} = $other->{fields}->{$field}->intersection_type_nocast($self->{fields}->{$field});
    }
  }

  if (defined($self->{is_pointer})) {
    $ret->{is_pointer} = $self->{is_pointer};
  }

  if (defined($other->{is_pointer})) {
    $ret->{is_pointer} = $other->{is_pointer};
  }

  return $ret;
}

sub deref {
  my($self) = @_;

  if($self->{target}) {
    # nothing to do
  } elsif($self->{type}) {
    $self->{target} = PartialType->new($self->{type}->{target});
  } else {
    $self->{is_pointer} = 1;
    $self->{target} = PartialType->new();
  }

  return $self->{target};
}

sub field_must_exist
{
  my($self, $name) = @_;

  $self->{fields}->{$name} = PartialType->new($self->{type} ? $self->{type}->{fields}->{$name} : undef);
}

sub field_type
{
  my($self, $name) = @_;

  $self->field_must_exist($name);

  return $self->{fields}->{$name};
}

my $expr_ops = {
  TERNOP_COND => sub {
    my ($attr) = @_;
    my @subexps = @{$attr->{subexps}};

    # $subexps[0]->casts_to($bool);

    return $subexps[1]->intersection_type_cast($subexps[2]);
  },

  STRUCTOP_PTR => sub {
    my ($attr) = @_;
    my $value = $attr->{value};
    my @subexps = @{$attr->{subexps}};

    my $type = $subexps[0]->deref;

    $type->field_must_exist($value);
    return $type->field_type($value);
  },

  STRUCTOP_STRUCT => sub {
    my ($attr) = @_;
    my $value = $attr->{value};
    my @subexps = @{$attr->{subexps}};

    my $type = $subexps[0];

    $type->field_must_exist($value);
    return $type->field_type($value);
  },

  OP_INTERNALVAR => sub {
    my ($attr) = @_;
    my $value = $attr->{value};
    my $type = PartialType->new;

    return $type;
  },

  UNOP_CAST_TYPE => sub {
    my ($attr) = @_;
    my @subexps = @{$attr->{subexps}};
    my $cast_type = $subexps[0];
    my $type = $subexps[1];

    $type->casts_to($cast_type);

    return $cast_type;
  },

  OP_TYPE => sub {
    my ($attr) = @_;

    return PartialType->new($attr->{type});
  },

  OP_LONG => sub {
    my ($attr) = @_;

    return PartialType->new($attr->{type});
  },
};

sub ops {
  my($class, $internals) = @_;

  my %ops = %$expr_ops;

  $ops{OP_INTERNALVAR} = sub {
    my ($attr) = @_;
    my $value = $attr->{value};
    my $type = PartialType->new;

    $type->{name} = $value;
    $internals->{$value} = $type;

    return $type;
  };

  return \%ops;
}

sub match {
  my($self,$type,$mapping) = @_;

  if ($mapping->{$self}) {
    return $type->match($mapping->{$self});
  }

  $mapping->{$self} = $type;

  if($self->{type}) {
    my $matches = $self->{type}->match($type);

    return $matches if defined $matches;
  }

  if($self->{fields} and $type->{fields}) {
    for my $field (keys %{$self->{fields}}) {
      return 0 unless $type->{fields}->{$field};
    }
  }

  if($self->{is_pointer}) {
    if($type->{kind} eq 'name') {
      return;
    }

    if($type->{kind} ne 'PTR') {
      return 0;
    }

    my $matches = $self->{target}->match($type->{target});

    return $matches if defined $matches;
  }

  return;
}

package GDBType;

sub match {
  my($self, $other, $mapping) = @_;

  return 1 if $self == $other;

  return 0 if ($self->{kind} ne $other->{kind}) and not ($self->{kind} eq 'name' or $other->{kind} eq 'name');

  if ($mapping->{$self}) {
    return ($other == $mapping->{$self}) ? 1 : undef;
  }

  $mapping->{$self} = $other;

  if ($self->{fields} and $other->{fields}) {
    for my $field (keys %{$self->{fields}}, keys %{$other->{fields}}) {
      return 0 unless $other->{fields}->{$field}->match($self->{fields}->{$field});
    }
  }

  return;
}

sub describe {
  my($self,$seen,$indent) = @_;
  my $ret = "";

  $indent = "" unless defined $indent;
  $seen = {} unless $seen;

  if($self->{name}) {
    $ret .= $indent . "type " . $self->{name};
  } else {
    $ret .= $indent . "anonymous type $self";
  }
  $ret .=  ($indent eq "" ? ":": ", which:") . "\n";

  $indent .= "  ";

  if($seen->{$self}++) {
    $ret .= $indent . "was seen before\n";
  } else {
    if($self->{kind} eq 'PTR') {
      $ret .= $indent . "is a pointer to:\n";

      $ret .= $self->{target}->describe($seen, $indent . "  ");
    } elsif($self->{kind} eq 'INT') {
      $ret .= $indent . "is a " . ($self->{sign} ? "signed" : "unsigned") . " integer of size " . $self->{bits} . "\n";
    }
    for my $field (keys %{$self->{fields}}) {
      $ret .= $indent . "has a field named $field:\n";
      $ret .= $self->{fields}->{$field}->describe($seen, $indent . "  ");
    }
  }

  return $ret;
}

sub new_kind_target {
  my($class, $kind, $target) = @_;

  my $self = bless {}, $class;
  $self->{kind} = $kind;
  $self->{target} = $target;

  return $self;
}

sub new_int {
  my($class, $bits, $sign) = @_;

  $sign = 1 unless defined $sign;

  my $self = bless {}, $class;
  $self->{kind} = 'INT';
  $self->{bits} = $bits;
  $self->{sign} = $sign;

  return $self;
}

sub new_pointer {
  my($class, $target) = @_;

  return GDBType->new_kind_target('PTR', $target);
}


my $type_ops = {
  PTR => sub {
    my($attr) = @_;
    my($self) = GDBType->new_pointer($attr->{target});

    return $self;
  },
  INT => sub {
    my($attr) = @_;
    my($self) = GDBType->new_int($attr->{sizeof} * 8); # bits per byte;

    return $self;
  },
  STRUCT => sub {
    my($attr) = @_;
    my($self) = GDBType->new_kind_target('struct', undef);

    for my $field (@{$attr->{fields}}) {
      $self->{fields}->{$field->{name}} = $field->{type};
    }

    return $self;
  },
  UNION => sub {
    my($attr) = @_;
    my($self) = GDBType->new_kind_target('struct', undef);

    for my $field (@{$attr->{fields}}) {
      $self->{fields}->{$field->{name}} = $field->{type};
    }

    return $self;
  },
  ENUM => sub {
    my($attr) = @_;
    my($self) = GDBType->new_kind_target('enum', undef);

    for my $field (@{$attr->{fields}}) {
      $self->{fields}->{$field->{name}} = $field->{type};
    }

    return $self;
  },
  name => sub {
    my($name) = @_;
    my $ret = GDBType->new_kind_target('name', undef);
    $ret->{name} = $name;
    return $ret;
  }
};

sub ops {
  my ($class, $types) = @_;
  $types = {} if !$types;
  my %ops = %$type_ops;

  $ops{name} = sub {
    my($name) = @_;

    return $types->{$name} if $types->{$name};

    my $ret = GDBType->new_kind_target('name', undef);
    $ret->{name} = $name;

    $types->{$name} = $ret;

    return $ret;
  };

  return \%ops;
}


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

use Data::Dumper;

sub read_type
{
  my($self, $name) = @_;

  $self->{types} = {} unless $self->{types};

  my %t = %{GDBType->ops($self->{types})};
  my $def = sub { $_[1]->{name} = $_[0]; $self->{types}->{$_[0]} = $_[1]; return $_[1]; };

  my $eval = $self->run_command("py print print_type('$name')");

  return $self if $eval eq "";

  my $t = eval $eval;

  die $@ if $@;

  print $t->describe;

  return $self;
}

sub read_type_expression
{
  my($self, $name) = @_;

  $self->{types} = {} unless $self->{types};

  my $expr = sub { $_[1]->{name} = $_[0]; $self->{types}->{$_[0]} = $_[1]; return $_[1]; };

  my %e = (OP_TYPE => sub { $_[0]->{type} });
  my %t = %{GDBType->ops($self->{types})};
  my $def = sub { $_[1]->{name} = $_[0]; $self->{types}->{$_[0]} = $_[1]; return $_[1]; };

  my $eval = $self->run_command("py print print_expression('$name')");

  return $self if $eval eq "";

  my $t = eval $eval;

  die $@ if $@;

  print $t->describe;

  return $self;
}

sub guess_macro_type
{
  my ($self, $macro, $linespec, $input_type) = @_;
  my $internals = {};

  my %e = %{PartialType->ops($internals)};
  my %t = %{GDBType->ops($self->{types})};

  my $expr = $self->run_command("py print print_macro('$macro', '$linespec')");

  return $self if $expr eq "";

  my $partial_type = eval $expr;

  die $@ if $@;

  print Dumper($partial_type);
  print $partial_type->describe;

  for my $name (keys %{$internals}) {
    print "\n\n";

    print Dumper($internals->{$name});
    print $internals->{$name}->describe;
  }

  for my $internal (keys %{$internals}) {
    my @potential_types;
    for my $type (keys %{$self->{types}}) {
      next if $self->{types}->{$type}->{kind} eq 'name';

      my $matches =  $internals->{$internal}->match($self->{types}->{$type});

      $matches = 'undef' unless defined $matches;

      print "$internal matches $type: " . $matches . "\n";

      push @potential_types, $self->{types}->{$type} if $matches eq 'undef';
    }

    for my $type (@potential_types) {
      # this looks C-specific, but it's actually not.
      $self->run_command("p \$"."$internal = typeof(" . $type->{name}. ")");

      $self->run_command("ptype \$x0");
      $self->run_command("ptype 0 ? \$x0 : (void *)0");
      $self->run_command("ptype 1 ? \$x0 : (void *)0");


      my $expr = $self->run_command("py print print_macro_type('$macro', '$linespec')");

      die $expr;
    }
  }

  return $self;
}

sub handle_macro
{
  my ($self, $macro, $linespec, $input_type) = @_;

  my $expr = $self->run_command("py print print_macro('$macro', '$linespec')");

  return $self if $expr eq "";

  eval $expr;
}

sub new {
  my ($class) = @_;
  my $self = bless {}, $class;

  $self->{in} = "";
  $self->{out} = "";

  $self->{ffi} = FFI::Platypus->new();

  $self->{ipc} = start(['/home/pip/git/binutils-gdb/gdb/gdb', '/home/pip/git/binutils-gdb/gdb/gdb'], \$self->{in}, \$self->{out});

  $self->wait_for_prompt;
  $self->{out} = "";
  $self->run_command("py exec file('/home/pip/git/FFI-Platypus/share/gdb/perlify-expressions.py')");

  return $self;
}

my $gdb = FFI::Platypus::GDB->new;
$gdb->run_command("b main");
$gdb->run_command("run");
$gdb->read_type('struct type');
$gdb->read_type('struct main_type');
$gdb->read_type_expression('struct type *');
$gdb->read_type_expression('struct main_type *');
my @types = keys %{$gdb->{types}};
for my $type (@types) {
  $gdb->read_type($type);
}
$gdb->guess_macro_type('TYPE_OBJFILE', 'python.c:1000');

# $gdb->handle_symbol('ffi_pl_closure_call', 1);
# $gdb->handle_symbol('ffi_pl_record_accessor_uint8', 1);
# $gdb->handle_symbol('ffi_pl_closure');
die 'success';
