#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Resource::Base {
  use Data::Dumper;

  use true;
  use Moose;
  use namespace::autoclean;

  use Moose::Exporter;
  use File::Spec;

  use Rex::Exception::Role::NotSatisfied;

  extends 'Rex::Object';

  Moose::Exporter->setup_import_methods( with_meta => ["resource"], );

  has name => ( is => "ro", writer => "_set_name" );
  has app => ( is => "rw", default => sub { bless( {}, "Rex" ) } );

  sub get_provider_object {
    my $self = shift;

    my @provider_class_path =
      map { s/^Resource$/Provider/; $_; } split( /::/, ref($self) );

    for my $inc_path (@INC) {
      my $class_path = File::Spec->catdir( $inc_path, @provider_class_path );
      if ( -d $class_path ) {
        opendir( my $dh, $class_path ) or die($!); #Rex::Exception::NoPermission->throw({message => "Can't open directory. $class_path.", code => 300});
        while ( my $entry = readdir($dh) ) {
          next if ( $entry =~ m/^\./ );
          my $class_file = File::Spec->catfile( $class_path, $entry );
          if ( -f $class_file ) {
            my $klass = join( "::", @provider_class_path, $entry );
            $klass =~ s/\.pm$//;
            print "load klas: $klass\n";
            eval "use $klass;";
            if ($@) {
              confess "Error: $@";
            }
            my $provider_obj = $klass->new( { app => $self->app } );
            return $provider_obj;
          }
        }
        closedir($dh);
      }
    }
  }

  sub execute {
    my $self = shift;
    my $obj = $self->get_provider_object();

    for my $role ( @{ $self->meta->{__resource_roles__} } ) {
      my $meta_klass = "Rex::Resource::Role::$role";
      eval "use $meta_klass;";
      $meta_klass->meta->apply($obj);
    }

    $obj->execute(@_);
  }

  # empty constructor
  sub BUILD { }

  sub resource {
    my $meta     = shift;
    my $res_name = shift;
    my %options  = @_;

    $meta->superclasses(__PACKAGE__);

    $meta->add_before_method_modifier(
      "BUILD",
      sub {
        shift->_set_name($res_name);
      }
    );

    if ( exists $options{is} && ref $options{is} eq "ARRAY" ) {
      $meta->{__resource_roles__} = $options{is};
    }
  }
}
