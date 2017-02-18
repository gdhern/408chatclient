#!/usr/bin/perl
print "LOGIN\nUsername: ";
$username = <STDIN>;
print "\n";


# open(USERS, "+<users.txt");
# if(!<USERS>){
#   print "Going to create file\n";
#   open(USERS, ">users.txt");
# }
# close USERS;

do {
  prompt();
  $input eq "M" ? composeMessage() :
    $input eq "I" ? checkInbox() :
    $input eq "E" ? term() : "";

} while(1);

sub prompt(){
  do{
    print "Send Message (M)\nCheck INBOX (I)\nExit (E)\n";
    chomp($input = uc <STDIN>);
    $input !~ /M|I|E/ ? print "Please try again...\n" : "";
  }
  while($input !~ /M|I|E/);
}


sub composeMessage(){
  print "To: ";
  $reciever = <STDIN>;
  #Check file for user name
  #if receiving user exists in the text file save the message to
  #a file for other user to access
  print "Message: ";
  $message = <STDIN>;
  print "\n";
}

sub checkInbox(){
  print $username, "\n";
}

sub term(){
  print "Goodbye\n";
  exit();
}
