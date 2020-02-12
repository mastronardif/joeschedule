#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";

use strict "vars";

=comment
File: contactus.pl

Purpose: send user feeback to us.
=cut

print "Content-type: text/html\n\n";
$ENV{'PATH'} = '/usr/bin:/bin:/usr/local/bin';

my $query = new CGI;

#my $comment  = $query->param('comment') || "n/a";
#my $negative = $query->param('comment') || "n/a";
#my @names = $query->param;
#print @names;


#print $comment;
	&mailtheform();

print "Thanks for your inquiry.";
&reply($query);

sub reply {
   my($query) = @_;
   my(@values,$key);

   print "<H2>What you wrote:</H2>";

   foreach $key ($query->param) {
      ##print "<STRONG>$key</STRONG> -> ";
      @values = $query->param($key);
      print join(", ",@values),"<hr />\n";
  }

print <<END;
Thank you for your comments.<br>

  Sincerely,<br>
<br>
<br>
  ________________<br>
  Joe Schedule	  

  <p><center>
  <!-- 
<a href="http://javascriptsource.com">The JavaScript Source</a></font>
  
  -->
<font face="arial, helvetica" size="-2">Return back to joeschedule.com<br>
<a href="../../../cgi/ngfop/joeschedule0.htm">JoeSchedule.com</a></font>
<!--
http://gw/cgi-bin/cgi/ngfop/contactus.pl
http://gw/cgi-bin/cgi/ngfop/joeschedule0.htm
http://gw/cgi/ngfop/joeschedule0.htm
-->


</center><p>
END


}

sub mailtheform()
{

my $to = "mastronardif\@netcarrier.com";

my $from = $query->param('email');
my $subject = "FM, JoeSchedule contact us data";

#	my $comment = $query->param('comment');
#	my $negative = $query->param('negative');

	my $msg = "<data from contactus.pl\/>\n";

	foreach my $key ($query->param) {
      my @values = $query->param($key);
      my $vals = join(", ",@values),"\n";

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



