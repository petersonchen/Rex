#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Syntax {

  use Data::Dumper;

  use true;
  use Moose;
  use namespace::autoclean;

  use Moose::Exporter;
  use File::Spec;

  Moose::Exporter->setup_import_methods( with_meta => ["register_resources"], );

  sub register_resources {
    my $meta = shift;

    my ($package, $filename, $line) = caller(1);

    $meta->add_before_method_modifier(
      "evaluate",
      sub {
        my $self = shift;

        my $rex_inc_path;
        for my $inc_path (@INC) {
          my $rex_lib_path = File::Spec->catfile($inc_path, "Rex.pm");
          if(-f $rex_lib_path) {
            $rex_inc_path = $inc_path;
            last;
          }
        }

        if(! $rex_inc_path) { die "Rex not found."; }

        my $resource_path = File::Spec->catdir($rex_inc_path, "Rex", "Resource");
        opendir(my $dh, $resource_path) or die($!);
        while(my $entry = readdir($dh)) {
          next if($entry =~ m/^\./);
          next if($entry eq "Base.pm");
          my $resource_klass = File::Spec->catfile($resource_path, $entry);
          $resource_klass =~ s/^\Q$rex_inc_path\E//;
          $resource_klass =~ s/\//::/g;
          $resource_klass =~ s/\.pm$//;
          $resource_klass =~ s/^:://;

          eval "use $resource_klass;";
          if($@) {
            die "Error: $@";
          }

          my $resource_obj = $resource_klass->new({app => $self->app});
          my $res_name = $resource_obj->name;

          {
            no strict 'refs';
            no warnings;
            print "OVERWRITE! $package / $res_name\n";
            $meta->add_method($res_name, sub { print "OVERWRITTEN: $res_name!!!\n"; });
            *{"${package}::${res_name}"} = sub {
              print "Syntax: running: $res_name \n";
            #  #my $obj = $caller_package->new( { name => $res_name } );
            #  #$obj->execute;
            };
          }
        }
        closedir($dh);

      }
    );
  }
}
