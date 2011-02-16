package t::Utils;
use strict;
use warnings;
use utf8;

use DBI;
use Nigiri;

sub import {
    strict->import;
    warnings->import;
    utf8->import;
}

sub setup_nigiri {
    my $dsn = 'dbi:SQLite::memory:';
    my $dbh = DBI->connect($dsn, '', '', {RaiseError => 1, PrintError => 0, AutoCommit => 1});

    my $schema = <<SQL;
CREATE TABLE user (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(255)
)
---
CREATE TABLE url (
    id INTEGER NOT NULL PRIMARY KEY,
    title VARCHAR(255),
    url   VARCHAR(255)
)
---
CREATE TABLE bookmark (
    id INTEGER NOT NULL PRIMARY KEY,
    user_id INT,
    url_id INT,
    UNIQUE (user_id, url_id)
)
---
CREATE INDEX url_id ON bookmark (url_id)
SQL

    for my $sql (split /---\n/, $schema) {
        $dbh->do($sql);
    }
    Nigiri->new($dbh);
}

1;
