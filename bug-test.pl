
use strict;
use warnings;

use LWP::UserAgent;
use Net::SSLeay;
use HTTP::Request;
use Data::Dumper;
use DBI;

$Net::SSLeay::trace = 2;

my $dsn = sprintf 'dbi:mysql:%s:%s', $ENV{DBI_DBNAME}, $ENV{DBI_HOST};

my $dbi = DBI->connect( $dsn, $ENV{DBI_USER}, $ENV{DBI_PASS} );

my $req = HTTP::Request->new( GET => 'https://google.com' );

my $ua = LWP::UserAgent->new;

my $rsp = $ua->request($req);

print {*STDERR} Dumper( [ status => $rsp->status_line ] );

connect_and_do_something($dsn);

$rsp = $ua->request($req);

print {*STDERR} Dumper( [ status => $rsp->status_line ] );

########################################################################
sub connect_and_do_something {
########################################################################
    my ($dsn) = shift;

    my $dbi = DBI->connect( $dsn, $ENV{DBI_USER}, $ENV{DBI_PASS} );
    $dbi->disconnect;
}

1;
