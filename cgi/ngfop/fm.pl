#!/usr/bin/perl -wT

use CGI;
#require "./sch00.lib";

use strict "vars";
my $query = new CGI;


my $id = $query->param('id') || "";
my $pw = $query->param('pw') || "";


#fm 1/24/9
# trim whitespace ws.
$id =~ s/^\s+//;
$id =~ s/\s+$//;

$pw =~ s/^\s+//;
$pw =~ s/\s+$//;

my $action = $query->param('action') || "";


if (10)
{
my $cookie = $query->cookie(-name=>'MY_COOKIE',
			 -value=>'BEST_COOKIE=chocolatechip',
			 -expires=>'+4h');

print $query->header(-cookie=>$cookie);

print $query->start_html('My cookie-set.cgi program');
print $query->h3('The cookie has been set');


print qq{<meta http-equiv="REFRESH" content="0;URL=http://www.joeschedule.com/cgi/ngfop/fmcookie.pl">\n};
print $query->end_html;

exit;
}


# Fm 8/18/7
   $id =~ /^([0-9a-zA-Z_\.]*?)$/;
   $id = $1 || "";

   $pw =~ /^(\w+)$/;
   $pw = $1 || "";

   if ($id=~/\./)
   {
      $id="$id/$pw";
   }

if ($action =~ /^signout$/i)
{
   # sign out!!!
   &SCH_SignOut();
   exit;

$action ="Demo";

}
##############################


if (0)
{
print "Content-type: text/html\n\n";
print "id = $id <br/>";
print "pw = $pw <br/>";
print "<br/>";
#exit;
}

if (0)
{
print "Content-type: text/html\n\n";
print <<EOF;
id = $id <br/>
pw = $pw <br/>
<br/>
EOF
exit;
}

######################

#print ("<h1>$id/$pw</h1>");

########################################################
# cookie shit #
########################################################
#my $cookie = $query->cookie(-name=>'sessionID',
#                            -value=>'xyzzy',
#                            -expires=>'+1h',
#                            -path=>'/cgi-bin/database',
#                            -domain=>'.capricorn.org',
#                             -secure=>1);

#11/4/9 my $cookie = $query->cookie(-name=>'sessionID', -value=>$id);
####print $query->header(-cookie=>$cookie);

my $oreo = cookie(-name    => 'WsessionID',
                -value   => 'Amherst',
                -expires => '+3M',    # M for month, m for minute
                -domain  => '\.joeschedule\.com'

                );

#                -domain  => '.perl.com');

#my $whither  = "http://www.joeschedule.com/cgi/ngfop/new_page_3.htm";
my $whither  = "http://www.joeschedule.com/cgi/ngfop/fmcookie.htm";
#my $whither  = "http:/cgi/ngfop/new_page_3.htm";

if (10)
{
#print "Content-type: text/html\n\n";
print $query->cookie( -name => 'my_ten_minute_cookie',
-value => 'Ten Minutes',
-expires => '+106m',
-domain => '.joeschedule.com'
); 
print qq{<meta http-equiv="REFRESH" content="0;URL=http://www.joeschedule.com/cgi/ngfop/fmcookie.htm">\n};

exit;
}

if (0)
{
print "Content-type: text/html\n\n";
print <<EOF;
id = $id <br/>
pw = $pw <br/>
<br/>
$whither
<br/>
$oreo
<br/>
EOF
exit;
}


print redirect( -URL     => $whither,
                -COOKIE  => $oreo);
exit;

sub SCH_SignOut()
{

   #reset the cookie
   my $cookieString="NULL"; 
   print "Content-type: text/html\n"; 
   print "Set-Cookie: sessionID=$cookieString; expires=Friday, 06-Apr-01 10:00:00 GMT \n\n"; 
   print "\n"; print "\n"; 

   # go back to login screen.
   ##http://gw/cgi-bin/cgi/ngfop/sch3.pl?name=cbcooking.xml&htmlname=cb3a.htm

   my $full_url = $query->url();
   $full_url =~ /(.+)\//;

   # get domain.  so i can work locally or on the net.
   my @dirs = split m!/!, $full_url;  
   my $root = "$dirs[0]//$dirs[2]/";

#FM 02/25/06   $root = "$root/cgi/ngfop/joeschedule0.htm";

print <<"END";
<BODY onLoad="redirTimer()">
<SCRIPT LANGUAGE="JavaScript1.2">
<!-- Begin
//redirTime = "15000";
redirTime = "0";
redirURL = "$root";
function redirTimer() { self.setTimeout("self.location.href = redirURL;",redirTime); }

//alert("$root")
//document.location.href = '/cgi/ngfop/new_page_3.htm';

// End -->
</script>
END

}
