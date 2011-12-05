package Data::Msg;

use 5.010;
use warnings;
use utf8;
use Mojo::Util 'html_escape';
use Data;

sub insert_msg {
    my  ( $user, $msg, $kat, $an ) = @_;
    my $dbh = Data::dbh();
    $dbh->do( 'UPDATE anz_zeichen SET anz=anz+?', undef, length( $msg) );
    my $sql = << 'EOSQL';
INSERT INTO tex_text ( ben_fk, tex_text, tex_dat, tex_kat, tex_von, tex_an) 
VALUES ( ?, ?, now(), ?, ?, ? )
EOSQL
    $dbh->do( $sql, undef, $user, html_escape($msg), $kat, $an ? $user : '',
        $an );
}

1;

