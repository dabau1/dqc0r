package Dqc0r::Msg::UserCommands;
use 5.010; 
use warnings;
use utf8;

sub _set_state {
    my ( $self, $cmd, $msg, $kat ) = @_;
    my $user = $self->session->{user};
    my $txt  = "» $user ist " . $Data::german_status{$cmd};
    $cmd = "\u$cmd";
    $txt .= ": $msg" if $msg;
    my $sql = << 'EOSQL';
UPDATE ben_benutzer
SET ben_status = ?
WHERE lower(ben_user)=lower(?)
EOSQL
    Data::dbh()->do( $sql, undef, $cmd, $user );
    return $txt, $kat;
}

our %Commands = (
    me => sub {    # Its me who's talking
        my $user = $_[0]->session->{user};
        "» $user $_[1]", 1;
    },
    set_refresh => sub {
        my ( $self, $txt ) = @_;
        my $user = $self->session->{user};
        return 'Refreshinterval setzen geht so: [code]/set_refresh ##[/code]',
          0, $user
          unless $txt =~ m/(\d+)/xms;
        my $interval = $1;
        if ( $interval >= 16 ) {
            $txt =
"» $user schaut nur noch nach neuen Nachrichten, wenn es ihm grad mal danach ist";
        }
        elsif ( $interval == 0 ) {
            $txt =
"» $user ist aufmerksam wie ein Wachhund und schaut ständig nach neuen Nachrichten";
        }
        else {
            $txt =
"» $user schaut erst in $interval Minuten wieder nach neuen Nachrichten";
        }
        my $sql = << 'EOSQL';
UPDATE log_login SET refresh=?
WHERE lower(ben_fk)=lower(?)
EOSQL
        Data::dbh()->do( $sql, undef, $interval, $user );
        return $txt, 1;
    },
    add_news => sub {
        my ( $self, $txt ) = @_;
        my $session = $self->session;
        return
'Nachrichten müssen folgende Form haben: [code]/add_news Newstext[/code]',
          2, $session->{user}
          unless $txt;
        return $txt, 0 unless $txt;
        my $sql = << 'EOSQL';
INSERT INTO not_notiz
(ben_fk, not_notiz, not_date)
VALUES (?, ?, ?)
EOSQL
        Data::dbh()
          ->do( $sql, undef, $session->{userid}, $txt,
            Dqc0r::get_timestamp_for_db() );
        $txt = "» $session->{user} hat eine Notiz hinterlassen";
        return $txt, 1;
    },
    del_news => sub {
        my ( $self, $txt ) = @_;
        my $user = $self->session->{user};
        return
          'Nachrichten werden wie folgt gelöscht: [code]/del_news ##[/code]',
          2, $user
          unless $txt =~ m/\A\s*(\d+)/xms;
        my $id  = $1;
        my $sql = << 'EOSQL';
DELETE FROM not_notiz
WHERE not_id=?
EOSQL
        Data::dbh()->do( $sql, undef, $id );
        return "» $user hat eine Notiz entfernt", 1;
    },
    help => sub {
        my ( $self, $txt ) = @_;
        return $Data::helpmsg, 2, $self->session->{user};
    },
    (    # Online, Busy, Away
        map {
            my ( $st, $k ) = ( $_->[0], $_->[1] );
            $st => sub { _set_state( $_[0], $st, $_[1], $k ) }
          } ( [ online => 10 ], [ busy => 11 ], [ away => 12 ], )
    ),
    (    # format the line - shortcut
        map {
            my $c = $_;
            $c => sub { "\[$c\]$_[1]\[/$c\]", 0 }
          } qw(b i u)
    ),
);
1;

