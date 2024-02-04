#!/usr/bin/perl -w

use CGI qw(:standard escapeHTML);
#require "sch00.lib";
require "./sch00.lib";
=comment
File: catagory.pl

Purpose: , read xml convert to hml.
=cut

print "Content-type: text/html\n\n";

$query = new CGI;

my $action = $query->param('action');
my $html = $query->param('htmlname') || "catagory.htm";

my $dirCatagory = "./pics";
my @dirInfo =  &getDir($dirCatagory);


open(MSG, $html) || ErrorMessage($html);
 @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";


   for $x(0 .. $#lines) {

      # get marker.
      if ($lines[$x] =~ /<filename>|<Row>|<description>|<ChoiceBoard>|<Schedule>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      if ($lines[$x] =~ /<\/filename>|<\/Row>|<\/description>|<\/ChoiceBoard>|<\/Schedule>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
         # make Discription, File table.
         &getInforFromDir($marker, @dirInfo);
         $left  = 0;
         $right = 0;
         $marker = "";
         next;
      }

      if (!$left) {
         print "$lines[$x]\n";
      }
   }

#######################
# 11/06/03            #
# FM fix this make it #
# faster              #
#######################
sub getDir()
{
   (my $dir) = @_;

   my @col2;
   my $fn;
   my $removeMe1=1;

#   opendir(DIR, ".");
   opendir(DIR, $dir) || ErrorMessage($dir);

#   opendir(DIR, "./pics") || ErrorMessage($dir);
   @logfiles= readdir(DIR);
   closedir(DIR);


   if (@logfiles) 
   {
      foreach $fn(@logfiles) 
      {
#print("FUCK($fn)");
         # Filter *.htm, .html, .cgi, .pl
         unless ($fn =~ /\.xml$/i) {$fn = ""; next;}
#print("FUCK($fn)");

         my @schData;
#         open(MSG, $fn) || ErrorMessage($fn);
         
         open(MSG, "$dir/$fn") || ErrorMessage("$dir/$fn");
         @schData = <MSG>;
         close(MSG);
#print("FUCK(@schData)");

         # Check if file has a description
         my @table = &SCH_xmLRD("<G><DESCRIPTION></G>", uc "<data>,<description>", @schData);

         if ($table[0] =~ /./)
         {
            $desc = "@table";

            #remove leading trailing ws
            $desc =~ s/^\s+//;
            $desc =~ s/\s+$//;
           push(@col2,"<description>\n$desc\n</description>\n<file>$dir/$fn</file>");
         }
      }
   }
   
#print("FUCK(@col2)");
   #sort by description
   return  (sort(@col2));
}


sub getInforFromDir()
{
   my $marker;
   local(@col2);
   ($marker, @col2) = @_;

#print("FUCK(@col2)");
   my $fn;

   foreach $fn(@col2) 
   {
      $_ = $fn;

      if (/<description>(.*)<\/description>/igs)
      {
         #remove leading trailing ws
         $trim = $1 || "";
         $trim =~ s/^\s+//;
         $trim =~ s/\s+$//;

         $desc = $trim;
      }
      if (/<File>(.*)<\/file>/igs)
      {
         #remove leading trailing ws
         $trim = $1 || "";
         $trim =~ s/^\s+//;
         $trim =~ s/\s+$//;

         $fn = $trim;

         my $pic = $marker;

         if ($marker=~ /<ChoiceBoard>/i)
         {

            $pic =~ /<ChoiceBoard>(.*)<\/ChoiceBoard>/igs;
            $trim = $1 || "";
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;

            $pic = $trim;

            {
               #printf($marker, $fn, $desc);
               $pic =~ s/<FILE>/$fn/igs;
               $pic =~ s/<DESCRIPTION>/$desc/igs;
               print($pic);

               next;
            }
         }
      }
   }
}


sub ErrorMessage {
   my $fn = shift(@_);
        print "Content-type: text/html\n\n";
        print "The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        exit;
}

