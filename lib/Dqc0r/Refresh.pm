package Dqc0r::Refresh;
use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Data;

sub _prepare_msg {
    my ( $m, $s ) = @_;
    $m->[7] = lc( $s->{user} ) eq lc( $m->[1] ) ? 1 : 0;
    $m->[3] = $1 if $m->[3] =~ m/\s(\d\d:\d\d)/xms;
    if ( $m->[2] =~ m{\A/(away|busy|online)}xmsi ) {
        $m->[2] = "» $m->[1] ist " . $Data::german_status{$1};
        return $m;
    }
    $m->[2] =~ s{[\n\r]+}{<br />&nbsp;&nbsp;&nbsp;&nbsp;}xmsg;
    chomp( $m->[2] );
    $m->[2] =~
s{\[url\](.+?)\[/url\]}{<a href="$1" title="Externe Webseite" target="_blank">$1</a>}xmsig;
    $m->[2] =~
s{\[img\](.+?)\[/img\]}{<a href="$1" title="Externes Bild" target="_blank"><img src="$1" title="Externes Bild" /></a>}xmsig;
    $m->[2] =~ s{\[([bui])\](.+?)\[/[bui]\]}{<$1>$2</$1>}xmsig;
    $m->[2] =~
      s{\[code(?: lang="?\w+"?)?\](.+?)\[/code\]}{<code>$1</code>}xmsig;
    return $m;
}

sub _prepare_user {
    my ( $u, $s ) = @_;
    $u->[0] = '@' . $u->[0] if $u->[4];
    $u->[2] = 'Online' unless $u->[2];
    $u->[5] = lc( $s->{user} ) eq lc( $u->[0] ) ? 1 : 0;
    return $u;
}

sub _prepare_note {
    my $n = shift;
    $n->[0] = sprintf '%d.%d.%04d',
      ( split '-', ( split ' ', $n->[0] )[0] )[ 2, 1, 0 ];
    return $n;
}

sub refresh {
    my $self    = shift;
    my $session = $self->session;
    my $dbh     = Data::dbh();
    my $sql     = << 'EOSQL';
SELECT tex_id, ben_fk, tex_text, tex_dat, tex_von, tex_an, tex_kat
FROM tex_text
WHERE tex_id > ? AND (lower(tex_an) = lower(?) OR tex_an = '' OR tex_an IS NULL)
ORDER BY tex_dat ASC;
EOSQL
    my $msgs = [
        map { _prepare_msg( $_, $session ) } @{
            $dbh->selectall_arrayref( $sql, undef, $session->{tex_id},
                $session->{user} )
          }
    ];
    $session->{tex_id} = $msgs->[-1][0] if @$msgs;

    # user, refresh, status, timediff
    $sql = << 'EOSQL';
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
    my $users =
      [ map { _prepare_user( $_, $session ) }
          @{ $dbh->selectall_arrayref($sql) } ];
    $sql = << 'EOSQL';
SELECT n.not_date, b.ben_user, n.not_notiz, n.not_id
FROM not_notiz n
INNER JOIN ben_benutzer b ON b.ben_id = n.ben_fk
ORDER BY n.not_date DESC;
EOSQL
    my $notes =
      [ map { _prepare_note($_) } @{ $dbh->selectall_arrayref($sql) } ];
    Dqc0r::log_timestamp($self);
    $self->render(
        json => { msgs => $msgs, buddies => $users, notes => $notes } );
}

1;

