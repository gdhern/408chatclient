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

# $textFrame -> pack;

#Actual textbox for the chat display                              
# my $textBox = $textFrame -> Text(-background => white);
# $textBox -> grid(-row => 1, -column => 1, -columnspan => 2, -sticky => "nsew");
my $textBox = $textFrame-> Scrolled('Text', 
                                    -scrollbars => 'ose',                                    
                                    -background => "white",
                                     );

my $button = $mw -> Button(-text => "Send", -command => \&broadcast);

my $entry = $mw -> Entry(-background => "white",
                              -width => 40,
                              -textvariable => \$message);
# $eJoshntry -> focus;                              

# my $srl_y = $textFrame -> Scrollbar(-orient=>'v', -command=>[yview => $textBox]);
# my $srl_x = $textFrame -> Scrollbar(-orient=>'h',-command=>[xview => $textBox]);
# $textBox -> configure(-yscrollcommand=>['set', $srl_y], 
# 		-xscrollcommand=>['set',$srl_x]);

# $srl_y -> grid(-row => 1, -column => 3, -sticky => "ns");
# $srl_x -> grid(-row => 2, -column => 1, -sticky => "ew", -columnspan => 2);
# $textBox -> grid(-sticky => "nsew");            
            
tie *STDOUT, 'Tk::Text', $textBox;
# tie *STDIN, 'Tk::Entry', $entry;
$entry -> bind('<Return>', \&broadcast);

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
 



sub broadcast {
      my $string = $message;
      if($userName eq ""){
            $userName = $message;
            print $userName;                                  
      } 
      print "\n";       
      if ($message eq "e"){$socket->send("e");exit();}
      else{$socket->send($message);}   
      $entry -> delete(0, 'end');  
}

# ---End GUI construction---



$socket = new IO::Socket::INET (
PeerHost => '127.0.0.1',
PeerPort => '22222',
Proto => 'tcp',
) or die "ERROR in Socket Creation : $!\n";

# print "Connected to Chat Server\n";
print "LOGIN\nUsername: ";
# $socket->send($userName);

sub reader {
  while(1){
    $data = <$socket>;
    chomp($data);
    print "$data\n";
  }
}



my $thr = threads->create(\&reader)->detach();

# sub userInput{
#     if ($message eq "e"){$socket->send("e");exit();}
#     else{$socket->send($message);}
# }

# while(1)
# {
#     # chomp($message = <STDIN>);
#     userInput();
# }
MainLoop;


$socket->close();
