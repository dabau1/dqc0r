package Dqc0r::Msg::UserCommands::News;

use 5.010;
use warnings;
use utf8;

sub add_news {
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
}

sub del_news {
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
}

1;

