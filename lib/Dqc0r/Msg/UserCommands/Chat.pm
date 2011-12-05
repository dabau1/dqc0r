package Dqc0r::Msg::UserCommands::Chat;

use 5.010;
use warnings;
use utf8;

sub msg {
    my ( $self, $txt ) = @_;
    return $txt, 0 unless $txt =~ m/\A(\w+)\s*(.+)\z/xmsi;
    my $to = $1;
    $txt = $2;
    return $txt, 3, $to;
}

1;

