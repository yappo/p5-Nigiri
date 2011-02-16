use t::Utils;
use Test::More;

my $nigiri = t::Utils->setup_nigiri;

subtest 'instance' => sub {
    isa_ok($nigiri, 'Nigiri::Neta::Base');
    isa_ok($nigiri, 'Nigiri::Neta::AnonClass1');
    can_ok($nigiri, qw/ user url bookmark /);
};

subtest 'columns' => sub {
    ok($nigiri->user->is_primary_key('id'));
    ok($nigiri->url->is_primary_key('id'));
    ok($nigiri->bookmark->is_primary_key('id'));

    is_deeply([$nigiri->user->get_primary_keys], ['id']);
    is_deeply([$nigiri->url->get_primary_keys], ['id']);
    is_deeply([$nigiri->bookmark->get_primary_keys], ['id']);

    is_deeply([$nigiri->user->get_columns], [qw/id name/]);
    is_deeply([$nigiri->url->get_columns], [qw/id title url/]);
    is_deeply([$nigiri->bookmark->get_columns], [qw/ id url_id user_id/]);
};

subtest 'create & save' => sub {
    my $user = $nigiri->user->new;
    isa_ok($user, 'Nigiri::Neta::RowBase');
    isa_ok($user, 'Nigiri::Neta::AnonClass1::user::Row');
    can_ok($user, qw/ id name save delete/);

    is($user->name('nekokak'), 'nekokak');
    my $user_id = $user->save;
    is($user_id, 1);

    my $url = $nigiri->url->new;
    isa_ok($url, 'Nigiri::Neta::RowBase');
    isa_ok($url, 'Nigiri::Neta::AnonClass1::url::Row');
    can_ok($url, qw/ id title url save delete/);

    is($url->title('Google'), 'Google');
    is($url->url('http://goo.gl/e'), 'http://goo.gl/e');
    my $url_id = $url->save;
    is($url_id, 1);


    my $bookmark = $nigiri->bookmark->new;
    isa_ok($bookmark, 'Nigiri::Neta::RowBase');
    isa_ok($bookmark, 'Nigiri::Neta::AnonClass1::bookmark::Row');
    can_ok($bookmark, qw/ id user_id url_id save delete/);

    is($bookmark->user_id($user_id), 1);
    is($bookmark->url_id($url_id), 1);
    my $bookmark_id = $bookmark->save;
    is($bookmark_id, 1);
};

subtest 'default values in table instance' => sub {
    my $user = $nigiri->user->new(
        id   => 2,
        name => 'yappo',
    );
    is($user->id, 2);
    is($user->name, 'yappo');

    my $user_id = $nigiri->user->new(
        name => 'tokuhirom',
    )->save;
    is($user_id, 2);
};

subtest 'get & update' => sub {
    my $user = $nigiri->user->lookup(1);
    is($user->id, 1);
    is($user->name, 'nekokak');
    is($user->name('yappo'), 'yappo');
    ok($user->save eq undef);

    my $user2 = $nigiri->user->lookup(1);
    is($user2->id, 1);
    is($user2->name, 'yappo');
};

subtest 'delete' => sub {
    my $user = $nigiri->user->lookup(1);
    is($user->delete, 1);
    is($user->delete, 0);

    my $user2 = $nigiri->user->lookup(1);
    ok($user2 eq undef);
};


done_testing;
