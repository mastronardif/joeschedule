#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";

use strict "vars";


=comment
File: signin.pl

Purpose: Sign in to schedule prog.
=cut


my $query = new CGI;


##################################
# Get session data               #
#11/9/9my %session = &SCH_getSession(); #
##################################


##############################
# get parameters from a form #
##############################
my $id = $query->param('id') || "";
my $pw = $query->param('pw') || "";

#fm 1/24/9
# trim whitespace ws.
$id =~ s/^\s+//;
$id =~ s/\s+$//;

$pw =~ s/^\s+//;
$pw =~ s/\s+$//;
#fm 1/24/9

my $action = $query->param('action') || "";

# Fm 8/18/7
   $id =~ /^([0-9a-zA-Z_\.]*?)$/;
   $id = $1 || "";

   $pw =~ /^(\w+)$/;
   $pw = $1 || "";

   if ($id=~/\./)
   {
      $id="$id/$pw";
   }

# FM 8/18/7



##############################
if ($action =~ /^signout$/i)
{
   # sign out!!!
   &SCH_SignOut();
   exit;

$action ="Demo";

}
##############################


if ($action =~ /^Demo$/)
{
   $id = "Demo";
   $pw = "";
}

######################
# Authenticate id/pw #
######################
#FM 12/5/7 if(!&SCH_authenticate($id, $pw))
#print "Content-type: text/html\n\n";
#print "$id $pw --- ";
my $authCode = &SCH_authenticate($id, $pw);

# FM 1/21/9
$id = $authCode;
# FM 1/21/9

#Fm 1/20/9 if(0 == $authCode)
if($authCode =~ m/fail/i)
{
print "Content-type: text/html\n\n";
print <<"END";
<p><font size="6" color="#FF0000"><b>fail($authCode)Invalid ID/Password.<br />
Please go back and try again.
</b></font></p>
END

# Fm 8/17/7
###$id-$pw-$authCode$authCode$authCode$authCode$authCode$authCode;
##print("<h1>id($id)</h1>");
# Fm 8/17/7

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






my $oreo = cookie( -NAME    => 'sessionID',
                -value   => $id,
                -expires => '+3M',    # M for month, m for minute
#-domain=>'.pairlitesite.com',
-domain=>'.joeschedule.com',
                );
#                -DOMAIN  => '.perl.com');

## my $whither  = "http://www.joeschedule.com/cgi/ngfop/root.html";
my $whither  = "http://www.joeschedule.com/cgi/ngfop/left02.pl?htmlname=topnav2.html";

#FM 2/23/19 my $whither  = "http://www.joeschedule.com/cgi/ngfop/new_page_3.htm";
#my $whither  = "http://www.pl1321.pairlitesite.com/cgi/ngfop/new_page_3.htm";
#fm 12/25/10 my $whither  = "http:/cgi/ngfop/new_page_3.htm";

## FM 8/30/7
if ($id =~ /Coupon/i && $pw =~ /Coupon/i)
{
#print ("<h1>$id/$pw</h1>");

$whither  = "http://www.joeschedule.com/js3col_coupons01.htm";
print redirect( -URL     => $whither,
                -COOKIE  => $oreo);
exit;
}
## FM 8/30/7

print redirect( -URL     => $whither,
                -COOKIE  => $oreo);

# FM 12/11/09
# move this cookie &*##* to the .lib file.
if(29==9)
{
   #reset the cookie
   my $cookieString=$id;
   print "Content-type: text/html\n";
   print "Set-Cookie: sessionID=$cookieString; host=.joeschedule.com; path=/; expires=Friday, +3M \n\n";
   print "\n"; print "\n";

   my $full_url = $query->url();
   $full_url =~ /(.+)\//;

   # get domain.  so i can work locally or on the net.
   my @dirs = split m!/!, $full_url;
   my $root = "$dirs[0]//$dirs[2]/";

   #$root="new_page_3.htm";
   $root="http://www.joeschedule.com/cgi/ngfop/new_page_3.htm";

print <<"END";
<BODY onLoad="redirTimer()">
redirecting<br/>
$full_url
<SCRIPT LANGUAGE="JavaScript1.2">
<!-- Begin
redirTime = "0";
redirURL = "$root";
function redirTimer() { self.setTimeout("self.location.href = redirURL;",redirTime); }
// End -->
</script>
END
}
# FM 12/11/09

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
//FM 2/23/19 redirURL = "$root";
redirURL = "$root/index.html";
function redirTimer() { self.setTimeout("self.location.href = redirURL;",redirTime); }

//alert("$root")
//document.location.href = '/cgi/ngfop/new_page_3.htm';

// End -->
</script>
END

}
