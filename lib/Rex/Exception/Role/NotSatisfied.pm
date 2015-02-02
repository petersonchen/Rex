#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::exception::Role::NotSatisfied {
  use true;
  use Moose;
  use namespace::autoclean;

  extends 'Rex::Exception::Base';
}



