#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";
require "./schdb.lib";
use strict 'vars';

=comment
File: register.pl

Purpose: Register user.
=cut

print "Content-type: text/html\n\n";

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################

##############
# Get params #
##############
my $query = new CGI;

my $blankSchedule = "blank.xml";
my $htmfilename = $query->param('htmlname') || $blankSchedule;
my $fn = $query->param('fn') || "";
my $ln = $query->param('ln') || "";
my $email = $query->param('email') || "";
my $id = $query->param('id') || "";
my $pw = $query->param('pw1') || "";

my @RegKeys = $query->param('RegKey');
# scrub RegKeys
my $regkey = join '', @RegKeys;

$htmfilename = "register01.htm";

open(MSG,"./$htmfilename") || ErrorMessage("./$htmfilename");
my @lines = <MSG>;
close(MSG);

my $myhtml = join('', @lines);
## <!--BEGIN_REGINFO--> <!--END_REGINFO-->
# You succesfully registration
my $template_onlineConfirmation = &getTemplate_OnlineConfirmation();
   
   my $error = 1;

   $error = &dbValidate("RegKey", $regkey);  
   if (!$error)
   {
      $error = &dbValidate("id", $id);  
   }
   
   if (!$error)
   {  ## write to db
      # 0. Save subsciber record(id, pw, email, name(fn, ln)
      $error = &SCHDB_Adduser($id, $pw, "$fn $ln", $email);
      #print "<span style=\"color: #f060ab;\"><i>$retval</i></span>";
   }
   
   if ($error) # Display error message(x) 
   {
      my $errorMsg = "<span class=\"ymemreq\">! $error</span>";
      my $TAG_error_message = "<!--ERROR_MESSAGE-->";

      $myhtml =~ s/$TAG_error_message/$errorMsg/igs;
      
      # set fld values where applicable.
      
      #@RegKeys[3]
      #input name="RegKey" value="" size="10" tabindex="1"
      if ($RegKeys[0])
      {
         $myhtml =~ s/input name="RegKey" id="RegKey1" value="" size="10" tabindex="1"/input name="RegKey" id="RegKey1" value="$RegKeys[0]" size="10" tabindex="1"/igs;
      }
      if ($RegKeys[1])
      {
         $myhtml =~ s/input name="RegKey" id="RegKey2" value="" size="10" tabindex="2"/input name="RegKey" id="RegKey2" value="$RegKeys[1]" size="10" tabindex="2"/igs;
      }
      if ($RegKeys[2])
      {
         $myhtml =~ s/input name="RegKey" id="RegKey3" value="" size="10" tabindex="3"/input name="RegKey" id="RegKey3" value="$RegKeys[2]" size="10" tabindex="3"/igs;
      }
      
      $myhtml =~ s/name="fn" id="fn" value="firstname"/name="fn" id="fn" value=$fn/igs;
           
      $myhtml =~ s/name="ln" id="ln" value="lastname"/name="ln" id="ln" value=$ln/igs;
      
      $myhtml =~ s/name="email" id="email" value=""/name="email" id="email" value=$email/igs;
      
      $myhtml =~ s/name="id" id="id" value=""/name="id" id="id" value=$id/igs;
   } 
   else 
   {
      # 1. (log) Success, Create subscription letter by id. (log)
      # 2. (log) Mail letters (batch job) (log)
      &SCHDB_Mail_ReplyFor($id, $pw);

      # 3. (log) log Transaction (log)
      
      my $letter = &templateLetter11($template_onlineConfirmation, $id, $pw);
      
      $myhtml =~ s/<!--BEGIN_REGINFO-->.*<!--END_REGINFO-->/$letter/igs;
   }
   
   @lines =  split '\n', $myhtml;

   print $myhtml;

sub ErrorMessage {
   my $fn = shift(@_);
        print "Content-type: text/html\n\n";
        print "The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        #exit;
}

sub getTemplate_OnlineConfirmation()
{
my $msg=<<"END";
<p style="
 color: #0060ab;
 font-family: 'Verdana', sans-serif;
 font-size: 26px;
 font-style: normal;
 font-variant: normal;
 font-weight: normal;
 letter-spacing: 0;
 line-height: 44px;
 margin-bottom: 0px;
 margin-left: 0px;
 margin-right: 0px;
 margin-top: 0px;
 opacity: 1.00;
 padding-bottom: 0px;
 padding-top: 0px;
 text-align: left;
 text-decoration: none;
 text-indent: 0px;
 text-transform: none;">
<b>Congratulations, <FULLNAME/>!</b>
</p>

<p align="left">
A confirmation message was sent to you via email.
</p>

<p align="left">
<b>Below are your account details</b>
<br/>You will need this information to sign in to joeschedule! and to reset your password in
case you forget it. Please print and keep this information in a safe place for future reference.
</p>

<p align="left">
   JoescheduleID: <b><ID/></b> &nbsp;&nbsp;&nbsp; PW: <b><PW/></b>
   <br/> Email address: <b><EMAIL/></b>
</p>
END

return $msg;
}

sub dbValidate()
{
   #my $retMsg = dbValidateRegKey(key, Value)
   my($key, $value) = @_;
   my $msg = "";
   
   ## Registration key.
   if ($key =~ m/Regkey/i)
   {
      if ($value !~ /1234567890|FreeTrial30/igs)
      {
         $msg = "Invalid registration key.";
      }
   }
   
   ## ID  
   if ($key =~ m/ID/i)
   {
      # Check id in not used.   
      if ($msg = SCHDB_DoesIDExists($value))
      {
	# old shcool remove after migration 
	if ($msg =~ /old school/i)
	{
           $msg = "ID being used. ".$msg;
	}
	else
	{
           $msg = "ID $id being used.";
	}

      }
   }
    
   return $msg;
}

sub templateLetter11()
{
   my($template, $id, $pw) = @_;
   my $letter="";
   
   my $href = &SCHDB_UserInfo($id);
   
   if ($href->{user})
   {
   $template =~ s/<id\/>/$href->{user}/igs;
   $template =~ s/<pw\/>/$pw/igs;
   $template =~ s/<email\/>/$href->{email}/igs;
   $template =~ s/<fullname\/>/$href->{fullname}/igs;
   }
   else
   {
      $template = <<END;
         Can not get user info.
         <p><font size="6" color="#FF0000"><b>Unknown User ID.<br />
         Please use Contact us button to resolve issue.
         </b></font></p>      
END
   }
   
   return $template;
}

sub getLetter_Reply()
{
my $msg=<<"END";
<p style="
 color: #0060ab;
 font-family: 'Verdana', sans-serif;
 font-size: 26px;
 font-style: normal;
 font-variant: normal;
 font-weight: normal;
 letter-spacing: 0;
 line-height: 44px;
 margin-bottom: 0px;
 margin-left: 0px;
 margin-right: 0px;
 margin-top: 0px;
 opacity: 1.00;
 padding-bottom: 0px;
 padding-top: 0px;
 text-align: left;
 text-decoration: none;
 text-indent: 0px;
 text-transform: none;">
<b>Congratulations, <FULLNAME/>!</b>
</p>

<p align="left">
<a href="http://www.joeschedule.com"> www.joeschedule.com</a>
<br/>
There is a help file available.  Any questions, please email us.
The eBook is here:
go to
<a href="http://www.joeschedule.com/cgi/ngfop/book/thebook.pdf">thebook.pdf</a>
or
<a href="http://www.joeschedule.com/cgi/ngfop/book/jsportfolio.htm">thebook</a>
to download the eBook Activity Schedule Ideas: A How-To Guide

</p>

<p align="left">
<b>Below are your account details</b>
<br/>You will need this information to sign in to joeschedule! and to reset your password in
case you forget it. Please print and keep this information in a safe place for future reference.
</p>

<p align="left">
   JoescheduleID: <b><ID/></b> &nbsp;&nbsp;&nbsp; PW:<b>_______</b>
   <br/> Email address: <b><EMAIL/></b>
</p>
END

return $msg;
}
