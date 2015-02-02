#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Exception::Base {
  use true;
  use Moose;
  use namespace::autoclean;

  with 'Throwable';

  has message => (is => 'ro');
  has code    => (is => 'ro', default => sub { 0 });
}
