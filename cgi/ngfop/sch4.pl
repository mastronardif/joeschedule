#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";
=comment
File: sch4.pl


Purpose: read xml convert to hml.
=cut

use strict 'vars';

print "Content-type: text/html\n\n";

my $query = new CGI;

my $blankSchedule = "./blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action') || "";
my $html = $query->param('htmlname') || "./sch3.htm";
my $picRoot = "/cgi/ngfop/pics/";

# set default file
if (!(-e $xmlfilename))
{
   $xmlfilename =~ /(.+\.)(.+\.xml)/igs;

   my $dayfile = $2 || "";

   my $ddd = $1 || "";;
   $ddd =~ /(.+)(\/)/igs;
   $xmlfilename = "$1/$dayfile";

   ($xmlfilename) || ErrorMessage($xmlfilename);
}


my $XMLkeys;
my @schData;
#open(MSG, $xmlfilename) || ErrorMessage($xmlfilename);
#@schData = <MSG>;
#close(MSG);

if ($action=~ /dir/i)
{
   $action =~ /\((.*)\)/;
   my $dir = $1;

#   $dir =~ /(.*\/)(.*)/i;
#   $dir = $1;
#   my $picDir = $2 || "";
   ##########
   # lookup #
   ##########

   @schData = &GetDirInfo("./pics/$dir");
}
else
{
   open(MSG, $xmlfilename) || ErrorMessage($xmlfilename);
   @schData = <MSG>;
   close(MSG);
}


########################################
# open html file                       #
########################################
open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";
   my $x;


   for $x(0 .. $#lines) {

      # get marker.
      if ($lines[$x] =~ /<filename>|<Row>|<description>|<name>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      if ($lines[$x] =~ /<\/filename>|<\/Row>|<\/description>|<\/name>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
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
            #printf($trim, $xmlfilename);
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

            ##########################################
            # Decorate                               #
            ##########################################
            @table = &decorate(@table);

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

sub decorate()
{
   my(@lines) = @_;
   my $results = "";

   my $iCol=0;
   for $x(0 .. $#lines) {
      if ($iCol++ == 4)
      {
         #$lines[$x] .= "<tr><\/tr>";
         $lines[$x] .= "<\/tr><tr>";
         $iCol = 0;
      }
   }

   return @lines;
}


sub ErrorMessage {
   my $fn = shift(@_) || "__";
        print "Content-type: text/html\n\n";
        print "The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        exit;
}

sub GetDirInfo()
{
   my $dir = shift(@_);

   # FM, cheese.
   $dir =~ /(.*\/)(.*)/i;

   my $picDir = $2 || "";

   my @dirdata;

   opendir(DIR, $dir) || ErrorMessage($dir);
   my @logfiles= readdir(DIR);
   closedir(DIR);


   push(@dirdata, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
   push(@dirdata, "<data>\n");


   if ($#logfiles) {
      foreach my $fn(@logfiles) {

#      print "<br>   --- $fn\n";

      unless ($fn =~ /\.JPG$|\.GIF$|\.PNG$/i) {next;}

      #   # Filter *.htm, .html, .cgi, .pl
      #   unless ($fn =~ /\.xml$/i) {$fn = ""; next;}

         push(@dirdata, "<row>\n");

         push(@dirdata, "<Picture>\n");
         push(@dirdata,  "$picRoot$picDir/$fn\n");
         push(@dirdata,  "</Picture>\n");

         push(@dirdata, "<name>\n");
         push(@dirdata, "ame\n");
         push(@dirdata,  "</name>\n");

         push(@dirdata, "</row>\n");
      }
   }
   
   push(@dirdata, "</data>\n");

   return  (@dirdata);
}

