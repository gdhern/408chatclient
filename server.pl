#!/usr/bin/perl

use IO::Socket::INET;
use threads;

$| = 1;

my ($socket,$client_socket,$data);
my ($peeraddress,$peerport);

$socket = new IO::Socket::INET (
LocalHost => '127.0.0.1',
LocalPort => '22222',
Proto => 'tcp',
Listen => 5,
Reuse => 1
) or die "ERROR in Socket Creation : $!\n";

print "SERVER Waiting for client connection on port 22222\n";

sub recAndSend{
    threads->create(sub{
        while(1){
            $client_socket->recv($data,1024);
            chomp($data);
            $client_socket->send("$data\n");
        }
    });
}

while(1)
{
    $client_socket = $socket->accept();
    $client_socket->recv($data,1024);
    print "New Client, $data, Connected\n";
    recAndSend();
}

$socket->close();
