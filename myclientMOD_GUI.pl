#!/usr/bin/perl

use IO::Socket::INET;
use threads;
use Tk;

$| = 1;

my ($socket,$client_socket,$data,$userName);


# GUI area below
# Main Window
my $mw = MainWindow->new(-height => 600, -width => 600);

#Frame for the chatbox display
my $textFrame = $mw -> Frame(-width => 40, -height => 10);
$textFrame -> grid(-row => 1, -column => 1, -columnspan => 2, -sticky => "nsew");

#Actual textbox for the chat display                              
my $textBox = $textFrame -> Text(-background => white);
$textBox -> grid(-row => 1, -column => 1, -columnspan => 2, -sticky => "nsew");

my $srl_y = $textFrame -> Scrollbar(-orient=>'v', -command=>[yview => $textBox]);
my $srl_x = $textFrame -> Scrollbar(-orient=>'h',-command=>[xview => $textBox]);
$textBox -> configure(-yscrollcommand=>['set', $srl_y], 
		-xscrollcommand=>['set',$srl_x]);

$srl_y -> grid(-row => 1, -column => 3, -sticky => "ns");
$srl_x -> grid(-row => 2, -column => 1, -sticky => "ew", -columnspan => 2);
$textBox -> grid(-sticky => "nsew");            
            

# my $label = $mw -> Label(-text=>"Hello World");
# $label -> grid(-row => 1, -column => 1);
my $button = $mw -> Button(-text => "Send", 
      -command => \&btnSend);
$button -> grid(-row => 2, -column => 2, -sticky => "ew");

my $entry = $mw -> Entry(-background => white,
                              -width => 40);
$entry -> grid(-row => 2, -column => 1, -sticky => "ew");

tie *STDOUT, 'Tk::Text', $textBox;
# tie *STDIN, 'Tk::Entry', $entry;

# $mw->configure(-width=> 40, -height=> 250);
$mw -> gridColumnconfigure(1, -weight => 1);
$mw -> gridColumnconfigure(3, -weight => 1);
$mw -> gridRowconfigure(1, -weight => 1);
$mw -> resizable(0,0);
MainLoop;

sub btnSend {
      my $string = $entry -> get();
      print $string;
      print "\n";
      $entry -> delete(0, 'end'); 
}

# ---End GUI construction---

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
    if ($message eq "e"){$socket->send("e");exit();}
    else{$socket->send($message);}
}

while(1)
{
    chomp($message = <STDIN>);
    userInput();
}



$socket->close();
