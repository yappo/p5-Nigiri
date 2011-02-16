package Nigiri::Neta::Base;
use strict;
use warnings;

use DBIx::TransactionManager;
use Carp;

sub _verify_pid {
    my $self = shift;
    if ($self->{owner_pid} != $$) {
        Carp::confess('this connection is no use. because fork was done.');
    }
}
sub get_dbh {
    my $self = shift;
    $self->_verify_pid;
    $self->{dbh};
}

# copied from Teng
# for transaction
sub txn_manager  {
    $_[0]->_verify_pid;
    $_[0]->{txn_manager} ||= DBIx::TransactionManager->new($_[0]->{dbh});
}

sub in_transaction {
    $_[0]->{txn_manager} ? $_[0]->{txn_manager}->in_transaction : undef;
}

sub txn_scope    { $_[0]->txn_manager->txn_scope    }
sub txn_begin    { $_[0]->txn_manager->txn_begin    }
sub txn_rollback { $_[0]->txn_manager->txn_rollback }
sub txn_commit   { $_[0]->txn_manager->txn_commit   }
sub txn_end      { $_[0]->txn_manager->txn_end      }

1;
