#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Provider::File::posix {
  use true;
  use Moose;
  use namespace::autoclean;

  extends 'Rex::Provider::Base';

#  fact_is osfamily => "linux",
#          foo      => "bar";

  sub present {
    my $self = shift;
    print ">>> file: present (" . $self->name . ")\n";
  }

  sub absent {
    my $self = shift;
    print ">>> file: absent\n";
  }
}


