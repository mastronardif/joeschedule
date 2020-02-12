#!/usr/bin/perl5 -w

die "please supply a filename as an argument.\n" unless $ARGV[0];

   my $fnMail = $ARGV[0];
   open(MSG, $fnMail) or die "Can't open $fnMail: $!\n";
   my @lines = <MSG>;
   close(MSG);


open(SENDMAIL, "|/usr/sbin/sendmail -i -oi -t -odq")
                        or die "Can't fork for sendmail: $!\n";

   # for each tag in file ________.

   my $left   = 0;
   my $right  = 0;
   my $mail;
   my @maildata;
LINE:   foreach (@lines) {
      if (/<MESSAGE>(.*?)<\/MESSAGE>/i) # delimeter
      {
         #reset
         #$mail .= $_;
         push(@maildata, $_);

         $left = 1;

         $mail  = "";
         @maildata = ();
         #print "\n\nFUCK\n\n";
         print SENDMAIL 'EOF';

         print SENDMAIL ".\n";

         print ".";
close(SENDMAIL)     or warn "sendmail didn't close nicely";
sleep (5);
open(SENDMAIL, "|/usr/sbin/sendmail -i -oi -t -odq")
                        or die "Can't fork for sendmail: $!\n";



         next LINE;
      }

      print SENDMAIL $_;

      #$mail .= $_;
      #push(@maildata, $_);
   }

close(SENDMAIL)     or warn "sendmail didn't close nicely";

exit;








   
    
    #print SENDMAIL "From: mastronardif\@netcarrier.com\n";
    #print SENDMAIL << EOF;

=comment    
    print SENDMAIL "From: mastronardif\@gw.example.org\n";
    print SENDMAIL "To: mastronardif\@comcast.net\n";
    print SENDMAIL "Subject: This is from $0\n";


   print SENDMAIL "MIME-Version: 1.0\n";
   print SENDMAIL "Content-Type: text/html; charset=\"UTF-8\"\r\n";
=cut
#    print SENDMAIL "Body of the message goes here, in as many lines as you like.\n";

#open(MYDATA, "perl ./myget01.pl http://www.themonroetimes.com/o1008aut.htm |")
#open(MYDATA, "cat ./mymaillog.txt |")


open(MYDATA, "cat ./$ARGV[0] |")
                        or die "Can't cat ./$ARGV[0]: $!\n";
    print SENDMAIL <MYDATA>;


#   print SENDMAIL "Content-Type: text/html; charset=\"UTF-8\"\r\n";
#open(MYDATA, "cat ./mymaillog.txt |")
#                        or die "Can't fork for myget01: $!\n";
    print SENDMAIL <MYDATA>;


close(SENDMAIL)     or warn "sendmail didn't close nicely";

