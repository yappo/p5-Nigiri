use common::sense;
use lib 'lib';
use Test::More;
use Test::SharedFork;

use DBI;
use Nigiri;

my $dsn = 'dbi:SQLite:';
my $dbh = DBI->connect($dsn);
for my $sql (split /---\n/, do { local $/; <DATA> }) {
    $dbh->do($sql);
}
my $nigiri = Nigiri->new($dbh);

$nigiri->user->new(
    name => 'sh',
)->save;
$nigiri->user->new(
    name => 'bash',
)->save;
$nigiri->user->new(
    name => 'zsh',
)->save;

my ($count) = $nigiri->get_dbh->selectrow_array('SELECT COUNT(*) FROM user');
is $count, 3;

done_testing;

__DATA__
CREATE TABLE user (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(255)
)
