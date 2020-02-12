#!/usr/bin/perl5 -w
use strict 'vars';

   my $fnMail = $ARGV[0];
   open(MSG, $fnMail) or die "Can't open $fnMail: $!\n";
   my @lines = <MSG>;
   close(MSG);

   my $users;
   while (<DATA>) {
      $users .= $_;
   }
    
   # for each tag in file ________.

   my $msgNo = 1;


   my $left   = 0;
   my $right  = 0;
   my $mail;
   my @maildata;
LINE:   foreach (@lines) {
      if (/<MYMAIL>/i) # start
      {
         $mail .= $_;
         push(@maildata, $_);

         $left = 1;
         next LINE;
      }

      if (/<\/MYMAIL>/i)  # end
      {
         $mail .= $_;
         push(@maildata, $_);
         $right = 1;
         #next LINE;
      }

      if ($left && !$right)
      {
         $mail .= $_;
         push(@maildata, $_);
      }

      if ($left && $right)
      {

         #print "<fuck>";         print $mail;         print "</fuck>";

         # Validate
         if (&validate($mail) == 2)
         {
            #&expand($mail);
            if ($msgNo > 1) {print "\n<MESSAGE>$msgNo</MESSAGE>\n";}
            &expand(@maildata);
            $msgNo++;
         }

         $left  = 0;
         $right = 0;
         $mail  = "";
         @maildata = ();
      }
   }

sub validate()
{
   my $left = shift;
   my $retval = 0;

   #print "<FUCK>\n";   print $left;   print "</FUCK>\n";

   $left =~ /<HEADER>(.*)<\/HEADER>/mi;
   my $header =  $1 || ""; 

   #print "<UCK>\n";   print "$header";   print "</UCK>\n";

   $header =~ /From: .*<(.*?)>/im;
   my $from =  $1 || ""; 

   #print "<F>\n";   print $from;   print "</F>\n";


#print "$users\n";
   if ($users =~ /\b$from\b/i)
   {
      #print "JJJJJJJJJJ\n";       print "ok\n";

      $retval++;
   }

   # Check for tags
   $left =~ /<TAGS>(.*)<\/TAGS>/mis;
   my $tags =  $1 || ""; 
   #print "<AAA>\n";   print $tags;   print "</AAA>\n";
   if ($tags =~ /.*http/mi)
   {
      my $tags =  $1 || ""; 
      #print "<TT>\n";   print $tags;   print "</TT>\n";
      $retval++;
   }


   #print "<FUCK>\n";   print "not ok";   print "<FUCK>\n";

   return $retval;
}

sub expand()
{
   #sub expand($mail)
#   my @mail01 = shift;
#   @_
   my $left   = 0;
   my $right  = 0;
   my $leftTags   = 0;
   my $rightTags  = 0;



   #FM 10/19/05 print "<expand>\n";  
   #print $mail01;   
LINE:   foreach (@_)
   {
      if (/<HEADER>/i) # start
      {
         $left = 1;
      }

      if (/<\/HEADER>/i) # end
      {
         $right = 1;
      }

      if ($left && !$right)
      {
         if (/From: (.*)/m)
         {
            print "From: mastronardif\@netcarrier.com\n";
            print "To: $1\n";

            next LINE;
         }

         if (/Subject: (.*)/m)
         {
            print ;
            print "MIME-Version: 1.0\n";
            #print "Content-Type: text/html; charset=\"UTF-8\"\r\n";
            print "Content-type: text/plain; charset=iso-8859-1\r\n";

            print "\n";

            next LINE;
         }
         #########FMprint;
         next LINE;
      }

      if (/<TAGS>/i) # start
      {
         $leftTags = 1;
         next LINE;
      }

      if (/<\/TAGS>/i) # end
      {
         $rightTags = 1;
         next LINE;
      }

      if ($leftTags && !$rightTags)
      {
         if (/^http:\/\//)
         {
            #print; print "\n";

            open(MYDATA, "perl ./myget01.pl $_ |") or die "Can't fork for myget01: $!\n";
            #print SENDMAIL <MYDATA>;
            print <MYDATA>;
            print "<hr></hr>";
            print "<b>thank you for using joemailweb</b>";

            #print SENDMAIL "<hr></hr>";
            next LINE;
         }

         next LINE;
      }

      ############### FM 10/19/05print;
   }
   #FM 10/19/05 print "</expand>\n";
}


__END__
mastronardif@comcast.net
mastronardif@netcarrier.com
fmastronardi@interlink.bz


