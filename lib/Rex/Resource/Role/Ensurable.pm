#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Resource::Role::Ensurable {
  use true;
  use Moose::Role;
  use namespace::autoclean;
  use Data::Dumper;
  use MooseX::Params::Validate;

  requires 'absent', 'present';

  sub execute {
    my $self = shift;
    my $name = shift;
    my %option = validated_hash(
      \@_,
      ensure => { isa => 'Str', default => 'present', },
      MX_PARAMS_VALIDATE_ALLOW_EXTRA => 1,
    );

    $self->_set_name($name);

    if($option{ensure} eq "present") {
      $self->present(@_);
    }
    elsif($option{ensure} eq "absent") {
      $self->absent(@_);
    }
  }
}
