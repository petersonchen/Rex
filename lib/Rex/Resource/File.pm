#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Resource::File {
  use true;
  use Moose;
  use namespace::autoclean;

  use Rex::Resource::Base;

  resource "file" => (is => [qw/Ensurable/]);
}
