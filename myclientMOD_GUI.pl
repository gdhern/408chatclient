#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use threads;
use Tk;

$| = 1;

my ($socket,$client_socket,$data,$userName, $message);


# GUI area below
# Main Window
$data = "";
$userName = "";
$message = "";

# Main Window
my $mw = MainWindow->new(-height => 600, -width => 600);



#Frame for the chatbox display
my $textFrame = $mw -> Frame(-width => 40, -height => 10);

my $textBox = $textFrame-> Scrolled('Text', 
                                    -scrollbars => 'ose',                                    
                                    -background => "white",
                                     );

my $button = $mw -> Button(-text => "Send", -command => \&broadcast);

my $entry = $mw -> Entry(-background => "white",
                              -width => 40,
                              -textvariable => \$message);          
            
tie *STDOUT, 'Tk::Text', $textBox;

# To send input simply by pressing 'Enter'
$entry -> bind('<Return>', \&broadcast);

# Give Entry box focus on launch
$entry -> focus;



# Geometry Management
$textFrame -> grid(-row => 1, -column => 1, -columnspan => 2, -sticky => "nsew");
$textBox -> grid(-row => 1, -column => 1, -sticky => "nsew");
$button -> grid(-row => 2, -column => 2, -sticky => "ew");
$entry -> grid(-row => 2, -column => 1, -sticky => "ew");
$mw -> gridColumnconfigure(1, -weight => 1);
$mw -> gridColumnconfigure(3, -weight => 1);
$mw -> gridRowconfigure(1, -weight => 1);
$mw -> resizable(0,0);
 


# Sub to broadcast to server
sub broadcast {
      my $string = $message;

      # If user has not entered anything yet, 
      # set username to input
      if($userName eq ""){
            $userName = $message;
            print $userName;                                  
      } 
      print "\n"; 

      if ($message eq "e"){$socket->send("e");exit();}
      else{$socket->send($message);} 
      
      #  Clear Entry box
      $entry -> delete(0, 'end');  
}

# ---End GUI construction---



$socket = new IO::Socket::INET (
PeerHost => '127.0.0.1',
PeerPort => '22222',
Proto => 'tcp',
) or die "ERROR in Socket Creation : $!\n";


print "LOGIN\nUsername: ";
# $socket->send($userName);

# Sub to read output from server
sub reader {
  while(1){
    $data = <$socket>;
    chomp($data);
    print "$data\n";
  }
}


# spawn thread for the server output reader
my $thr = threads->create(\&reader)->detach();


# Send exit call to server
$mw -> OnDestroy(sub {
  $socket->send("e");
});

# All Tk gui need this
MainLoop;


$socket->close();
