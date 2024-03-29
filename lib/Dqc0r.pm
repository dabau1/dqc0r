package Dqc0r;
use Mojo::Base 'Mojolicious';
use warnings;
use utf8;
use Data;

sub get_timestamp_for_db {
    my @lt = localtime;
    $lt[5] += 1900;
    $lt[4]++;
    sprintf '%04d-%02d-%02d-%02d:%02d:%02d', @lt[ reverse 0 .. 5 ];
}

sub log_timestamp {
    my $self      = shift;
    my $timestamp = shift // get_timestamp_for_db();
    Data::log_timestamp( $timestamp, $self->session->{user} );
}

sub startup {
    my $self = shift;
    my $app  = $self->app;
    Data::set_config($app);

    # Routes
    my $r = $self->routes;

    $r->route('/')->to('auth#login_form');
    $r->route('/logout')->to('auth#logout');
    $r->route('/login')->to('auth#login');
    my $b = $r->bridge()->to('auth#check_login');
    $b->route('/refresh')->to('refresh#refresh');
    $b->route('/msg')->to('msg#msg');

}

1;
