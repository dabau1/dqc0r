package Dqc0r::Msg;
use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Data::Msg;
use Dqc0r::Msg::UserCommands;
use Dqc0r::Msg::AdminCommands;

sub _command_parsing {
    my ( $self, $commands, $msg ) = @_;
    return $msg, 0, '' unless $msg =~ m~\A/(\w+)(?:\s+(.*))?\z~xms;
    my ( $cmd, $txt ) = ( $1, $2 // '' );
    return $msg, 0, '' unless exists $$commands{$cmd};
    my ( $nmsg, $kat, $an ) = $$commands{$cmd}( $self, $txt );
    $msg = $nmsg // $msg;
    $kat //= 0;
    $an  //= '';
    return $msg, $kat, $an;
}

sub msg {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $session->{user};
    my $msg     = $self->param('msg');
    chomp($msg);
    my $laenge = length $msg;
    if ( 2 > $laenge ) {
        $self->redirect_to('/refresh');
        return;
    }
    my $kat      = 0;
    my $an       = '';
    my %commands = (%Dqc0r::Msg::UserCommands::Commands);
    %commands = ( %commands, %Dqc0r::Msg::AdminCommands::Commands ) if $session->{admin};
    ( $msg, $kat, $an ) = $self->_command_parsing( \%commands, $msg );

    Data::Msg::insert_msg( $user, $msg, $kat, $an );
    Dqc0r::log_timestamp($self);
    $self->redirect_to('/refresh');
}

1;

