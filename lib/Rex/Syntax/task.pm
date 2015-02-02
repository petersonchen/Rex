#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Syntax::task {
  use Data::Dumper;

  use true;
  use Moose;
  use namespace::autoclean;

  use Rex::Syntax::Base;
  use Rex::Rexfile::Task;

  dsl "task";

  sub execute {
    my $self = shift;
    my ( $task_name, @options ) = @_;

    my $code = pop @options;

    my $task = Rex::Rexfile::Task->new(
      {
        name        => $task_name,
        code        => $code,
        description => "",
      }
    );

    $self->app->add_task($task);
  }

}
