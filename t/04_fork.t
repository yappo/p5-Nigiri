use t::Utils;
use Test::More;
use Test::SharedFork;

my $nigiri = t::Utils->setup_nigiri;
my $dbh = $nigiri->get_dbh;

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
