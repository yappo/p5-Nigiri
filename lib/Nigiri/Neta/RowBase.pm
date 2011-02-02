package Nigiri::Neta::RowBase;
use strict;
use warnings;

sub save {
    my($self, ) = @_;

    my $is_update = grep {
        defined $_
    } values %{ $self->{_original_data} };

    my @columns = grep {
        $self->{_update_column}->{$_} == 1
    } keys %{ $self->{_update_column} };

    if ($is_update) {
        my @values;
        my @set_columns;

        # for set values
        for my $column (@columns) {
            push @values, $self->{_row_data}->{$column};
            push @set_columns, $column . ' = ?';
        }

        # for where queries
        for my $column (@{ $self->{_primary_keys} }) {
            push @values, $self->{_row_data}->{$column};
        }

        my $sql = sprintf 'UPDATE %s SET %s WHERE %s',
            $self->{_table_name},
            join(', ', @set_columns),
            $self->{_primary_keys_where_sql};
        my $sth = $self->{_dbh}->prepare($sql);
        $sth->execute(@values);
        $sth->finish;
        return;
    } else {
        my $sql = sprintf 'INSERT INTO %s (%s) VALUES(%s)',
            $self->{_table_name},
            join(', ', @columns),
            join(', ', ('?') x scalar(@columns));
        my $sth = $self->{_dbh}->prepare($sql);
        $sth->execute(map { $self->{_row_data}->{$_} } @columns );
        my $last_insert_id = $self->{_dbh}->last_insert_id(undef, undef, undef, undef);
        $sth->finish;
        return $last_insert_id;
    }
}

sub delete {
    my $self = shift;

    for my $column (@{ $self->{_primary_keys} }) {
        return unless defined $self->{_row_data}->{$column};
    }

    my @values;
    # for where queries
    for my $column (@{ $self->{_primary_keys} }) {
        push @values, $self->{_row_data}->{$column};
    }

    my $sql = sprintf 'DELETE FROM %s WHERE %s',
        $self->{_table_name},
        $self->{_primary_keys_where_sql};
    my $sth = $self->{_dbh}->prepare($sql);
    $sth->execute(@values);
    $sth->finish;
    $sth->rows;
}

1;
