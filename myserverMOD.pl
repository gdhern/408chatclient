#!/usr/bin/perl

use strict;
use IO::Socket::INET;
use threads;
use threads::shared;

$| = 1;

my ($name,$tName,$message,$iter);

our @clients : shared;
@clients = ();

# Create socket here
my $socket = new IO::Socket::INET (
LocalHost => '127.0.0.1',
LocalPort => '22222',
Proto => 'tcp',
Listen => 5,
Reuse => 1
) or die "ERROR in Socket Creation : $!\n";

print "SERVER Waiting for client connection on port 22222\n";

# Method to initialize a new client/server connection
sub process {
    my $data;

    # This line maps the array elements passed form our
    # thread 'create()' method to local variables.
    my ($lname, $lclient, $lfileno) = @_;

    print "$lname Connected.\n";
    print $lclient "Welcome to server\n";

    # Here we write a conneciton method to each client
    # in the client list.
    foreach my $fn (@clients){
        open my $fh, ">&=$fn" or warn $! and die;
        print $fh "$lname Connected.\n";
    }
    while(1){
        # Listen for message from clients
        $lclient->recv($message, 1024);

        # Indicates the client has has disconnected
        if($message eq "e"){

            # This line uses Perl's grep() method to remove the 
            # file handle corresponding to $lfileno from the 
            # @clients list. It returns a list of the elements for
            # which the code block evaluates to true. Inside the block
            # the $_ variable corresponds to the current list element,
            # while the '!~' operator attempts to match the element with
            # the variable on the right and returns a boolean 'false' if
            # they DO MATCH, and 'true' if they DO NOT MATCH.
            @clients = grep {$_ !~ $lfileno} @clients;

            print "$lname disconnected.\n";

            # Print a message to all other clients that $lfileno has
            # disconnected.
            foreach my $fn (@clients){
                open my $fh, ">&=$fn" or warn $! and die;
                print $fh "$lname disconnected.\n";
            }
            
            # Kill this particular thread
            threads->exit();
        }

        # Echo clients message to all other clients in the @clients list
        else{
            foreach my $fn (@clients){
                open my $fh, ">&=$fn" or warn $! and die;
                print $fh "$lname> $message \n";
            }
        }
    }
    close($lclient);
}

# Main server loop
while(1)
{
    # wait for client to connect
    my $client_socket = $socket->accept();

    # Get client name from socket outputstream
    $client_socket->recv($name, 1024);

    # Perl doesn't allow us to share an array of client sockets,
    # so we will create an array of references to those sockets instead
    # to share among the threads created.
    my $fileno = fileno $client_socket;
    push (@clients, $fileno);

    # Here we pass the 'process' method by reference to the thread 'create()' method.
    # The other arguments will be passed as arguments to the process funciton
    # when when it is called.

    # '-> detach()' call  prevents the main program from blocking while Waiting
    # for the newly created thread to complete its execution.
    my $thr = threads->create(\&process, $name, $client_socket, $fileno)->detach();
}
$socket->close();
