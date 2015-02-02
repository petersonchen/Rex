#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Rexfile::Parser {
  use true;
  use Moose;
  use MooseX::Params::Validate;
  use namespace::autoclean;
  use IO::File;
  use Data::Dumper;
  use Eval::WithLexicals;

  use Rex::Exception::Rexfile::Parser;

  has app     => (is => 'ro');
  has rexfile => ( is => 'ro', default => sub { "Rexfile" } );

  sub parse {
    my ($self) = @_;

    my @rexfile_content_a = ();
    my $fh = IO::File->new( $self->rexfile, "r" );
    while ( my $line = <$fh> ) {
      chomp $line;
      push @rexfile_content_a, $line;
    }

    my @rexfile_code = ();

    require Rex::DSL;
    Rex::DSL->import(-app => $self->app, -into  => "Rex::Rexfile::Parser::eval");

    push @rexfile_code, "package Rex::Rexfile::Parser::eval {";
    push @rexfile_code, "use true;";
    push @rexfile_code, "use Moose;";
    push @rexfile_code, "use namespace::autoclean;";
    push @rexfile_code, @rexfile_content_a;
    push @rexfile_code, "}\n1;\n";

    unshift @INC, sub {
      if($_[1] eq "Rex/Rexfile/Parser/eval.pm") {
        open my $fh, '<', \join("\n", @rexfile_code);
        shift @INC;
        $fh;
      }
      else {
        ();
      }
    };

    do "Rex/Rexfile/Parser/eval.pm";

    $self->app->run_task("test");
  }
}
