package Data;

use 5.010;
use warnings;
use utf8;
use DBI;

our $helpmsg = << 'EOHELP';
[b]Nachrichten-Commandos:[/b][code]
    /help           : Dreimal darfst du raten
    /b, /u, /i      : Fette, shiefe oder unterstrichene Zeile
    /set_refresh ## : Refresh-Frequenz auf ## setzen
    /add_news       : Notiz für die rechte Seitenspalte
    /del_news ##    : Notiz ## entfernen
    /online         : Setzt den Status auf online
    /away           : Setzt den Status auf away
    /busy           : Setzt den Status auf busy[/code]

[b]BBCodes:[/b][code]
    url  : Link erzeugen zum wo drauf klicken
    img  : Da wird ein Bild angezeigt
    b    : Fettschreiben
    u    : Unterschreiben
    i    : Schiefschreiben
    code : Breitengleiche vordefinierte Schrift[/code]
EOHELP

our %german_status = (
    away   => 'gerade nicht da',
    busy   => 'tierisch beschäftigt ... oder tut wenigstens so als ob',
    online => 'jetzt verfügbar',
);

{
    my $dbh;
    my $config = {};

    sub set_config {
        my $app = shift;
        $config =
          $app->plugin( JSONConfig => { file => '../../etc/dqc0r.conf' } );
        $app->secret( $config->{cookie_secret} );
    }

    sub dbh {
        return $dbh if $dbh;
        $dbh = DBI->connect(
            $config->{dsn},
            $config->{user},
            $config->{password},
            {
                RaiseError => 1,
                AutoCommit => 1,
            }
        );
        $dbh->{'mysql_enable_utf8'} = 1;
        return $dbh;
    }
}

1;

