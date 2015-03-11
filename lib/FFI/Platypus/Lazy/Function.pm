package FFI::Platypus::Lazy::Function;
use parent -norequire, 'FFI::Platypus::Function';
use Scalar::Util qw(weaken);
use Carp qw(croak);
use Carp::Always;
use overload
    bool => sub { my $self = shift; $self->realize },
    '""' => sub { my $self = shift; $self->realize },
    '0+' => sub { my $self = shift; $self->realize },
    'eq' => sub {
      my($self, $other) = @_;
      $self->realize eq ($other->can('realize') ? $other->realize : $other);
    },
    'cmp' => sub {
      my($self, $other) = @_;
      $self->realize cmp ($other->can('realize') ? $other->realize : $other);
    },
    '<=>' => sub {
      my($self, $other) = @_;
      $self->realize <=> ($other->can('realize') ? $other->realize : $other);
    },
    '&{}' => sub {
      my $self = shift;

      if($self->realize) {
	return sub { $self->realize->(@_); };
      } else {
	return;
      }
    };

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

  return unless defined $self->{address};

  my $real = $self->{return_type};
  $real = $real->realize while $real->can('realize');
  $self->{return_type} = $real;

  return unless $self->{return_type};

  my @args = map { $_->can('realize') ? $_->realize : $_ } @{$self->{argument_types}};
  $self->{argument_types} = \@args;

  return if grep { !$_ } @args;

  $self->{base} = $self->{ffi}->impl_new_function($self->{address}, $self->{return_type}, @{$self->{argument_types}});
  $self->{realized} = 1;

  $real = $self->{base};
  $real = $real->realize while $real->can('realize');
  $self->{base} = $real;

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

  if(!$self) {
    return;
  }

  $self->realize->attach($attach_name, $attach_location, $proto);

  return 1;
}

use Data::Dumper;

sub _make_attach_method {
  my($interpreter, $data) = @_;
  my $function = $data->{function};

  croak "lazy function has been deleted" unless $function;

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
  # XXX this depends on the Perl interpreter argument actually being present and breaks on non-threaded Perl.
  $self->{data}->{body} = $ffi->cast('(opaque, SV, int)->void' => 'opaque', $self->{body_closure});
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
