package Data::Refresh;

use 5.010;
use warnings;
use utf8;
use Data;

sub get_msgs {
    my  ( $user, $tex_id, $login, $last_login ) = @_;
    my @params  = ( $tex_id, $user, $user );

    my $sql = << 'EOSQL';
SELECT tex_id, ben_fk, tex_text, tex_dat, tex_von, tex_an, tex_kat
FROM tex_text
WHERE tex_id > ? AND 
    (lower(tex_an) = lower(?) 
        OR lower(tex_von) = lower(?) 
        OR tex_an = '' OR tex_an IS NULL)
EOSQL
    if ( $login ) {
        $sql = "($sql)";
        $sql .= << 'EOSQL';
UNION
(SELECT tex_id, ben_fk, tex_text, tex_dat, tex_von, tex_an, tex_kat
FROM tex_text
WHERE lower(tex_an)=lower(?) AND tex_dat > ?)
EOSQL
        push @params, ( $user, $last_login );
    }
    $sql .= "\nORDER BY tex_dat ASC";
    return Data::dbh()->selectall_arrayref( $sql, undef, @params );
}

sub get_users {
    my $sql = << 'EOSQL';
SELECT 
    b.ben_user, l.refresh, b.ben_status,
    case when l.refresh > 0 then round((unix_timestamp(now()) - unix_timestamp(l.log_timestamp))/60) else 0 end as ltime,
    b.ben_admin
FROM log_login l
INNER JOIN ben_benutzer b ON l.ben_fk=b.ben_user
WHERE 
    ( l.refresh = 0 AND ((unix_timestamp(now()) - unix_timestamp(l.log_timestamp)) < ( 10 * 60 )) ) 
    OR 
    ( l.refresh > 0 AND ((unix_timestamp(now()) - unix_timestamp(l.log_timestamp)) < (l.refresh*60+30)) )
ORDER BY b.ben_dat
EOSQL
    return Data::dbh()->selectall_arrayref($sql);
}

sub get_notes {
    my $sql = << 'EOSQL';
SELECT n.not_date, b.ben_user, n.not_notiz, n.not_id
FROM not_notiz n
INNER JOIN ben_benutzer b ON b.ben_id = n.ben_fk
ORDER BY n.not_date DESC;
EOSQL
    return Data::dbh()->selectall_arrayref($sql);
}

1;

