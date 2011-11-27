package Dqc0r::Auth;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'md5_sum';
use utf8;
use Data;

sub login {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $self->param('user');
    my $pass    = md5_sum( $self->param('pass') );
    my $dbh     = Data::dbh();
    $self->stash( error => '' );
    my $sql = << 'EOSQL';
SELECT ben_admin, ben_status, ben_news, ben_id i
FROM ben_benutzer 
WHERE lower(ben_user)=lower(?) AND ben_pw=?
EOSQL
    my @admindata = $dbh->selectrow_array( $sql, undef, $user, $pass );
    unless (@admindata) {
        $self->render( 'login_form', error => 'Anmeldung fehlgeschlagen' );
        return;
    }
    %$session = (
        %$session,
        user     => $user,
        pass     => $pass,
        admin    => $admindata[0],
        status   => $admindata[1],
        news     => $admindata[2],
        userid   => $admindata[3],
    );
    $sql = << 'EOSQL';
SELECT tex_id 
FROM tex_text 
ORDER BY tex_id DESC 
LIMIT 1 OFFSET 10
EOSQL
    $session->{tex_id} = $dbh->selectrow_arrayref($sql)->[0] // 0;
    $sql = << 'EOSQL';
UPDATE ben_benutzer 
SET 
    ben_lastdate = ben_dat,
    ben_session  = ?,
    ben_dat      = now(),
    ben_kick     = 0
WHERE lower(ben_user)=lower(?)
EOSQL
    $dbh->do( $sql, undef, "$session", $user );
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
    my $dbh = Data::dbh();
    $dbh->do(
q{UPDATE ben_benutzer SET ben_session='' WHERE lower(ben_user)=lower(? );
        }
        , undef, $user
    );
    $dbh->do( 'DELETE FROM log_login WHERE lower(ben_fk)=lower(?)',
        undef, $user );
    $self->render( 'login_form',
        error => 'Abmelden bestätigt, bitte melden Sie sich erneut an' );
}

sub login_form {
    my $self = shift;
    $self->render('login_form', error => 'Bitte melden Sie sich an');
}

sub check_login {
    my $self = shift;
    return 1 if $self->session()->{user};
    $self->redirect_to( 'login_form' );
    return;
}

1;

