package FFI::Platypus::GDB::Fragment;

my @fragments;

sub fragment($) {
  my $str = shift;

  push @fragments, $str;

  return $str;
}

# taken from Declare.pm

sub import {
  my $caller = caller;
  *{join '::', $caller, 'fragment'} = \&fragment;
}

sub show_fragments {
  for my $fragment (@fragments) {
    #print "\n------------------------\nFRAGMENT\n$fragment\n\n\n---------------\n";
    print $fragment . "\n";
  }
}

return 1;
