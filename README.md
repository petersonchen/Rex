# Rex 2

This is the development branch for Rex 2.

## Code Structure

The main difference to Rex 1 is that Rex.pm is an object that holds every data. So there is no global object anymore.

Every command is now an object that has access to the application through ```$self->app```.

### Rex DSL

These are the base functions. Like ```task```, ```user```, ```password``` and so on.

To create a new DSL function it is necessary to create a new package. This package represent an object.

```perl
package Rex::Syntax::task {
  use Data::Dumper;

  use true;
  use Moose;
  use namespace::autoclean;

  use Rex::Syntax::Base;
  use Rex::Rexfile::Task;

  # define a new dsl function named "task"
  dsl "task";

  # this gets executed if the "task" function is called from a Rexfile.
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
```

### Resources

Resources are functions that describe a state of a specific *thing* on the server. For example a *file*, a *package* or a *service*.

Resources consist of a resource definition and one (or more) implementations.

The resource definition defines the behaviour of a resource.

```perl
package Rex::Resource::File {
  use true;
  use Moose;
  use namespace::autoclean;

  use Rex::Resource::Base;

  resource "file" => (is => [qw/Ensurable/]);
}
```

This example resource defines a new resource named *file*. This will create a function *file* that can be used in the *Rexfile*. Also it will add the Role *Rex::Resource::Role::Ensurable* to the implementations of this resource. These roles defines the method that the implementations of this resource must implement.

which implementation of a resource the current run should use is defined by the implementation or can be forced with a parameter.

```perl
package Rex::Provider::File::posix {
  use true;
  use Moose;
  use namespace::autoclean;

  extends 'Rex::Provider::Base';

  # use this provider if the connection is
  # currently to a linux system.
  fact_is osfamily => "linux";

  sub present {
    my $self = shift;
    # create the file
    print ">>> file: present (" . $self->name . ")\n";
  }

  sub absent {
    my $self = shift;
    # remove the file
    print ">>> file: absent\n";
  }
}
```

This example implementation will be chosen if the remote system has the osfamily *linux*. 


### Remote Execution Functions

There are functions that doesn't have a state. For example ```ping```, ```is_file```, ...


## Gathering facts from the remote system


## SSH Connection


## State handling



