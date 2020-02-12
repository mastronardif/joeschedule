#!/usr/bin/perl -wT
use CGI;

my $query = new CGI;
my $theCookie = $query->cookie('MY_COOKIE');

my $id = $query->param('id') || "";

if(9)
{

   #reset the cookie
#   my $cookieString="SSNULL";
   my $cookieString=$id;
   print "Content-type: text/html\n";
   print "Set-Cookie: sessionID=$cookieString; path=/; expires=Friday, +3M \n\n";
#   print "Set-Cookie: sessionID=$cookieString; expires=Friday, 06-Apr-01 10:00:00 GMT \n\n";
   print "\n"; print "\n";

   my $full_url = $query->url();
   $full_url =~ /(.+)\//;

   # get domain.  so i can work locally or on the net.
   my @dirs = split m!/!, $full_url;
   my $root = "$dirs[0]//$dirs[2]/";

#FM 02/25/06   $root = "$root/cgi/ngfop/joeschedule0.htm";
#$root="fmcookie.htm";
$root="new_page_3.htm";

print <<"END";
<BODY onLoad="redirTimer()">
what eh fjasdfi<br/>
$full_url
<SCRIPT LANGUAGE="JavaScript1.2">
<!-- Begin
//redirTime = "15000";
redirTime = "510";
redirURL = "$root";
function redirTimer() { self.setTimeout("self.location.href = redirURL;",redirTime); }
// End -->
</script>
END
}

if(0)
{
print "Content-type: text/html\n\n";
print "<BLOCKQUOTE>\n";
print "cookie = ".$theCookie;
print "</BLOCKQUOTE>\n";
}


