package Data::Msg::UserCommands::News;

use 5.010;
use warnings;
use utf8;
use Data;

sub insert_news {
    my ( $userid, $txt, $timestamp ) = @_;
    my $sql = << 'EOSQL';
INSERT INTO not_notiz
(ben_fk, not_notiz, not_date)
VALUES (?, ?, ?)
EOSQL
    Data::dbh()->do( $sql, undef, $userid, $txt, $timestamp );
}

sub check_editability {
    my ( $id, $userid, $admin) = @_;
    return 1 if $admin;
    my $sql = << 'EOSQL';
SELECT 1 FROM not_notiz
WHERE not_id=? AND ben_fk=?
EOSQL
    return ( Data::dbh()->selectrow_array($sql, undef, $id, $userid) )
        ? 1 : 0
}

sub delete_news {
    my $id = shift;
    my $sql = << 'EOSQL';
DELETE FROM not_notiz
WHERE not_id=?
EOSQL
    Data::dbh()->do( $sql, undef, $id );
}

1;

