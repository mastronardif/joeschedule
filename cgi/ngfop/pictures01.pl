#!/usr/bin/perl -w

use CGI qw(:standard escapeHTML);
require "sch00.lib";
=comment
File: pictures.pl

Purpose: , read xml convert to hml.
=cut

print "Content-type: text/html\n\n";

$query = new CGI;

my $blankSchedule = "blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action');
my $html = "./pictures01.htm";


my $XMLkeys = uc "<Picture>,<name>,<description>";
#my @xmlkeys = split /,\s*/, $x;  
#print @xmlkeys;

#Removing leading path from filename 
#s(^.*/)()

my $filename = $xmlfilename;

$filename =~ s/(^.*\/)//;
my $dir = $1;

#print("<br>");
#print("dir($dir)<br> filename($filename)<br>");

#return;

my $htmlroot  = "/cgi/ngfop/";
my $picroot   = "/cgi/ngfop/pics/";
my @table;

if ($action=~ /^save$/i)
{
# format to _______.xml
$xmlfilename =~ tr/ /_/;
#$xmlfilename =~ s/\..*//;
#$xmlfilename = "$xmlfilename.xml";


   print "xmlfilename($xmlfilename)";

   # save to file
   &saveList;

   print "<H1>shit saved.  Hit the back button ";

   return;
}


my $weekdays = "Sun.xml Mon.xml Tue.xml Wed.xml Thu.xml Fri.xml Sat.xml";
my @days = split /\s+/, $weekdays;  # $word[0] = 'Calvin'
my $iii = 0;
                              
my @RewardsFile;

if ($action=~ /dir/i)
{
   $action =~ /\((.*)\)/;
   $dir = $1;

   @RewardsFile = &GetDirInfo($dir);
}
else
{
   open(MSG, $xmlfilename) || ErrorMessage($xmlfilename);
   @RewardsFile = <MSG>;
   close(MSG);
}

open(MSG, $html) || ErrorMessage($htm);
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
         #if ($marker =~ /<\/filename>/i)

         my $tag = "filename";
         if ($marker =~ /<\/\b$tag\b>/i)
         {
            $_ = $marker;
      
            /<\b$tag\b>(.*)<\/\b$tag\b>/igs;
      
            #remove leading trailing ws
            $trim = $1;
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;
            printf($trim, $defFile);
         }
         else
         {

            #readxmLRD22($marker, $XMLkeys, @RewardsFile);
            if ($action =~ /NonServer/i)
            {
               @table = &SCH_xmLRD2($marker, $XMLkeys, @RewardsFile, $picroot);
            }
            else
            {
               @table = &SCH_xmLRD($marker, $XMLkeys, @RewardsFile);
            }

            ##########################################
            # Decorate                               #
            ##########################################
            @table = &decorate(@table);

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


sub GetDirInfo()
{
   my $dir = shift(@_);

   my @dirdata;

#print ("<br>dur = $dir\n");

   opendir(DIR, $dir) || ErrorMessage($dir);
   @logfiles= readdir(DIR);
   closedir(DIR);
#print("@logfiles");
#print("<br>$#logfiles<br>");

   # FM, cheese.
   $dir =~ /\.\/pics\/(.*)/i;
   $dir = $1;
   #printf "<br><br>FUCKDIR $dir<br><br>\n";


   push(@dirdata, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
   push(@dirdata, "<data>\n");


   if ($#logfiles) {
      foreach $fn(@logfiles) {

#      print "<br>   --- $fn\n";

      unless ($fn =~ /\.JPG$|\.GIF$|\.PNG$/i) {next;}

      #   # Filter *.htm, .html, .cgi, .pl
      #   unless ($fn =~ /\.xml$/i) {$fn = ""; next;}

         push(@dirdata, "<Picture>\n");

         push(@dirdata, "<name>\n");

         push(@dirdata,  "$dir/$fn\n");

         push(@dirdata,  "</name>\n");

         push(@dirdata,  "</Picture>\n");
      }
   }
   
   push(@dirdata, "</data>\n");

   return  (@dirdata);
}


sub decorate()
{
   my(@lines) = @_;
   my $results = "";

   my $irow=0;
   for $x(0 .. $#lines) {
      #################################
      # FM, Cheesy cb check.          #
      # Check for Selection           #
      #################################
      if ($irow++ == 4)
      {
         $lines[$x] .= "<tr><\/tr>";
         $irow = 0;
      }
   }

   return @lines;
}


sub ErrorMessage {
   my $fn = shift(@_);
        print "Content-type: text/html\n\n";
        print "The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        exit;
}


sub saveList()
{
   open (LOG, ">./$xmlfilename") || &ErrorMessage($xmlfilename);

   print LOG "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
   print LOG "<data>\n";


   my $description = $formdata{'d0'};

   $description =~ s/^\s+//;       # trim leading  white space
   $description =~ s/\s+$//;       # trim trailing white space



   print LOG "<description>\n";
   print LOG "$description";
   print LOG "\n</description>\n";

   my $items = $formdata{'R55'};
   @list = split(/,/, $items);

   foreach $value(@list) {

   $value =~ s/^\s+//;       # trim leading  white space
   $value =~ s/\s+$//;       # trim trailing white space


   #skip blanks
   if (!($value))
   {
      next;
   }

   #print LOG "\nvalue($value)\n";
   #print "<P>($key)($value)<br>";
   #print "$key, $value ";

   print LOG "<name>\n";
   print LOG "$value";
   print LOG "\n</name>\n";

}

   print LOG "\n</data>\n";
   close (LOG);
}
