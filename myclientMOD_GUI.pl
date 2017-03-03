#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use threads;
use Tk;

$| = 1;

my ($socket,$client_socket,$data,$userName, $message);

$socket = new IO::Socket::INET (
PeerHost => '127.0.0.1',
PeerPort => '22222',
Proto => 'tcp',
) or die "ERROR in Socket Creation : $!\n";

# GUI area below
# Main Window
$data = "";
$userName = "";
$message = "";

# Main Window
my $mw = MainWindow->new(-height => 600, -width => 600);

# Listen for message from server using fileevent method
$mw ->fileevent($socket, readable => sub {
    my $line = <$socket>;
    unless (defined $line) {
      $mw->fileevent($socket => readable => '');
      return;
    }      
    chomp($line);
    print "$line\n";
});



#Frame for the chatbox display
my $textFrame = $mw -> Frame(-width => 40, -height => 10);

my $textBox = $textFrame-> Scrolled('ROText', 
                                    -scrollbars => 'ose',                                    
                                    -background => "white",                                                                    
                                     );

my $button = $mw -> Button(-text => "Send", -command => \&broadcast);

# Here we define the Entry widget and use the -textvariable
# option to assign the input string to the $message variable.
my $entry = $mw -> Entry(-background => "white",
                              -width => 40,
                              -textvariable => \$message);          

# This line ties the standard output stream to the $textbox
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
 
# ---End GUI construction---

# Method to broadcast to server
sub broadcast {
      my $string = $message;

      # If user has not entered anything yet, 
      # set username to input
      if($userName eq ""){
            $userName = $message;            
            print $userName; 
            print "\n"; 
      }       

      if ($message eq "e"){$socket->send("e");exit();}
      else{$socket->send($message);} 
      
      #  Clear Entry box
      $entry -> delete(0, 'end');  
}

print "LOGIN\nUsername: ";


# Send exit call to server
$mw -> OnDestroy(sub {
  $socket->send("e");
});

# All Tk gui need this
MainLoop;


$socket->close();
