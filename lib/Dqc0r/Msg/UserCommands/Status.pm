package Dqc0r::Msg::UserCommands::Status;

use 5.010;
use warnings;
use utf8;
use Data::Msg::UserCommands::Status;
use Data::Language;

sub set_state {
    my ( $self, $cmd, $msg, $kat ) = @_;
    my $user = $self->session->{user};
    my $txt  = "» $user ist " . $Data::Language::german_status{$cmd};
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

1;

