package FFI::Platypus::Function::Lazy;
use parent -norequire, 'FFI::Platypus::Function';
use Scalar::Util qw(weaken);
use Carp qw(croak);
use Carp::Always;

sub new
{
  my($class, $ffi, $address, $ret, @args) = @_;
  my $self = bless {}, $class;

  $self->{ffi} = $ffi;
  $self->{address} = $address;
  $self->{return_type} = $ret;
  $self->{argument_types} = \@args;

  return $self;
}

sub realize
{
  my($self) = @_;

  return $self->{base} if $self->{realized};

  $self->{address} = $self->{address}->realize
      if ref $self->{address} and $self->{address}->can('realize');
  $self->{return_type} = $self->{return_type}->realize
      if $self->{return_type}->can('realize');
  my @args = map { $_->can('realize') ? $_->realize : $_ } @{$self->{argument_types}};
  $self->{argument_types} = \@args;

  $self->{base} = $self->{ffi}->impl_new_function($self->{address}, $self->{return_type}, @{$self->{argument_types}});
  $self->{realized} = 1;

  return $self->{base};
}

sub call
{
  my($self, @args) = @_;
  my $base = $self->{base};

  $self->realize->call(@args);
}

sub attach
{
  my($self, $attach_name, $attach_location, $proto) = @_;

  $self->realize->attach($attach_name, $attach_location, $proto);
}

use Data::Dumper;

sub _make_attach_method {
  my($data) = @_;
  my $function = $data->{function};

  croak "lazy function has been deleted" unless defined $function;

  # replace ourselves
  $function->realize->attach_method($data->{ffi},
				    $data->{in_object},
				    $data->{in_object_key},
				    $data->{out_object},
				    $data->{drop_first_argument},
				    $data->{attach_name},
				    $data->{attach_location},
				    $data->{proto});
}

sub attach_method
{
  my($self, $ffi, $in_object, $in_object_key, $out_object, $drop_first_argument, $attach_name, $attach_location, $proto) = @_;

  my $data = {};

  $data->{function} = $self;

  $data->{ffi} = $self->{ffi}; # not $ffi!
  $data->{in_object} = $in_object;
  $data->{in_object_key} = $in_object_key;
  $data->{out_object} = $out_object;
  $data->{drop_first_argument} = $drop_first_argument;
  $data->{attach_name} = $attach_name;
  $data->{attach_location} = $attach_location;
  $data->{proto} = $proto;

  $self->{body_closure} = $ffi->closure(\&_make_attach_method);
  $self->{data} = $data;

  $self->{data}->{function} = $self;
  $self->{data}->{body} = $ffi->cast('(SV, int)->void' => 'opaque', $self->{body_closure});
  $self->{data}->{my_name} = $attach_name;
  $self->{data}->{ffi} = $ffi;
  $self->{data}->{argument} = $out_object unless $drop_first_argument;
  if(ref $object)
  {
    $self->{data}->{weakref} = $object;
    weaken $self->{data}->{weakref};
  }

  return $ffi->_attach_body_data($in_object, $in_object_key, $in_object, 0, $attach_name, $attach_location, $proto, attach_method_lazy_address(), \$self->{data});
}

sub DESTROY {
};

1;