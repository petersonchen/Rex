#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Rexfile::Base {
  use true;
  use Moose;
  use namespace::autoclean;
  use Rex::Rexfile::Task;

  sub evaluate {

    # just a stub
  }

  sub add_task {
    my $self = shift;

    #$self->{__tasks__}->{ $_[0] } = { code => $_[1], };
    my $task = Rex::Rexfile::Task->new(
      {
        name        => $_[0],
        code        => $_[1],
        description => "",
      }
    );

    push @{ $self->{__tasks__} }, $task;
  }

  sub run_task {
    my $self = shift;
    my $task = $self->get_task($_[0]);
    $task->run;
  }

  sub get_task {
    my $self = shift;
    my $name = shift;

    my ($task) = grep { $_->name eq $name } @{ $self->{"__tasks__"} };

    return $task;
  }
}
