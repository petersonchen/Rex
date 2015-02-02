#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
package Rex::Provider::Base {
  use true;
  use Moose;
  use namespace::autoclean;
  use Data::Dumper;

  has app => (is => 'ro');
  has name => (is => 'ro', writer => '_set_name');

}
