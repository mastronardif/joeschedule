#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";
use strict 'vars';

=comment
File: other2.pl

Purpose: read ___.htm, ___ xml convert to merged hml.
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
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action') || "";
my $avalue = $query->param('avalue') || "";
my $htmfilename = $query->param('htmlname') || $blankSchedule;
my $student     = $query->param('student')  || "";

my $studentsfile = "$session{dir}$xmlfilename";
my $mystudents = "";
if (($xmlfilename !~/^$blankSchedule/i) && (-e $studentsfile))
{
   open(MSG, $studentsfile) || ErrorMessage($xmlfilename);
   my @studentsData = <MSG>;
   close(MSG);
   my $studentsData = join ' ', @studentsData;
   
   $studentsData =~ /<data>(.*?)<\/data>/igs;
   $mystudents = $1 || "";
}

my @xmldata = <<END =~ m/(\S.*\S)/g;
<?xml version="1.0" encoding="UTF-8"?>
<data>
<student>
$student
</student>
<filename>
$xmlfilename
</filename>
<description>
Description for ($xmlfilename)
</description>
$mystudents
</data>
END

=comment
$ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(POST => $url);
$req->content_type('application/x-www-form-urlencoded');
$req->content($aec_post);
my $res = $ua->request($req);
#SEND USER TO $url ???
=cut

if ($action=~ /^ABASWMs$/i)
{
	# Save SWM's.
	my $fn = "StudentAbaSWMs.xml";
	my $data = $avalue;
	&SCH_SWMs_SaveList($session{dir}, $data);
}

if ($action=~ /^security$/i)
{
   if ("$session{dir}" =~ "Demo")
   {
      print "Hey now! <br/>It appears you have not Subscribed!";
      return;
   }
}

if ($htmfilename=~ m|^members/Sussina/0abakitxm22.htm$|i)
{
   if ("$session{dir}" =~ "Demo")
   {

      $htmfilename = "members/Sussina/AD0abakitxm22.htm";
      #print "Hey now! <br/>It appears you have not Subscribed!";
      #return;
   }
}

if ($action=~ /^pdf$/i)
{
   if (-r $xmlfilename)
   {
      print "<font size=\"1\"></code>/fop.sh -xsl 2cols.xsl -xml $xmlfilename  -pdf $xmlfilename.pdf</code></font>";
      system "./fop.sh -xsl 2cols.xsl -xml $xmlfilename  -pdf $xmlfilename.pdf";
      print "<hr></hr>";
      print "You can view $xmlfilename.pdf w/ Acrobat Reader if you like<br>";
      printf ("<A HREF=\"/cgi/ngfop/%s\">%s</A><br>", "$xmlfilename.pdf", "$xmlfilename.pdf");
   }
   else
   {
      print "xmlfilename($xmlfilename) don't exist's";
   }
   
   exit;
}

if ($action=~ /^delete$/i)
{
   ########################
   # Do security checking #
   # Get users root       #
   ########################
  
   my $fn = "$session{dir}$xmlfilename";
   if (-e $fn)
   {
      # get Description.
      my $desc = SCH_getDescription($xmlfilename);
      print "Removed ($desc)!<br />";

       #unlink($fn) || print " having trouble deleting $fn<br>";
       rename($fn, "$fn.rem") || print " having trouble removing $fn<br>";
      print "<h5>Removed aka renamed ($fn)</h5>";
   }

   #print "!Deleted ";
   print "($fn)";
}

open(MSG,"./$htmfilename") || ErrorMessage("./$htmfilename");
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";

   for my $x(0 .. $#lines) 
   {
      # get marker.
      if ($lines[$x] =~ /<filename>|<student>|<Row>|<description>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      if ($lines[$x] =~ /<\/filename>|<\/student>|<\/Row>|<\/description>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
         #print "xmldata(@xmldata)";
         if ($marker =~ /<filename>|<student>|<description>/i)
         {
            my $XMLkeys = uc "<data>,<filename>,<student>,<description>";
            my @table = &SCH_xmLRD($marker, $XMLkeys, @xmldata);
            print @table;
         }
         
         if ($marker =~ /<row>|<name>/i)
         {
            my $XMLkeys = uc "<row>,<name>";
            my @table = &SCH_xmLRD($marker, $XMLkeys, @xmldata);
            print @table;
         }

         $left  = 0;
         $right = 0;
         $marker = "";
         next;
      }

      if (!$left) {
         print "$lines[$x]\n";
      }
   }

sub ErrorMessage {
   my $fn = shift(@_);
        print "Content-type: text/html\n\n";
        print "The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        #exit;
}
