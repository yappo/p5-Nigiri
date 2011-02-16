package Nigiri::Neta::RowBase;
use strict;
use warnings;

# in Nigiri->new
sub get_dbh { goto $_[0]->{'%NIGIRI_META'}->{context}->{get_dbh} }

sub save {
    my($self, ) = @_;

    my $is_update = grep {
        defined $_
    } values %{ $self->{'%NIGIRI_META'}->{original_data} };

    my @columns = grep {
        $self->{'%NIGIRI_META'}->{update_column}->{$_} == 1
    } keys %{ $self->{'%NIGIRI_META'}->{update_column} };

    my $dbh = $self->get_dbh;
    if ($is_update) {
        my @values;
        my @set_columns;

        # for set values
        for my $column (@columns) {
            push @values, $self->{$column};
            push @set_columns, $column . ' = ?';
        }

        # for where queries
        for my $column (@{ $self->{'%NIGIRI_META'}->{primary_keys} }) {
            push @values, $self->{$column};
        }

        my $sql = sprintf 'UPDATE %s SET %s WHERE %s',
            $self->{'%NIGIRI_META'}->{table_name},
            join(', ', @set_columns),
            $self->{'%NIGIRI_META'}->{primary_keys_where_sql};
        my $sth = $dbh->prepare($sql);
        $sth->execute(@values);
        $sth->finish;
        return;
    } else {
        my $sql = sprintf 'INSERT INTO %s (%s) VALUES(%s)',
            $self->{'%NIGIRI_META'}->{table_name},
            join(', ', @columns),
            join(', ', ('?') x scalar(@columns));
        my $sth = $dbh->prepare($sql);
        $sth->execute(map { $self->{$_} } @columns );
        my $last_insert_id = $dbh->last_insert_id(undef, undef, undef, undef);
        $sth->finish;
        return $last_insert_id;
    }
}

sub delete {
    my $self = shift;

    for my $column (@{ $self->{'%NIGIRI_META'}->{primary_keys} }) {
        return unless defined $self->{$column};
    }

    my @values;
    # for where queries
    for my $column (@{ $self->{'%NIGIRI_META'}->{primary_keys} }) {
        push @values, $self->{$column};
    }

    my $sql = sprintf 'DELETE FROM %s WHERE %s',
        $self->{'%NIGIRI_META'}->{table_name},
        $self->{'%NIGIRI_META'}->{primary_keys_where_sql};
    my $sth = $self->get_dbh->prepare($sql);
    $sth->execute(@values);
    $sth->finish;
    $sth->rows;
}

1;
