#!/usr/bin/perl5 -w
use strict 'vars';

   my $fnMail = $ARGV[0];
   open(MSG, $fnMail) or die "Can't open $fnMail: $!\n";
   my @lines = <MSG>;
   close(MSG);


    
    for (1..4)
    {
    sleep (1);
    print ;
open(SENDMAIL, "|/usr/sbin/sendmail -oi -t -odq")
                        or die "Can't fork for sendmail: $!\n";


         #print SENDMAIL << "EOF";
    print SENDMAIL "From: mastronardif\@netcarrier.com\n";
    print SENDMAIL "To: mastronardif\@netcarrier.com\n";
    print SENDMAIL "Subject: This is from \n";

    print SENDMAIL "MIME-Version: 1.0\n";
    print SENDMAIL "Content-Type: text/html; charset=\"UTF-8\"\r\n";

    print SENDMAIL "Body of the message goes here, in as many lines as you like.\n";
close(SENDMAIL)     or warn "sendmail didn't close nicely";
    }
    exit;
   # for each tag in file ________.

   my $left   = 0;
   my $right  = 0;
   my $mail;
LINE:   foreach (@lines) {
      if (/<MYMAIL>/i) # start
      {
         $left = 1;
         next LINE;
      }

      if (/<\/MYMAIL>/i)  # end
      {
         $right = 1;
         #next LINE;
      }

      if ($left && !$right)
      {
         $mail .= $_;
      }



      if ($left && $right)
      {

         #print "<fuck>";         print $mail;         print "</fuck>";

         print SENDMAIL $mail;
         print SENDMAIL EOF;

         $left  = 0;
         $right = 0;
         $mail  = "";
      }
   }

close(SENDMAIL)     or warn "sendmail didn't close nicely";

