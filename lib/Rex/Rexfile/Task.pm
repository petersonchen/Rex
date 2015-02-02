#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Rexfile::Task {
  use true;
  use Moose;
  use namespace::autoclean;

  has name        => ( is => 'ro' );
  has description => ( is => 'ro' );
  has code        => ( is => 'ro' );

  sub run {
    my $self = shift;
    $self->code->();
  }
}
