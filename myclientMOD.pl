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

sub reader {
  while(1){
    my $data = <$socket>;
    chomp($data);
    print "$data\n";
  }
}

my $thr = threads->create(\&reader)->detach();

sub userInput{
    if ($message eq "e"){$socket->send($userName);$socket->send("e");exit();}
    else{$socket->send($userName);$socket->send($message);}
}

while(1)
{
    chomp($message = <STDIN>);
    userInput();
}
$socket->close();
