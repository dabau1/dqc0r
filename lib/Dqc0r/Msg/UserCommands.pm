package Dqc0r::Msg::UserCommands;
use Dqc0r::Msg::UserCommands::Chat;
use Dqc0r::Msg::UserCommands::Status;
use Dqc0r::Msg::UserCommands::News;
use Language;
use 5.010;
use warnings;
use utf8;

our %Commands = (
    me          => sub { '» ' . $_[0]->session->{user} . " $_[1]", 1 },
    set_refresh => \&Dqc0r::Msg::UserCommands::Status::set_refresh,
    add_news    => \&Dqc0r::Msg::UserCommands::News::add_news,
    del_news    => \&Dqc0r::Msg::UserCommands::News::del_news,
    msg         => \&Dqc0r::Msg::UserCommands::Chat::msg,
    help => sub { $Language::helpmsg, 2, $_[0]->session->{user} },
    (    # Online, Busy, Away
        map {
            my ( $st, $k ) = ( $_->[0], $_->[1] );
            $st => sub { Dqc0r::Msg::UserCommands::Status::set_state( $_[0], $st, $_[1], $k ) }
          } ( [ online => 10 ], [ busy => 11 ], [ away => 12 ], )
    ),
    (    # format the line - shortcut
        map {
            my $c = $_;
            $c => sub { "\[$c\]$_[1]\[/$c\]", 0 }
          } qw(b i u code)
    ),
);
1;

