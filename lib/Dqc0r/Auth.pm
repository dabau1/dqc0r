package Dqc0r::Auth;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'md5_sum';
use utf8;
use Data::Auth;

sub login {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $self->param('user');
    my $pass    = md5_sum( $self->param('pass') );
    $self->stash( error => '' );
    my @data = Data::Auth::get_userdata( $user, $pass );

    unless (@data) {
        $self->render( 'login_form', error => 'Anmeldung fehlgeschlagen' );
        return;
    }
    %$session = (
        %$session,
        user   => $user,
        pass   => $pass,
        admin  => $data[0],
        status => $data[1],
        news   => $data[2],
        userid => $data[3],
    );

    ( $session->{tex_id}, $session->{last_login} ) = ( Data::Auth::get_lastsessiondata( $user ) );

    Data::Auth::update_usersession("$session", $user);
    Dqc0r::log_timestamp($self);
    $self->render('chat');
}

sub logout {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $session->{user};
    delete $session->{user};
    delete $session->{pass};
    delete $session->{userid};
    Data::Auth::logout($user);
    $self->render( 'login_form',
        error => 'Abmelden bestätigt, bitte melden Sie sich erneut an' );
}

sub login_form {
    my $self = shift;
    $self->render( 'login_form', error => 'Bitte melden Sie sich an' );
}

sub check_login {
    my $self = shift;
    return 1 if $self->session()->{user};
    $self->redirect_to('login_form');
    return;
}

1;

