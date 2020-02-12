#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
#require "sch00.lib";
require "./sch00.lib";

#for debuging only, remove in production. BEGIN
#use CGI::Carp qw(fatalsToBrowser); 
#for debuging only, remove in production. END

use strict "vars";

=comment
File: subscribe.pl

Purpose: subscription services
=cut

#print "Content-type: text/html\n\n";

$ENV{'PATH'} = '/usr/bin:/bin:/usr/local/bin'; 


my $query = new CGI;
print $query->header( "text/html" );


my $sc = $query->param('sc');
if(!($sc=~/^22JV$/i))
{

print <<bob;
<p>
Incorrect security code.
Please hit the backspace and try again.
</p>

<p><center>
<font face="arial, helvetica" size="-2">Return back to joeschedule.com<br>
<a href="../../../cgi/ngfop/joeschedule0.htm">JoeSchedule.com</a></font>
</center>
<p>

bob
   exit;
}


	&mailtheform();
print <<bob;
<p>
Thank you for subscribing.
We will verify your information and you should receive an email with 
your User ID and Password so you can begin using JoeSchedule.
</p>
bob

&reply($query);

sub reply {
   my($query) = @_;
   my(@values,$key);

=comment
   print "<H2>What you wrote:</H2>";

   foreach $key ($query->param) {
      ##print "<STRONG>$key</STRONG> -> ";
      @values = $query->param($key);
      print join(", ",@values),"<hr />\n";
  }
=cut

print <<DNE;

  Sincerely,<br>
<br>
<br>
  ________________<br>
  Joe Schedule	  

  <p><center>
<font face="arial, helvetica" size="-2">Return back to joeschedule.com<br>
<a href="../../../cgi/ngfop/joeschedule0.htm">JoeSchedule.com</a></font>
</center><p>
DNE

}

sub mailtheform()
{

my $to = "mastronardif\@netcarrier.com";

my $from = $query->param('email');
my $subject = "FM, JoeSchedule Subscription info";

#	my $comment = $query->param('comment');
#	my $negative = $query->param('negative');
   
   my ($fn) = ($0 =~ m#^.*/(.*?)$#);

	my $msg = "<data from $fn\/>\n";

	foreach my $key ($query->param) {
      my @values = $query->param($key);
#      my $vals = join(", ",@values),"\n";
      my $vals = join(", ",@values);

      $msg .= "<$key>\n$vals\n</$key>\n";
	}

#	my $contents = $msg;

open (MAIL, "|/usr/sbin/sendmail -t") || &ErrorMessage;

print MAIL "To: $to \nFrom: $from\n";
print MAIL "Subject: $subject\n";
print MAIL "$msg\n";

close (MAIL);


}

sub ErrorMessage {
        print "<P>FM, The server has a problem. Aborting script. \n";
        exit;
}



