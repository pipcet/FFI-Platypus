package FFI::Platypus::Function::RTypes;
use parent 'FFI::Platypus::Function';

use strict;
use warnings;
use 5.008001;
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );
