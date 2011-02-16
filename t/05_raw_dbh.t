use t::Utils;
use Test::More;

my $nigiri = t::Utils->setup_nigiri;

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
