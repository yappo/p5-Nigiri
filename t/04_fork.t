use common::sense;
use lib 'lib';
use Test::More;
use Test::SharedFork;

use DBI;
use Nigiri;

my $dsn = 'dbi:SQLite:';
my $dbh = DBI->connect($dsn, '', '', {RaiseError => 1, PrintError => 0, AutoCommit => 1});
for my $sql (split /---\n/, do { local $/; <DATA> }) {
    $dbh->do($sql);
}
my $nigiri = Nigiri->new($dbh);

unless (fork) {
    # root class
    do {
        local $@;
        eval { $nigiri->get_dbh };
        ok $@;
        like $@, qr/this connection is no use\. because fork was done\./;
    };

    # table class
    do {
        local $@;
        eval { $nigiri->user->lookup(1) };
        ok $@;
        like $@, qr/this connection is no use\. because fork was done\./;
    };

    # row class
    do {
        local $@;
        eval { $nigiri->user->new( name => 'foo' )->save };
        ok $@;
        like $@, qr/this connection is no use\. because fork was done\./;
    };

    # transaction
    do {
        local $@;
        eval { $nigiri->txn_begin };
        ok $@;
        like $@, qr/this connection is no use\. because fork was done\./;
    };

    exit;
}

wait;
is +$nigiri->get_dbh, $dbh, 'dbh';
done_testing;

__DATA__
CREATE TABLE user (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(255)
)
