package Nigiri::Neta::Base;
use strict;
use warnings;

use DBIx::TransactionManager;
use Carp;

sub _verify_pid {
    my $self = shift;
    if ($self->{context}->{owner_pid} != $$) {
        Carp::confess('this connection is no use. because fork was done.');
    }
}
sub get_dbh {
    my $self = shift;
    $self->_verify_pid;
    $self->{context}->{dbh};
}

# TODO: re-set dbh
#sub set_dbh {
#    ${ $_[0]->{context}->{dbh} }       = $_[1];
#    ${ $_[0]->{context}->{owner_pid} } = $$;
#}


# copied from Teng
# for transaction
sub txn_manager  {
    $_[0]->{txn_manager} ||= DBIx::TransactionManager->new($_[0]->get_dbh);
}

sub in_transaction {
    $_[0]->{txn_manager} ? $_[0]->{txn_manager}->in_transaction : undef;
}

sub txn_scope    {
    my @caller = caller();
    $_[0]->txn_manager->txn_scope(caller => \@caller);
}

sub txn_begin    { $_[0]->txn_manager->txn_begin    }
sub txn_rollback { $_[0]->txn_manager->txn_rollback }
sub txn_commit   { $_[0]->txn_manager->txn_commit   }
sub txn_end      { $_[0]->txn_manager->txn_end      }

1;
