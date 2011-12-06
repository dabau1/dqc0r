package Dqc0r::Refresh;
use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Data::Refresh;
use Language;

sub _prepare_msg {
    my ( $m, $s ) = @_;
    my $user = $s->{user};
    $m->[7] = lc( $user ) eq lc( $m->[1] ) ? 1 : 0;
    $m->[3] = $1 if $m->[3] =~ m/\s(\d\d:\d\d)/xms;
    if ( $m->[2] =~ m{\A/(away|busy|online)}xmsi ) {
        $m->[2] = "» $m->[1] ist " . $Language::german_status{$1};
        return $m;
    }
    $m->[2] =~ s{[\n\r]+}{<br />&nbsp;&nbsp;&nbsp;&nbsp;}xmsg;
    chomp( $m->[2] );
    $m->[2] =~
s{\[url\](.+?)\[/url\]}{<a href="$1" title="Externe Webseite" target="_blank">$1</a>}xmsig;
    $m->[2] =~
s{\[img\](.+?)\[/img\]}{<a href="$1" title="Externes Bild" target="_blank"><img src="$1" title="Externes Bild" /></a>}xmsig;
    $m->[8] = $m->[6] == 0 ? ( $m->[2] =~ s{\b($user)\b}{\[b\]$1\[/b\]}xgmsi ? 1 : 0 ) : 0;
    $m->[2] =~ s{\[([bui])\](.+?)\[/[bui]\]}{<$1>$2</$1>}xmsig;
    $m->[2] =~ s{\*(\w+)\*}{<b>$1</b>}xmsig;
    $m->[2] =~
      s{\[code(?: lang="?\w+"?)?\](.+?)\[/code\]}{<code>$1</code>}xmsig;
    return $m;
}

sub _prepare_user {
    my ( $u, $s ) = @_;
    $u->[5] = lc( $s->{user} ) eq lc( $u->[0] ) ? 1 : 0;
    $u->[0] = '@' . $u->[0] if $u->[4];
    $u->[2] = 'Online' unless $u->[2];
    return $u;
}

sub _prepare_note {
    my $n = shift;
    $n->[0] = sprintf '%d.%d.%04d',
      ( split '-', ( split ' ', $n->[0] )[0] )[ 2, 1, 0 ];
    return $n;
}

sub refresh {
    my $self    = shift;
    my $session = $self->session;
    my $user    = $session->{user};

    my $msgs = [
        map { _prepare_msg( $_, $session ) } @{
            Data::Refresh::get_msgs(
                $user,                 $session->{tex_id},
                $self->param('login'), $session->{last_login}
            )
          }
    ];
    $session->{tex_id} = $msgs->[-1][0] if @$msgs;

    # user, refresh, status, timediff
    my $users =
      [ map { _prepare_user( $_, $session ) } @{ Data::Refresh::get_users() } ];

    my $notes = [ map { _prepare_note($_) } @{ Data::Refresh::get_notes() } ];

    Dqc0r::log_timestamp($self);
    $self->render(
        json => { msgs => $msgs, buddies => $users, notes => $notes } );
}

1;

