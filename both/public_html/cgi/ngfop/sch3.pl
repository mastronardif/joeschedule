#!/usr/bin/perl -w

use CGI qw(:standard escapeHTML);
require "./sch00.lib";

=comment
File: sch3.pl

Purpose: read xml convert to hml.
=cut

#use strict 'vars';

print "Content-type: text/html\n\n";

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################

$query = new CGI;

my $blankSchedule = "blank.xml";
#FM 6/4/ my $blankSchedule = "./blank.xml";
##my $xmlfilename = $query->param('name') || $blankSchedule;
my $xmlfilename = $query->param('name') || "";
my $action = $query->param('action');
my $html = $query->param('htmlname') || "./sch3.htm";
my $student = $query->param('student') || "";
my $usedir = $query->param('usedir')   || $session{dir};

## Fm 6/4/8
my $pubFN = "";
if ($xmlfilename)
{
   $pubFN = "$session{dir}$xmlfilename";
}

#print "pubFN = 0($pubFN)<br>\n";
if ($usedir =~ m/usedir\s*\(/i)
{
    $usedir =~ /\((.*)\)/igs;

   #remove leading trailing ws
    my $trim = $1 || "";
    $trim =~ s/^\s+//;
    $trim =~ s/\s+$//;
    my $pubdir = $trim;
#print "FFF($session{dir}$xmlfilename)<br>\n";    
   
   if (!(-e "$session{dir}$xmlfilename"))
   {
      $pubFN = "./members/$trim/$xmlfilename";
   }
   #print "pubFN = 1($pubFN)<br>\n";
}

## Fm 6/4/8

my $swms = "";
if ($student)
{
   my $fn = "StudentAbaSWMs.xml";
   $swms = &SCH_SWMs_GetRows($session{dir}, $student);
}

=comment
##########################
# FM 11/23/03
# mov this calander stuff
# to the sch00.lib file.
##########################
# set default file
#if (!(-e $xmlfilename))
if (!(-e "$session{dir}$xmlfilename"))
{
   $xmlfilename =~ /(.+\.)(.+\.xml)/igs;

   my $dayfile = $2 || "";

   my $ddd = $1 || "";
   $ddd =~ /(.+)(\/)/igs;
   $xmlfilename = "$1/$dayfile";

   ($xmlfilename) || ErrorMessage($xmlfilename);
   #print "xmlfilename = aa($xmlfilename)<br>\n";

}
=cut


my $XMLkeys;
my @schData;
#open(MSG, $xmlfilename) || ErrorMessage($xmlfilename);
# FM 6/4/8 open(MSG, "$session{dir}$xmlfilename") || ErrorMessage("$session{dir}$xmlfilename");
#$pubFN = "$session{dir}$xmlfilename";
#print "pubFN = 2($pubFN)<br>\n";

#FM 6/4/8 open(MSG, "$pubFN") || ErrorMessage("$xmlfilename");
if ($pubFN)
{
   open(MSG, "$pubFN") || ErrorMessage("$pubFN");
   @schData = <MSG>;
   close(MSG);
}


open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";
   my $x;

   for $x(0 .. $#lines) {

      # get marker.
      if ($lines[$x] =~ /<swms>|<filename>|<Row>|<description>|<name>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      if ($lines[$x] =~ /<\/swms>|<\/filename>|<\/Row>|<\/description>|<\/name>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
         my $tagSWMs = "SWMs";
         ###############################
         # if <FILENAME>               #
         ###############################
         my $tag = "filename";
         if ($marker =~ /<\/\b$tag\b>/i)
         {
            $_ = $marker;
      
            /<\b$tag\b>(.*)<\/\b$tag\b>/igs;    

            #remove leading trailing ws
            my $trim = $1 || "";
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;

            $trim =~ s/<FILENAME>/$xmlfilename/igs;

            print $trim;
         }
         ###############################
         # if <SWMS>                   #
         ###############################
         elsif ($marker =~ /<\/\b$tagSWMs\b>/i)
         {
            $tag = $tagSWMs;
            $_ = $marker;
      
            /<\b$tag\b>(.*)<\/\b$tag\b>/igs;    

            #remove leading trailing ws
            my $trim = $1 || "";
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;

            $trim =~ s/<SWMS>/$swms/igs;

            print $trim;
         }
         else
         {
            if ($marker =~ /<description>/i)
            {
               $XMLkeys = uc "<data>,<description>"
            }
            else
            {
               $XMLkeys = uc "<row>,<time>,<picture>,<pname>,<pdescription>,<name>"
            }

            my @table = &SCH_xmLRD($marker, $XMLkeys, @schData);

            # remove empty img's
            @table = &SCH_xmlRemoveEmptyPics(@table);

            print @table;
         }

         #default
         $XMLkeys = uc "<row>,<time>,<picture>,<pname>,<pdescription>,<name>";

         $marker = "";
         $left  = 0;
         $right = 0;
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
        exit;
}

