#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Syntax::Base {
  use true;
  use Moose;
  use namespace::autoclean;

  use Moose::Exporter;

  extends 'Rex::Object';

  has name => ( is => "ro", writer => "_set_name" );
  has app => ( is => "rw", default => sub { bless( {}, "Rex" ) } );

  Moose::Exporter->setup_import_methods( with_meta => ["dsl"], );

  sub BUILD { }

  sub dsl {
    my $meta     = shift;
    my $res_name = shift;

    $meta->superclasses(__PACKAGE__);

    $meta->add_before_method_modifier(
      "BUILD",
      sub {
        shift->_set_name($res_name);
      }
    );

  }

}
