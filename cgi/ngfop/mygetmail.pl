#!/usr/bin/perl -w
use CGI qw(:standard escapeHTML);

##require "./sch00.lib";

use strict "vars";

print "Content-type: text/html\n\n";

my $query = new CGI;

my $myOutpath='/usr/home/pl1321/JSAdmin/log';
my $fn =  $myOutpath."/cloudmail.txt";

print "Thanks for your inquiry.";
&reply($query);

my $mail="";
sub reply {
   my($query) = @_;
   my(@values,$key);

   print "<H2>What you wrote:</H2>";

   my $bFirstRow=0;
   foreach $key ($query->param) {
      print "<STRONG>$key</STRONG> -> ";
      @values = $query->param($key);
      print join(", ",@values),"<hr />\n";

      #my $fff=join(", ",@values);
      #$mail .= "$key ->" . join(", ",@values);
      if ($bFirstRow || $bFirstRow++)
      {
         $mail .="\n";
      }
      $mail .= "$key -> \n\t" . join(", ",@values);
  }

  if ($mail)
  {
     open(DBG, ">>$fn") || die print "can not open($fn)$!";
     print DBG "\n***\nlocaltime: ". localtime() ."\n";
     print DBG "\n$mail\n";

    # joemailweb call
    if ($mail =~ m/joemailweb/igs)
    {
       print "Holy shit dude!";
       #FM do the usual xy___ security check.
       my $var= `/usr/www/users/pl1321/cgi-bin/gojoemailweb.sh`;
       print $var;
    }

  }

}
