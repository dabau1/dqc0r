package Data::Msg::UserCommands::Status;

use 5.010;
use warnings;
use utf8;

sub update_refresh {
    my ( $user, $interval ) = @_;

    my $sql = << 'EOSQL';
UPDATE log_login SET refresh=?
WHERE lower(ben_fk)=lower(?)
EOSQL
    Data::dbh()->do( $sql, undef, $interval, $user );
}

sub update_state {
    my ( $user, $status ) = @_;
    my $sql = << 'EOSQL';
UPDATE ben_benutzer
SET ben_status = ?
WHERE lower(ben_user)=lower(?)
EOSQL
    Data::dbh()->do( $sql, undef, $status, $user );
}

1;

