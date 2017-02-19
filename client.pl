#!/usr/bin/perl

use IO::Socket::INET;
use threads;

$| = 1;

print "LOGIN\nUsername: ";
chomp($username = <STDIN>);

my ($socket,$client_socket,$data);

$socket = new IO::Socket::INET (
PeerHost => '127.0.0.1',
PeerPort => '22222',
Proto => 'tcp',
) or die "ERROR in Socket Creation : $!\n";

print "Connected to Chat Server\n";
$socket->send($username);

sub recvAndPrint{
    threads->create(sub{
        $socket->recv($data,1024);
        chomp($data);
        print "$data\n";
    });
}

sub end(){
    print "exiting";
    exit();
}

while(1)
{
    recvAndPrint();
    print "(e to exit)> ";
    $message = <STDIN>;
    exit 0 if $message eq 'e';
    $socket->send("$username> $message");
}
$socket->close();
