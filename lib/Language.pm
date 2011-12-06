package Language;

use 5.010;
use warnings;
use utf8;

our $helpmsg = << 'EOHELP';
[u]Nachrichten-Commandos[/u]:
[b]/help[/b]: Dreimal darfst du raten
[b]/b[/b], [b]/u[/b], [b]/i[/b]: Zeilenformatierung mit BBCodes
[b]/code[/b]: Breitengleiche Nachricht
[b]/set_refresh ##[/b]: Refresh-Frequenz auf ## setzen
[b]/add_news[/b]: Notiz für die rechte Seitenspalte
[b]/del_news ##[/b]: Notiz ## entfernen
[b]/online[/b]: Setzt den Status auf online
[b]/away[/b]: Setzt den Status auf away
[b]/busy[/b]: Setzt den Status auf busy
[b]/msg to text[/b]: Sendet eine private Nachricht
[b]/set_pw oldpw newpw newpw[/b]: Neues Passwort setzen.
[u]BBCodes[/u]:
[b]url[/b]: Link erzeugen zum wo drauf klicken
[b]img[/b]: Da wird ein Bild angezeigt
[b]b[/b]: Fettschreiben
[b]u[/b]: Unterschreiben
[b]i[/b]: Schiefschreiben
[b]code[/b]: Breitengleiche vordefinierte Schrift
EOHELP

our %german_status = (
    away   => 'gerade nicht da',
    busy   => 'tierisch beschäftigt ... oder tut wenigstens so als ob',
    online => 'jetzt verfügbar',
);


1;

