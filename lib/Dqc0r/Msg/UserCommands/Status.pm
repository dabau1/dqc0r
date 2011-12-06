package Dqc0r::Msg::UserCommands::Status;

use 5.010;
use warnings;
use utf8;
use Data::Msg::UserCommands::Status;
use Language;

sub set_state {
    my ( $self, $cmd, $msg, $kat ) = @_;
    my $user = $self->session->{user};
    my $txt  = "» $user ist " . $Language::german_status{$cmd};
    $cmd = "\u$cmd";
    $txt .= ": $msg" if $msg;
    Data::Msg::UserCommands::Status::update_state( $user, $cmd );
    return $txt, $kat;
}

sub set_refresh {
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
    Data::Msg::UserCommands::Status::update_refresh( $user, $interval );
    return $txt, 1;
}

sub set_pw {
    my ( $self, $txt ) = @_;
    my $user = $self->session->{user};
    return 'Passwort neu setzen geht so: [code]/set_pw oldpw newpw newpw[/code], wobei "oldpw" das alte Passwort ist, welches zur Bestätigung eingegeben werden muss, "newpw" ist das neue Passwort, welches zweimal nacheinander eingegeben werden muss. Zwischen "oldpw" und den beiden "newpw" darf jeweils nur ein Leerzeichen stehen! Neue Passwörter müssen im Übrigen zwischen 8 und 32 Zeichen lang sein.', 0, $user
        unless  $txt =~ m/\A(\S+)\s(\S{8,32})\s(\2)\z/xms;
    my ( $oldpw, $newpw ) = ( $1, $2 );
    return Data::Msg::UserCommands::Status::set_pw( $user, $oldpw, $newpw ), 3, $user;
}

1;

