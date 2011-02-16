use common::sense;
use lib 'lib';
use Test::More;

use DBI;
use Nigiri;

my $dsn = 'dbi:SQLite:';
my $dbh = DBI->connect($dsn, '', '', {RaiseError => 1, PrintError => 0, AutoCommit => 1});
for my $sql (split /---\n/, do { local $/; <DATA> }) {
    $dbh->do($sql);
}
my $nigiri = Nigiri->new($dbh);

subtest 'do basic transaction' => sub {
    $nigiri->txn_begin;
    $nigiri->user->new(
        name => 'perl',
    )->save;
    $nigiri->txn_commit;

    is +$nigiri->user->lookup(1)->name, 'perl';
};

subtest 'do rollback' => sub {
    $nigiri->txn_begin;
    $nigiri->user->new(
        name => 'bash',
    )->save;
    $nigiri->txn_rollback;

    ok not +$nigiri->user->lookup(2);
};

subtest 'do commit' => sub {
    $nigiri->txn_begin;
    $nigiri->user->new(
        name => 'ruby',
    )->save;
    $nigiri->txn_commit;

    is +$nigiri->user->lookup(2)->name, 'ruby';
};

subtest 'scope rollback' => sub {
    do {
        local $SIG{__WARN__} = sub {};
        my $txn = $nigiri->txn_scope;
        $nigiri->user->new(
            name => 'zsh',
        )->save;
    };

    ok not +$nigiri->user->lookup(3);
};

subtest 'do commit' => sub {
    do {
        my $txn = $nigiri->txn_scope;
        $nigiri->user->new(
            name => 'python',
        )->save;
        $txn->commit;
    };
    is +$nigiri->user->lookup(3)->name, 'python';
};

done_testing;

__DATA__
CREATE TABLE user (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(255)
)
