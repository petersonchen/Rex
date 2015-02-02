#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::DSL {

  use strict;
  use warnings;
  use true;
  use File::Spec;
  use Data::Dumper;
  use MooseX::Params::Validate;

  use Rex::Exception::RexPathNotFound;

  sub _find_rex_path {
    my $self = shift;

    my $rex_inc_path;
    for my $inc_path (@INC) {
      my $rex_lib_path = File::Spec->catfile( $inc_path, "Rex.pm" );
      if ( -f $rex_lib_path ) {
        $rex_inc_path = $inc_path;
        last;
      }
    }

    if ( !$rex_inc_path ) {
      Rex::Exception::RexPathNotFound->throw(
        {
          code    => 123,
          message => "Can't find Rex in your Perl library path.",
        }
      );
    }

    return $rex_inc_path;
  }

  sub _get_resources_to_load {
    my $self = shift;
    my (%option) = validated_hash( \@_, path => { isa => 'Str', } );

    $self->_get_modules_from_path({ path => $option{path}, sub_path => ["Rex", "Resource"] });
  }

  sub _get_dsl_functions_to_load {
    my $self = shift;
    my (%option) = validated_hash( \@_, path => { isa => 'Str', } );

    $self->_get_modules_from_path({ path => $option{path}, sub_path => ["Rex", "Syntax"] });
  }

  sub _get_modules_from_path {
    my $self = shift;
    my (%option) = validated_hash( \@_, path => { isa => 'Str', }, sub_path => { isa => 'ArrayRef' } );

    my $rex_inc_path = $option{path};

    my @found_modules;

    my $resource_path = File::Spec->catdir( $rex_inc_path, @{ $option{sub_path} } );
    opendir( my $dh, $resource_path ) or die($!);
    while ( my $entry = readdir($dh) ) {
      next if ( $entry =~ m/^\./ );
      next if ( -d File::Spec->catdir( $resource_path, $entry ) );
      next if ( $entry eq "Base.pm" );
      my $resource_klass = File::Spec->catfile( $resource_path, $entry );
      $resource_klass =~ s/^\Q$rex_inc_path\E//;
      $resource_klass =~ s/\//::/g;
      $resource_klass =~ s/\.pm$//;
      $resource_klass =~ s/^:://;

      push @found_modules, $resource_klass;
      closedir($dh);

      return @found_modules;
    }

    sub _import_function_to_ns {
      my $self = shift;
      my (%option) = validated_hash(
        \@_,
        function  => { isa => 'Str', },
        namespace => { isa => 'Str', },
        scope     => { isa => 'Rex::Object', },
      );

      {
        my $package  = $option{namespace};
        my $res_name = $option{function};
        my $res_obj  = $option{scope};
        no strict 'refs';

        *{"${package}::${res_name}"} = sub {
          $res_obj->execute(@_);
        };
      }
    }

    sub import {

      my $class  = shift;
      my %option = @_;

      my $app = $option{"-app"} || Rex->new;
      my $package = $option{"-into"};

      my ( $caller_package, $caller_filename, $caller_line ) = caller(0);
      $package ||= $caller_package;

      my $rex_inc_path = $class->_find_rex_path();
      my @resources_to_load =
        $class->_get_resources_to_load( { path => $rex_inc_path } );

      my @dsl_functions_to_load = 
        $class->_get_dsl_functions_to_load( { path => $rex_inc_path } );

      for my $resource_klass (@resources_to_load, @dsl_functions_to_load) {
        eval "use $resource_klass;";
        if ($@) {
          die "Error: $@";
        }
        my $resource_obj = $resource_klass->new(
          {
            app => $app
          }
        );
        my $res_name = $resource_obj->name;

        $class->_import_function_to_ns(
          {
            function  => $res_name,
            namespace => $package,
            scope     => $resource_obj,
          }
        );
      }

    }

  }
}
