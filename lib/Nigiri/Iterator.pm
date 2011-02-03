package Nigiri::Iterator;
use strict;
use warnings;
use overload
    '<>' => sub { $_[0]->next },
    fallback => 1;


sub new {
    my($class, %args) = @_;
    bless {
        sth   => $args{sth},
        rec   => $args{rec},
        table => $args{table},
    }, $class;
}

sub next {
    my $self = shift;
    return unless $self->{sth};
    unless ($self->{sth}->fetch) {
        $self->end;
        return;
    }
    $self->{table}->new(%{ $self->{rec} }, { from_db => 1 });
}

sub end {
    my $self = shift;
    if ($self->{sth}) {
        $self->{sth}->finish;
        delete $self->{sth};
    }
    return;
}

sub DESTROY { shift->end };

1;

