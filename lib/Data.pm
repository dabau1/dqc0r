package Data;

use 5.010;
use warnings;
use utf8;
use DBI;

sub log_timestamp {
    my ( $timestamp, $user ) = @_;
    my $dbh = dbh();
    my $sql = 'INSERT INTO log_login SET log_timestamp = ?, ben_fk = ?';
    if (
        $dbh->selectrow_array(
            'SELECT log_id FROM log_login WHERE lower(ben_fk)=lower(?)',
            undef, $user
        )
      )
    {
        $sql =
          'UPDATE log_login SET log_timestamp=? WHERE lower(ben_fk)=lower(?)';
    }
    $dbh->do( $sql, undef, $timestamp, $user );

}

{
    my $dbh;
    my $config = {};

    sub set_config {
        my $app = shift;
        $config =
          $app->plugin( JSONConfig => { file => $ENV{DQC0R_CONFIG} // '../../etc/dqc0r.conf' } );
        $app->secret( $config->{cookie_secret} );
    }

    sub dbh {
        return $dbh if $dbh;
        $dbh = DBI->connect(
            $config->{dsn},
            $config->{user},
            $config->{password},
            {
                RaiseError => 1,
                AutoCommit => 1,
            }
        );
        $dbh->{'mysql_enable_utf8'} = 1;
        return $dbh;
    }
}

1;

