use t::Utils;
use Test::More;

my $nigiri = t::Utils->setup_nigiri;
my $user   = $nigiri->user;

my @users = (
    [ 1 => 'nekokak' ],
    [ 2 => 'yappo' ],
    [ 3 => 'tokuhirom' ],
    [ 4 => 'lestrrat' ],
    [ 5 => 'gfx' ],
    [ 6 => 'a666666' ],
    [ 7 => 'charsbar' ],
    [ 8 => 'kawanet' ],
);

do {
    for my $data (@users) {
        $user->new(
            id   => $data->[0],
            name => $data->[1],
        )->save;
    }
};

subtest 'get all' => sub {
    my $itr = $user->search;
    isa_ok($itr, 'Nigiri::Iterator');
    my @get_users;
    while (my $row = $itr->next) {
        isa_ok($row, 'Nigiri::Neta::AnonClass1::user::Row');
        push @get_users, [ $row->id, $row->name ];
    }
    @get_users = sort { $a->[0] <=> $b->[0] } @get_users;
    is_deeply(\@get_users, \@users);
};


subtest 'get where and order by' => sub {
    my $itr = $user->search(
        'WHERE name = ? OR name = ? OR name = ? ORDER BY id DESC',
        'kawanet', 'lestrrat', 'charsbar',
    );
    isa_ok($itr, 'Nigiri::Iterator');

    my @get_users;
    while (my $row = $itr->next) {
        isa_ok($row, 'Nigiri::Neta::AnonClass1::user::Row');
        push @get_users, [ $row->id, $row->name ];
    }
    is_deeply(\@get_users, [
        [ 8 => 'kawanet' ],
        [ 7 => 'charsbar' ],
        [ 4 => 'lestrrat' ],
    ]);
};

subtest 'get all rows order by desc' => sub {
    my $itr = $user->search(
        'ORDER BY id DESC',
    );
    isa_ok($itr, 'Nigiri::Iterator');

    my @get_users;
    while (my $row = $itr->next) {
        isa_ok($row, 'Nigiri::Neta::AnonClass1::user::Row');
        push @get_users, [ $row->id, $row->name ];
    }
    is_deeply(\@get_users, [ reverse @users ]);
};

subtest 'get where no result' => sub {
    my $itr = $user->search(
        'WHERE name = ? AND name = ? AND name = ? ORDER BY id DESC',
        'kawanet', 'lestrrat', 'charsbar',
    );
    isa_ok($itr, 'Nigiri::Iterator');
    ok($itr->next == undef);
};

done_testing;
