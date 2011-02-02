package Nigiri::Neta::TableBase;
use strict;
use warnings;

sub new {
    my $opts = {};
    $opts = pop @_ if scalar(@_) > 1 && ref $_[-1];
    my($self, %args) = @_;

    my $row_class = $self->{row_class};

    my %row_data = map {
        $_ => $args{$_} || undef
    } $self->get_columns;
    my %original_data = map {
        $_ => $opts->{from_db} ? $args{$_} || undef : undef
    } $self->get_columns;
    my %update_column = map {
        $_ => $opts->{from_db} ? 0 : $args{$_} ? 1 : 0
    } $self->get_columns;

    bless {
        _table_name             => $self->get_table_name,
        _row_data               => \%row_data,
        _original_data          => \%original_data,
        _update_column          => \%update_column,
        _primary_keys           => [ $self->get_primary_keys ],
        _primary_keys_where_sql => $self->get_primary_keys_where_sql,
        _dbh                    => $self->{dbh},
    }, $row_class;
}

sub get_primary_keys_where_sql {
    my $self = shift;
    my @pk_queries;
    for my $column ($self->get_primary_keys) {
        push @pk_queries, $column . ' = ?';
    }
    join('AND ', @pk_queries);
}

sub lookup {
    my($self, @keys) = @_;

    my @bind;
    my %rec;
    for my $column ($self->get_columns) {
        push @bind, \$rec{$column};
    }

    my $sql = sprintf 'SELECT %s FROM %s WHERE %s',
        join(', ', $self->get_columns),
        $self->get_table_name,
        $self->get_primary_keys_where_sql;

    my $sth = $self->{dbh}->prepare($sql);
    $sth->execute(@keys);
    $sth->bind_columns(undef, @bind);

    my $rv = $sth->fetch;
    $sth->finish;
    undef $sth;
    return unless $rv;
    $self->new(%rec, { from_db => 1 });
}

1;
