#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
package Rex {
  use Data::Dumper;

  use true;
  use Moose;
  use MooseX::Params::Validate;
  use namespace::autoclean;

  use Rex::Rexfile::Parser;
  
  sub run {
    my ($self) = @_;

    my $rexfile_parser = Rex::Rexfile::Parser->new(app => $self);
    $rexfile_parser->parse();
  }

  sub add_task {
    my $self = shift;
    my $task = shift;

    push @{ $self->{__tasks__} }, $task;
  }

  sub run_task {
    my $self = shift;
    my $task_name = shift;

    my ($task) = grep { $_->name eq $task_name } @{ $self->{__tasks__} };

    $task->run;
  }

}

