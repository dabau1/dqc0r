package Data::Auth;

use 5.010;
use warnings;
use utf8;
use Data;
use Data::Msg;

sub get_userdata {
    my ( $user, $pass ) = @_;
    my $sql = << 'EOSQL';
SELECT ben_admin, ben_status, ben_news, ben_id i
FROM ben_benutzer 
WHERE lower(ben_user)=lower(?) AND ben_pw=?
EOSQL
    Data::dbh()->selectrow_array( $sql, undef, $user, $pass );
}

sub get_lastsessiondata {
    my $user = shift;

    my $dbh = Data::dbh();
    $sql = << 'EOSQL';
SELECT tex_id, tex_dat 
FROM tex_text 
ORDER BY tex_id DESC 
LIMIT 1 OFFSET 10
EOSQL
    my $tex_id = $dbh->selectrow_arrayref($sql)->[0] // 0;

    $sql = << 'EOSQL';
SELECT log_timestamp 
FROM log_login 
WHERE lower(ben_fk)=lower(?)
EOSQL
    my $last_login = ( $dbh->selectrow_array($sql, undef, $user) )[0] // $tex_id;

    return $tex_id, $last_login;
}

sub update_usersession {
    my ( $session, $user ) = @_;
    $sql = << 'EOSQL';
UPDATE ben_benutzer 
SET 
    ben_lastdate = ben_dat,
    ben_session  = ?,
    ben_dat      = now(),
    ben_kick     = 0
WHERE lower(ben_user)=lower(?)
EOSQL
    Data::dbh()->do( $sql, undef, $session, $user );
    Data::Msg::insert_msg( $user, "» $user ist jetzt angemeldet", 1, '' );
}

sub logout {
    my $user = shift;
    Data::dbh()->do(
q{UPDATE ben_benutzer SET ben_session='' WHERE lower(ben_user)=lower(? );
        }
        , undef, $user
    );
    Data::Msg::insert_msg( $user, "» $user hat sich abgemeldet", 1, '' );
    #$dbh->do( 'DELETE FROM log_login WHERE lower(ben_fk)=lower(?)',
    #    undef, $user );
}

1;

