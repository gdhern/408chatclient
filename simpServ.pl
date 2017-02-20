#!/usr/bin/perl

use strict;
use IO::Socket::INET;
use threads;

$| = 1;

my ($socket,$client_socket,$data,$name,$message,@users,@userNames,$var,$iter);

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
            $client_socket->recv($name,1024);
            $client_socket->recv($message,1024);
            if($message eq "e"){print "$name disconnected.\n"; threads->exit();}
            else{print "$name> $message\n";}
            #if ($data eq "e") {
            #    $iter=0;
            #    $iter++ until $client_socket == @users[$iter];
            #    print "@userNames[$iter] disconnected.\n";
            #    splice(@users,$iter,1);
            #    splice(@userNames,$iter,1);
            #    threads-> exit();
            #}
            #else{
                #print "$name> $message\n";
                #foreach $var (@users) {$var->send("$data\n");}
            #}
        }
    });
}

while(1)
{
    $client_socket = $socket->accept();
    $client_socket->recv($data,1024);
    print "New Client, $data, Connected\n";
    #push @userNames,$data;
    #push @users,$client_socket;
    recAndSend();
}

$socket->close();
