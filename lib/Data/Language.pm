package Data::Language;

use 5.010;
use warnings;
use utf8;

our $helpmsg = << 'EOHELP';
[b]Nachrichten-Commandos:[/b][code]
    /help           : Dreimal darfst du raten
    /b, /u, /i      : Fette, shiefe oder unterstrichene Zeile
    /code           : Breitengleiche Nachricht
    /set_refresh ## : Refresh-Frequenz auf ## setzen
    /add_news       : Notiz für die rechte Seitenspalte
    /del_news ##    : Notiz ## entfernen
    /online         : Setzt den Status auf online
    /away           : Setzt den Status auf away
    /busy           : Setzt den Status auf busy[/code]
    /msg to text    : Sendet eine private Nachricht an "to"

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


1;

