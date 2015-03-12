package FFI::Platypus::RTypes::Type::Wrap;
use parent 'FFI::Platypus::RTypes::Type', 'FFI::Platypus::Type::Wrap';
use FFI::Platypus::Declare;

# this type demonstrates that we can implement a type purely in Perl
# even though it needs to return C closures for some of its
# operations.

sub perl_to_native_cmethod {
  my($self) = @_;

  return $self->{perl_to_native_cmethod} if exists $self->{perl_to_native_cmethod};

  my $underlying_type = $self->{underlying_types}->[0];
  my $address = $underlying_type->perl_to_native_cmethod;

  undef $underlying_type;

  return 0 unless $address;

  my $sub = sub {
    my($arguments, $i, $type_sv, $extra_data, $arg, $freeme) = @_;

    print STDERR "argument is $arg\n";

    my $f = $type_sv->{ffi}->function($address => ['opaque', 'int', 'SV', 'opaque', 'SV', 'opaque'] => 'int');
    my $ret = $f->call($arguments, $i, $type_sv, $extra_data, $arg, $freeme);

    my $arguments_ptr = unpack 'P16', pack 'Q', $arguments;
    my ($arguments_count, $arguments_reserved, $arguments_pointers) = unpack 'llq', $arguments_ptr;
    my $ppointers = unpack 'P' . (8*$arguments_count), pack 'Q', $arguments_pointers;
    for (my $j = 0; $j < $ret; $j++) {
      my $argument = unpack 'P8', substr($ppointers, ($i+$j)*8, 8);
      my $argument_hex = sprintf("%016x", unpack 'Q', $argument);
      warn "argument $i+$j encoded as $argument_hex..."; # it might be longer than that
    }

    return $ret;
  };

  my $closure = $self->{ffi}->closure($sub);

  $self->{perl_to_native_closure} = $closure;

  $self->{perl_to_native_cmethod} = $self->{ffi}->cast('(opaque, int, SV, opaque, SV, opaque)->int', 'opaque', $closure);

  return $self->{perl_to_native_cmethod};
}

sub perl_to_native_post_cmethod {
  my($self) = @_;

  return $self->{perl_to_native_post_cmethod} if exists $self->{perl_to_native_post_cmethod};

  my $underlying_type = $self->{underlying_types}->[0];
  my $address = $underlying_type->perl_to_native_post_cmethod;

  return 0 unless $address;

  undef $underlying_type;

  my $sub = sub {
    my($arguments, $i, $type_sv, $extra_data, $arg, $freeme) = @_;

    my $f = $type_sv->{ffi}->function($address => ['opaque', 'int', 'SV', 'opaque', 'opaque', 'opaque'] => 'int');
    my $ret = $f->call($arguments, $i, $type_sv, $extra_data, $arg, $freeme);

    return $ret;
  };
  my $closure = $self->{ffi}->closure($sub);

  $self->{perl_to_native_post_closure} = $closure;

  my $ret = $self->{perl_to_native_post_cmethod} = $self->{ffi}->cast('(opaque, int, SV, opaque, long, long)->int', 'opaque', $closure);

  return $ret;
}

sub native_to_perl_cmethod {
  my($self) = @_;

  return $self->{native_to_perl_cmethod} if exists $self->{native_to_perl_cmethod};

  my $underlying_type = $self->{underlying_types}->[0];
  my $address = $underlying_type->native_to_perl_cmethod;

  return 0 unless $address;

  undef $underlying_type;

  my $sub = sub {
    my($resultp, $return_type, $extra_data) = @_;

    my $result = unpack 'P' . (8), pack 'Q', $resultp;
    my $result_hex = sprintf("%016x", unpack 'Q', $result);

    warn "result encoded as $result_hex..."; # it might be longer than that.

    my $ret = $return_type->{ffi}->function($address => ['SV', 'long', 'SV', 'opaque'] => 'SV')->call($resultp, $return_type, $extra_data);

    warn "return value is $ret";

    return $ret;
  };

  my $closure = $self->{ffi}->closure($sub);

  $self->{native_to_perl_closure} = $closure;

  my $ret = $self->{native_to_perl_cmethod} = $self->{ffi}->cast('(SV, long, SV, opaque)->SV', 'opaque', $closure);
  return $ret;
}

sub prepare_cmethod {
  my($self) = @_;

  return $self->{prepare_cmethod} if exists $self->{prepare_cmethod};

  my $underlying_type = $self->{underlying_types}->[0];
  my $underlying_extra_data = $underlying_type->extra_data;
  my $address = $underlying_type->prepare_cmethod;

  my $sub = sub {
    my ($getter_pointers, $getter_limits, $ffi_pointers, $ffi_limits, $type, $extra_data) = @_;

    my $ret = $type->{ffi}->function($address => ['opaque', 'opaque', 'opaque', 'opaque', 'SV', 'opaque'] => 'int')->call(undef, undef, $ffi_pointers, $ffi_limits, $underlying_type, $underlying_extra_data);

    return $ret;
  };

  my $closure = $self->{ffi}->closure($sub);

  $self->{prepare_closure} = $closure;

  my $ret = $self->{prepare_cmethod} = $self->{ffi}->cast('(opaque, opaque, opaque, opaque, SV, opaque)->int', 'opaque', $closure);
  return $ret;
}

sub extra_data {
  return 0;
}

sub argument_count {
  my($self) = @_;
  my $argument_count =  $self->{underlying_types}->[0]->argument_count;

  return $argument_count;
}

sub count_native_arguments {
  my($self) = @_;

  return $self->{underlying_types}->[0]->count_native_arguments;
}

sub new {
  my($class, $ffi, $basetype) = @_;

  return bless { underlying_types => [$basetype], ffi => $ffi }, $class;
}

1;
