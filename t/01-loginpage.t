#!/usr/bin/perl
use 5.010;
use warnings;
use utf8;

use Test::More tests => 9;
use Test::Mojo;

my $t = Test::Mojo->new('Dqc0r');

$t->get_ok('/')->status_is(200)
  ->content_like( qr/Bitte melden Sie sich an/, 'welcome message' );

$t->post_form_ok( '/login', { user => 'test', pass => 'test' } )->status_is(200)
  ->content_like(qr{Angemeldet als <b>test</b>}, 'logged in');

$t->get_ok('/logout')->status_is(200)
  ->content_like(qr/Abmelden bestätigt/, 'logged out');

