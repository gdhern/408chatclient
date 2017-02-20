#!/usr/bin/perl

use strict;
use IO::Socket::INET;
use threads;
use threads::shared;

$| = 1;

my ($name,$tName,$message,$iter);

our @clients : shared;
@clients = ();

my $socket = new IO::Socket::INET (
LocalHost => '127.0.0.1',
LocalPort => '22222',
Proto => 'tcp',
Listen => 5,
Reuse => 1
) or die "ERROR in Socket Creation : $!\n";

print "SERVER Waiting for client connection on port 22222\n";


sub process {
  my $data;
  my ($lclient) = @_;
  print $lclient "Welcome to server\n";
  while(1){
    $lclient->recv($tName, 1024);
    $lclient->recv($message, 1024);
      if($message eq "e"){
          $iter=0;
          $iter++ until $lclient == @clients[$iter];
          print "$tName disconnected.\n";
          splice(@clients,$iter,1);
          threads->exit();
      }
    else{
        foreach my $fn (@clients){
            open my $fh, ">&=$fn" or warn $! and die;
            print $fh "$tName> $message \n";
        }
    }
    #$lclient->send($data);
    #print "$data\n";
  }
  close($lclient);
  #@clients = grep {$_ !~ $lfileno} @clients;
}

while(1)
{
    my $client_socket = $socket->accept();
    $client_socket->recv($name, 1024);
    print "Client, $name, connected.\n";
    my $fileno = fileno $client_socket;
    push (@clients, $fileno);
    my $thr = threads->create(\&process, $client_socket)->detach();
}
$socket->close();
#$socket->close();
