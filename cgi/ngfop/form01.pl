#!/usr/bin/perl -w

use CGI qw(:standard escapeHTML);
require "sch00.lib";
=comment
File: form01.pl

Purpose: , read xml convert to hml.
=cut

print "Content-type: text/html\n\n";

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################


$query = new CGI;

my $blankSchedule = "./blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action') || "";
my $html = $query->param('htmlname') || "./form01.htm";

if ($action=~ /^check$/i)
{

   print "Congrads you got ___ correct, you get the  next clue ________ <br>";
   print "Ice Cream or Donuts, or travel.";
$xmlfilename =~ tr/ /_/;

   return;
}



##################
# calander files #
##################
# set default file
my $defFile = $xmlfilename;
##if (!(-e $xmlfilename))
my $fff = "$session{dir}$xmlfilename";

my $fn = "$session{dir}$xmlfilename";
if ($xmlfilename =~/^$blankSchedule/i)
{
   $fn = $blankSchedule;
}

if (!(-e $fn))
{
   $xmlfilename =~ /(.+\.)(.+\.xml)/ig;
   my $dayfile = $2;

   my $ddd = $1;
   $ddd =~ /(.+)(\/)/igs;
   $defFile = "$1/$dayfile";
   $xmlfilename = $defFile;

   $fff = "$session{dir}$xmlfilename";
   $fn = "$session{dir}$xmlfilename";

   ##if (!(-e $defFile))
   if (!(-e $fff))
   {
      ##$xmlfilename = $blankSchedule;
      $fn = $blankSchedule;
   }
}




########################
#                      #
# XML Data             #
#                      #
########################
my $XMLkeys;
my @schData;
$fn = $xmlfilename;
if (!($xmlfilename =~ /^blank.xml/i))
{
   $fn = "$session{dir}$xmlfilename";
}

#open(MSG, $xmlfilename) || ErrorMessage($xmlfilename);
open(MSG, $fn) || ErrorMessage($fn);
@schData = <MSG>;
close(MSG);


########################
#                      #
# HTML Data            #
#                      #
########################
open(MSG, $html) || ErrorMessage($html);
 @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";


   for $x(0 .. $#lines) {

      # get marker.
      if ($lines[$x] =~ /<filename>|<Row>|<description>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      if ($lines[$x] =~ /<\/filename>|<\/Row>|<\/description>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {


         my $tag = "filename";
         if ($marker =~ /<\/\b$tag\b>/i)
         {
            $_ = $marker;
      
            /<\b$tag\b>(.*)<\/\b$tag\b>/igs;
      
            #remove leading trailing ws
            $trim = $1;
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;
            printf($trim, "");
         }
         else
         {
            if ($marker =~ /<description>/i)
            {
               $XMLkeys = uc "<data>,<description>";
               my @table = &SCH_xmLRD($marker, $XMLkeys, @schData);
               print @table;
            }
            if ($marker =~ /<row>/i)
            {
               $XMLkeys = uc "<row>,<time>,<picture>,<name>,<pname>";
               my @table = &SCH_xmLRD($marker, $XMLkeys, @schData);
               print @table;
            }

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
        exit;
}
