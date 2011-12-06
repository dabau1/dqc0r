package Data::Msg::UserCommands::Status;

use 5.010;
use warnings;
use utf8;
use Mojo::Util 'md5_sum';

sub set_pw {
    my $user = shift;
    my $oldpw = md5_sum( shift );
    my $newpw = md5_sum( shift );
    my $dbh = Data::dbh();
    my $sql = <<'EOSQL';
SELECT 1 FROM ben_benutzer
WHERE lower(ben_user)=lower(?) AND ben_pw=?
EOSQL
    return 'Passwortsetzen fehl geschlagen: Das alte Passwort war nicht korrekt!'
        unless $dbh->selectrow_array($sql, undef, $user, $oldpw);
    $sql = <<'EOSQL';
UPDATE ben_benutzer
SET ben_pw=?
WHERE lower(ben_user)=lower(?)
EOSQL
    $dbh->do($sql, undef, $newpw, $user);
    return 'Passwort erfolgreich gesetzt'
}

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

