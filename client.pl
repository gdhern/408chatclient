#!/usr/bin/perl

use IO::Socket::INET;
use threads;

$| = 1;

my ($socket,$client_socket,$data,$userName);

print "LOGIN\nUsername: ";
chomp($userName = <STDIN>);

$socket = new IO::Socket::INET (
PeerHost => '127.0.0.1',
PeerPort => '22222',
Proto => 'tcp',
) or die "ERROR in Socket Creation : $!\n";

print "Connected to Chat Server\n";
$socket->send($userName);

sub recvAndPrint{
    threads->create(sub{
        $socket->recv($data,1024);
        chomp($data);
        print "$data\n";
    });
}

sub userInput{
    if ($message eq "e"){$socket->send("e");exit();}
    else{$socket->send("$userName> $message");}
}

while(1)
{
    recvAndPrint();
    chomp($message = <STDIN>);
    userInput();
}
$socket->close();
