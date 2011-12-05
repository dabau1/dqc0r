package Dqc0r::Msg;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'html_escape';
use utf8;
use Data;
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
    my $dbh = Data::dbh();
    $laenge = length $msg;
    $dbh->do( 'UPDATE anz_zeichen SET anz=anz+?', undef, $laenge );
    my $sql = << 'EOSQL';
INSERT INTO tex_text ( ben_fk, tex_text, tex_dat, tex_kat, tex_von, tex_an) 
VALUES ( ?, ?, now(), ?, ?, ? )
EOSQL
    $dbh->do( $sql, undef, $user, html_escape($msg), $kat, $an ? $user : '',
        $an );
    Dqc0r::log_timestamp($self);
    $self->redirect_to('/refresh');
}

1;

