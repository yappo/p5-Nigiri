package Nigiri;
use strict;
use warnings;
our $VERSION = '0.01';

use DBI;

use Nigiri::Loader;

sub new {
    my($class, $target, %args) = @_;

    my $dbh;
    if (ref $target eq 'DBI::db') {
        $dbh = $target;
    } else {
        $dbh = DBI->connect(
            $target,
            $args{username},
            $args{auth},
            $args{attr}
        ) or die "connect failed: $target";
    }
    my $loader = Nigiri::Loader->new($dbh);

    my $klass = $loader->load_schema;

    bless {
        dbh => $dbh,
    }, $klass;
}

1;
__END__

=head1 NAME

Nigiri - micro ORM

=head1 SYNOPSIS

  use Nigiri;

=head1 DESCRIPTION

Nigiri is

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {at} shibuya {dot} plE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
