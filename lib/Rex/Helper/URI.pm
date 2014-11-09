#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

use strict;

package Rex::Helper::URI;

use warnings;

sub encode {
  my ($part) = @_;
  $part =~ s/([^\w\-\.\@])/_encode_char($1)/eg;
  return $part;
}

sub _encode_char {
  my ($char) = @_;
  return "%" . sprintf "%lx", ord($char);
}

1;