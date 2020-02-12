#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";

use strict "vars";

=comment
File: left02.pl

Purpose: , read xml convert to hml.
=cut

print "Content-type: text/html\n\n";

my $query = new CGI;

my $xmlfilename = $query->param('name') || "cblist.xml";
my $action = $query->param('action');
my $html = $query->param('htmlname') || "left02.htm";

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################

$session{dir} =~ /\/members\/(.*)\//;
my $id =  $1 || "____";

my @dirInfo =  &getDir($session{dir});

open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";


   for my $x(0 .. $#lines) {

      if ($lines[$x] =~ /<ID\/>/i)
      {
         $lines[$x] =~ s/<ID\/>/$id/ig;
      }

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
   my $dir = shift(@_);

   my @col2;
   my $fn;
   my $removeMe1=1;

#   opendir(DIR, ".");
   opendir(DIR, "$dir")|| ErrorMessage($dir);
   my @logfiles= readdir(DIR);
   closedir(DIR);

   if (@logfiles) 
   {
      foreach $fn(@logfiles) 
      {
         # Filter *.htm, .html, .cgi, .pl
         unless ($fn =~ /\.xml$/i) {$fn = ""; next;}

         my @schData;
         #open(MSG, $fn) || ErrorMessage($fn);
         open(MSG, "$session{dir}$fn") || ErrorMessage("$session{dir}$fn");
         @schData = <MSG>;
         close(MSG);

         # Check if file has a description
         my @table = &SCH_xmLRD("<Ass><DESCRIPTION></Ass>", uc "<data>,<description>", @schData);
         if(@table)
         {
         if ($table[0] =~ /./)
         {
            my $desc = "@table";

            #remove leading trailing ws
            $desc =~ s/^\s+//;
            $desc =~ s/\s+$//;
           push(@col2,"<description>\n$desc\n</description>\n<file>$fn</file>");
         }
         }
      }
   }
   
   #sort by description
   return  (sort(@col2));
}


sub getInforFromDir()
{
   #my $marker;
   #local(@col2);
   my ($marker, @col2) = @_;

   my $fn;

   foreach $fn(@col2) 
   {
      $_ = $fn;

      my $trim = "";
      my $desc = "";

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

         ####################
         #                  #
         #                  #
         #  FM remove this  #
         #  Cheese          #
         #                  #
         ####################
         if ($fn=~ /^rewards.xml|^blank.xml/i)
         {
            next;
         }
         ####################
         ####################

         my $pic = $marker;

         my $tag = ChoiceBoard;

         #if ($marker=~ /<ChoiceBoard>/i)
         if ($marker =~ /<\b$tag\b>/i)
         {
            if ($fn=~ /^cb/i)
            {
               ## FM 1/2/04
               #$pic =~ /<ChoiceBoard>(.*)<\/ChoiceBoard>/is;
               $pic =~ /<\b$tag\b>(.*)<\/\b$tag\b>/igs;
               $trim = $1 || "";
               $trim =~ s/^\s+//;
               $trim =~ s/\s+$//;

               $pic = $trim;

               ## FM 1/2/04
               #printf($marker, $fn, $desc);
               $pic =~ s/<FILE>/$fn/igs;
               $pic =~ s/<DESCRIPTION>/$desc/igs;
               print($pic);

               next;
            }
         }
         if ($marker=~ /<Schedule>/i)
         {
            # skip choice boards.
            if ($fn=~ /^cb/i)
            {
               next;
            }
            $pic =~ s/<FILE>/$fn/igs;
            $pic =~ s/<DESCRIPTION>/$desc/igs;
            print($pic);
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

