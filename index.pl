#!/usr/bin/env perl
use Mojolicious::Lite;
use DBI;
use Mojo::Util qw(md5_sum html_escape);
use utf8;

my $helpmsg = << 'EOHELP';
[code]Nachrichten-Commandos:
    /help           : Dreimal darfst du raten
    /b, /u, /i      : Fette, shiefe oder unterstrichene Zeile
    /set_refresh ## : Refresh-Frequenz auf ## setzen
    /news           : Notiz für die rechte Seitenspalte
    /online         : Setzt den Status auf online
    /away           : Setzt den Status auf away
    /busy           : Setzt den Status auf busy

BBCodes:
    url  : Link erzeugen zum wo drauf klicken
    img  : Da wird ein Bild angezeigt
    b    : Fettschreiben
    u    : Unterschreiben
    i    : Schiefschreiben
    code : Breitengleiche vordefinierte Schrift[/code]
EOHELP

app->secret('asjdfhoae jb<F3>.o84u9iqw');
my $config = plugin JSONConfig => { file => '../../etc/dqc0r.conf' };

my %german_status = (
    away => 'gerade nicht da',
    busy => 'tierisch beschäftigt ... oder tut wenigstens so als ob',
    online => 'jetzt verfügbar',
);

{
    my $dbh;

    sub Mojolicious::Controller::dbh {
        my $self = shift;
        return $dbh if $dbh;
        my $session = $self->session;
        $dbh = DBI->connect(
            $config->{dsn}, $config->{user}, $config->{password},
            {
                RaiseError => 1,
                AutoCommit => 1,
            }
        );
        $dbh->{'mysql_enable_utf8'} = 1;
        return $dbh;
    }
}

any '/logout' => sub {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $session->{user};
    delete $session->{user};
    delete $session->{pass};
    delete $session->{userid};
    my $dbh = $self->dbh;
    $dbh->do(
q{UPDATE ben_benutzer SET ben_session='' WHERE lower(ben_user)=lower(? );
        }
        , undef, $user
    );
    $dbh->do( 'DELETE FROM log_login WHERE lower(ben_fk)=lower(?)',
        undef, $user );
    $self->render( 'login_form',
        error => 'Abmelden bestätigt, bitte melden Sie sich erneut an' );
};

post '/login' => sub {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $self->param('user');
    my $pass    = md5_sum( $self->param('pass') );
    my $dbh     = $self->dbh;
    $self->stash( error => '' );
    my @admindata = $dbh->selectrow_array(
'SELECT ben_admin, ben_status, ben_news, ben_id FROM ben_benutzer WHERE lower(ben_user)=lower(?) AND ben_pw=?',
        undef, $user, $pass
    );
    unless (@admindata) {
        $self->render( 'login_form', error => 'Anmeldung fehlgeschlagen' );
        return;
    }
    %$session = (
        %$session,
        user     => $user,
        pass     => $pass,
        admin    => $admindata[0],
        status   => $admindata[1],
        news     => $admindata[2],
        userid   => $admindata[3],
    );
    $session->{tex_id} = $dbh->selectrow_arrayref('SELECT max(tex_id) FROM tex_text')->[0] // 0;
    my $sql = << 'EOSQL';
UPDATE ben_benutzer 
SET 
    ben_lastdate = ben_dat,
    ben_session  = ?,
    ben_dat      = now(),
    ben_kick     = 0
WHERE lower(ben_user)=lower(?)
EOSQL
    $dbh->do( $sql, undef, "$session", $user );
    $self->log_timestamp;
    $self->render('chat');
};

any '/login_form' => sub {
    my $self = shift;
    $self->render('login_form', error => 'Bitte melden Sie sich an');
};

#############################################################################
# NONE SHALL PASS!!!!
#############################################################################
under sub {
    my $self = shift;
    return 1 if $self->session()->{user};
    $self->redirect_to( 'login_form' );
    return;
};

sub set_state {
    my ( $self, $cmd, $msg, $kat ) = @_;
    my $user = $self->session->{user};
    my $txt = "» $user ist ". $german_status{$cmd};
    $cmd = "\u$cmd";
    $txt .= ": $msg" if $msg;
    my $sql = << 'EOSQL';
UPDATE ben_benutzer
SET ben_status = ?
WHERE lower(ben_user)=lower(?)
EOSQL
    $self->dbh->do($sql, undef, $cmd, $user);
    return $txt, $kat;
}

our %commands = (
    me => sub { # Its me who's talking
        my $user = $_[0]->session->{user};
        "» $user $_[1]", 1;
    },
    set_refresh => sub {
        my ( $self, $txt ) = @_;
        return ( $txt, 0 ) unless $txt =~ m/(\d+)/xms;
        my $user = $self->session->{user};
        my $interval = $1;
        if ( $interval >= 16 ) {
            $txt ="» $user schaut nur noch nach neuen Nachrichten, wenn es ihm grad mal danach ist";
        }
        elsif ( $interval == 0 ) {
            $txt ="» $user ist aufmerksam wie ein Wachhund und schaut ständig nach neuen Nachrichten";
        }
        else {
            $txt ="» $user schaut erst in $interval Minuten wieder nach neuen Nachrichten";
        }
        my $sql = << 'EOSQL';
UPDATE log_login SET refresh=?
WHERE lower(ben_fk)=lower(?)
EOSQL
        $self->dbh()->do($sql, undef, $interval, $user);
        return $txt, 1;
    },
    news => sub {
        my ( $self, $txt ) = @_;
        my $session = $self->session;
        return $txt, 0 unless $txt;
        my $sql = << 'EOSQL';
INSERT INTO not_notiz
(ben_fk, not_notiz, not_date)
VALUES (?, ?, ?)
EOSQL
        $self->dbh->do($sql, undef, $session->{userid}, $txt, get_timestamp_for_db());
        $txt = "» $session->{user} hat eine Notiz hinterlassen";
        return $txt, 1;
    },
    help => sub {
        my ( $self, $txt ) = @_;
        return $helpmsg, 2, $self->session->{user};
    },
    (   # Online, Busy, Away
        map { 
            my ($st, $k) = ( $_->[0], $_->[1] ); 
            $st => sub { set_state( $_[0], $st, $_[1], $k ) } 
        } (
            [online => 10], [busy => 11], [away => 12],
        )
    ),
    (   # format the line - shortcut
        map { my $c = $_; $c => sub { "\[$c\]$_[1]\[/$c\]", 0 } } qw(b i u)
    ),
);
our %admincommands = (
    kick => sub {

    },
);

sub command_parsing {
    my ( $self, $msg ) = @_;
    return $msg, 0, '' unless $msg =~ m~\A/(\w+)(?:\s+(.*))?\z~xms;
    my ( $cmd, $txt ) = ( $1, $2 // '' );
    return $msg, 0, '' unless exists $commands{$cmd};
    my ( $nmsg, $kat, $an ) = $commands{$cmd}( $self, $txt );
    $msg = $nmsg // $msg;
    $kat //= 0;
    $an  //= '';
    return $msg, $kat, $an;
}

sub get_timestamp_for_db {
    my @lt = localtime;
    $lt[5] += 1900;
    $lt[4]++;
    sprintf '%04d-%02d-%02d-%02d:%02d:%02d', @lt[ reverse 0..5 ];
}

sub Mojolicious::Controller::log_timestamp {
    my $self      = shift;
    my $timestamp = shift // get_timestamp_for_db();
    my $session   = $self->session;
    my $dbh       = $self->dbh;
    my $sql       = 'INSERT INTO log_login SET log_timestamp = ?, ben_fk = ?';
    if (
        $dbh->selectrow_array(
            'SELECT log_id FROM log_login WHERE lower(ben_fk)=lower(?)',
            undef, $session->{user}
        )
      )
    {
        $sql =
          'UPDATE log_login SET log_timestamp=? WHERE lower(ben_fk)=lower(?)';
    }
    $dbh->do( $sql, undef, get_timestamp_for_db(), $session->{user} );
}

post '/msg' => sub {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $session->{user};
    my $msg     = $self->param('msg');
    chomp($msg);
    my $laenge = length $msg;
    if ( 2 > $laenge ) {
        refresh($self);
        return;
    }
    my $kat    = 0;
    my $an     = '';
    local %commands = ( %commands, %admincommands ) if $session->{admin};
    ( $msg, $kat, $an ) = command_parsing( $self, $msg );
    $msg =~ s{(https?://\S+)}{\[url\]$1\[/url\]}xmsig;
    my $dbh = $self->dbh;
    $dbh->do( 'UPDATE anz_zeichen SET anz=anz+?', undef, $laenge );
    my $sql = << 'EOSQL';
INSERT INTO tex_text ( ben_fk, tex_text, tex_dat, tex_kat, tex_von, tex_an) 
VALUES ( ?, ?, now(), ?, ?, ? )
EOSQL
    $dbh->do( $sql, undef, $user, html_escape($msg), $kat, $an ? $user : '', $an );
    $self->log_timestamp;
    refresh($self)
};

sub prepare_msg {
    my ( $m, $s ) = @_;
    $m->[7] = lc($s->{user}) eq lc($m->[1]) ? 1 : 0;
    $m->[3] = $1 if $m->[3] =~ m/\s(\d\d:\d\d)/xms;
    if ( $m->[2] =~ m{\A/(away|busy|online)}xmsi ) {
        $m->[2] = "» $m->[1] ist " . $german_status{$1};
        return $m;
    }
    $m->[2] =~ s{[\n\r]+}{<br />&nbsp;&nbsp;&nbsp;&nbsp;}xmsg;
    chomp($m->[2]);
    $m->[2] =~ s{\[url\](.+?)\[/url\]}{<a href="$1" title="Externe Webseite" target="_blank">$1</a>}xmsig;
    $m->[2] =~ s{\[img\](.+?)\[/img\]}{<a href="$1" title="Externes Bild" target="_blank"><img src="$1" title="Externes Bild" /></a>}xmsig;
    $m->[2] =~ s{\[([bui])\](.+?)\[/[bui]\]}{<$1>$2</$1>}xmsig;
    $m->[2] =~ s{\[code(?: lang="?\w+"?)?\](.+?)\[/code\]}{<code>$1</code>}xmsig;
    return $m;
}
sub prepare_user {
    my ( $u, $s ) = @_;
    $u->[0] = '@'.$u->[0] if $u->[4];
    $u->[2] = 'Online' unless $u->[2];
    $u->[5] = lc($s->{user}) eq lc($u->[0]) ? 1 : 0;
    return $u;
}

sub prepare_note {
    my $n = shift;
    $n->[0] = sprintf '%d.%d.%04d', ( split '-', ( split ' ', $n->[0] )[0] )[2,1,0];
    return $n;
}

sub refresh {
    my $self     = shift;
    my $session  = $self->session;
    my $dbh      = $self->dbh;
    my $sql = << 'EOSQL';
SELECT tex_id, ben_fk, tex_text, tex_dat, tex_von, tex_an, tex_kat
FROM tex_text
WHERE tex_id > ? AND (lower(tex_an) = lower(?) OR tex_an = '' OR tex_an IS NULL)
ORDER BY tex_dat ASC;
EOSQL
    my $msgs = [ map { prepare_msg($_, $session) } @{ $dbh->selectall_arrayref( $sql, undef, $session->{tex_id}, $session->{user} ) } ];
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
    my $users = [ map { prepare_user($_, $session) } @ { $dbh->selectall_arrayref( $sql ) } ];
    $sql = << 'EOSQL';
SELECT n.not_date, b.ben_user, n.not_notiz
FROM not_notiz n
INNER JOIN ben_benutzer b ON b.ben_id = n.ben_fk
ORDER BY n.not_date DESC;
EOSQL
    my $notes = [ map { prepare_note($_) } @{ $dbh->selectall_arrayref( $sql ) } ];
    $self->log_timestamp;
    $self->render( json => { msgs => $msgs, buddies => $users, notes => $notes } );
}
get '/refresh' => sub {refresh(@_)};

get '/' => sub { $_[0]->render('chat') };

app->start;

