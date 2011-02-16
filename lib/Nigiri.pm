package Nigiri;
use strict;
use warnings;
our $VERSION = '0.01';

use DBI;

use Nigiri::Loader;

sub new {
    my($class, $target, %args) = @_;

    my $dbh;
    if (ref $target eq 'DBI::db') {
        $dbh = $target;
    } else {
        $dbh = DBI->connect(
            $target,
            $args{username},
            $args{auth},
            $args{attr}
        ) or die "connect failed: $target";
    }
    my $loader = Nigiri::Loader->new($dbh);

    my $klass = $loader->load_schema;

    bless {
        dbh         => $dbh,
        txn_manager => undef, # for transaction, handling in Nigiri::Neta::Base
        owner_pid   => $$,
    }, $klass;
}

1;
__END__

=head1 NAME

Nigiri - micro ORM

=head1 SYNOPSIS

your sql schema in sqlite

    CREATE TABLE user (
        id INTEGER NOT NULL PRIMARY KEY,
        name VARCHAR(255)
    );
    CREATE TABLE url (
        id INTEGER NOT NULL PRIMARY KEY,
        title VARCHAR(255),
        url   VARCHAR(255)
    );
    CREATE TABLE bookmark (
        id INTEGER NOT NULL PRIMARY KEY,
        user_id INT,
        url_id INT,
        UNIQUE (user_id, url_id)
    );
    CREATE INDEX url_id ON bookmark (url_id);

in perl code

    use Nigiri;
    
    my $nigiri = Nigiri->new('dbi:SQLite:dbname=example.db');
    
    # insert user table
    my $user = $nigiri->user->new;
    $user->name('nekokak');
    my $user_id = $user->save;
    
    # insert url table
    my $url = $nigiri->url->new;
    $url->title('Google');
    $url->url('http://goo.gl/e');
    my $url_id = $url->save;
    
    # insert bookmark table
    my $bookmark = $nigiri->bookmark->new;
    $bookmark->user_id($user_id);
    $bookmark->url_id($url_id);
    my $bookmark_id = $bookmark->save;
    
    # insert syntax sugar
    my $user_id = $nigiri->user->new(
        name => 'yappo',
    )->save;
    
    # lookup & update table
    my $user = $nigiri->user->lookup(1);
    $user->name('yappo');
    $user->update;
    
    # delete table
    $user->delete;
    
    # search
    my $itr = $nigiri->user->search(
        'WHERE name = ? OR name = ? ORDER BY id DESC LIMIT 10',
        'nekokak', 'yappo'
    );
    while (my $row = $itr->next) {
        say $row->id, $row->name;
    }

    # transaction
    do {
        my $txn = $nigiri->txn_scope;
        $row->save;
    }; # rollback
    do {
        my $txn = $nigiri->txn_scope;
        $row->save;
        $txn->commit;
    };

=head1 DESCRIPTION

Nigiri is

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {at} shibuya {dot} plE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
