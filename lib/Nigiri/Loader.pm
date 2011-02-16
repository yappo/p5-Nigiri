package Nigiri::Loader;
use strict;
use warnings;

require Nigiri::Neta::Base;
require Nigiri::Neta::TableBase;
require Nigiri::Neta::RowBase;

use DBIx::Inspector;
use Package::Stash;

my $ANON_CLASS_COUNT = 1;

sub new {
    my($class, $context) = @_;

    my $inspector = DBIx::Inspector->new(dbh => $context->{dbh});
    bless {
        inspector => $inspector,
        context   => $context,
    }, $class;
}

sub load_schema {
    my($self, %args) = @_;

    my $base_class_name = $args{base_class};
    unless ($base_class_name) {
        $base_class_name = $self->crete_anon_base_class_name;
    }
    $self->{base_class_name} = $base_class_name;

    my $table_classes = {};
    for my $table_info ($self->{inspector}->tables) {
        $table_classes->{$table_info->name} = {
            table => $self->create_table_class($table_info),
            row   => $self->create_row_class($table_info),
        };
    }

    $self->create_base_class($table_classes);

    $base_class_name;
}

sub crete_anon_base_class_name {
    'Nigiri::Neta::AnonClass' . ($ANON_CLASS_COUNT++);
}

sub create_base_class {
    my($self, $table_classes) = @_;

    my $pkg = Package::Stash->new($self->{base_class_name});
    $pkg->add_package_symbol('@ISA', [ 'Nigiri::Neta::Base' ]);

    while (my($name, $class_names) = each %{ $table_classes }) {
        my $obj = bless {
            row_class  => $class_names->{row},
            context    => $self->{context},
        }, $class_names->{table};
        $pkg->add_package_symbol('&' . $name, sub {
            $obj
        });
    }
}

sub create_table_class {
    my($self, $table_info) = @_;

    my $class_name = join '::', $self->{base_class_name}, $table_info->name;

    my $pkg = Package::Stash->new($class_name);
    $pkg->add_package_symbol('@ISA', [ 'Nigiri::Neta::TableBase' ]);

    $pkg->add_package_symbol(
        '&get_table_name' => sub { $table_info->name }
    );

    my %primary_key = map {
        $_->name => 1
    } $table_info->primary_key;

    $pkg->add_package_symbol(
        '&is_primary_key' => sub { $primary_key{$_[1]} }
    );

    my @primary_keys = sort keys %primary_key;
    $pkg->add_package_symbol(
        '&get_primary_keys' => sub { @primary_keys }
    );

    my @columns = sort map { $_->name } $table_info->columns;
    $pkg->add_package_symbol(
        '&get_columns' => sub { @columns }
    );

    $class_name;
}

sub create_row_class {
    my($self, $table_info) = @_;

    my $class_name = join '::', $self->{base_class_name}, $table_info->name, 'Row';
    my $pkg = Package::Stash->new($class_name);
    $pkg->add_package_symbol('@ISA', [ 'Nigiri::Neta::RowBase' ]);

    for my $column ($table_info->columns) {
        my $column_name = $column->name;
        my $code = sub {
            return $_[0]->{_row_data}->{$column_name} unless defined $_[1];# not hove new value
            if ($_[0]->{_original_data}->{$column_name} && $_[1] eq $_[0]->{_original_data}->{$column_name}) {
                # not changed from original data
                $_[0]->{_update_column}->{$column_name} = 0;
                return $_[0]->{_row_data}->{$column_name} = $_[1];
            }
            # changed
            $_[0]->{_update_column}->{$column_name} = 1;
            return $_[0]->{_row_data}->{$column_name} = $_[1];
        };
        $pkg->add_package_symbol(
            '&' . $column_name => $code
        );
    }

    $class_name;
}

1;
