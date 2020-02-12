#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";

=comment
File: schnrew2.pl

Purpose: read xml convert to hml.
=cut

use strict 'vars';

print "Content-type: text/html\n\n";

my $query = new CGI;


##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################



my $blankSchedule = "./blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action');
my $html = "./schnrew.htm";



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

   my $dayfile = $2;

   my $ddd = $1;
   $ddd =~ /(.+)(\/)/igs;
   $xmlfilename = "$1/$dayfile";
}


# Key def for pictures
my $XMLkeys = uc "<Picture>,<pname>";

my @schData;
#open(MSG, $xmlfilename) || ErrorMessage($xmlfilename);
open(MSG, "$session{dir}$xmlfilename") || ErrorMessage("$session{dir}$xmlfilename");

@schData = <MSG>;
close(MSG);

open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";


   for my $x(0 .. $#lines) {

      # get marker.
      if ($lines[$x] =~ /<Reward>|<filename>|<Row>|<description>|<name>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      if ($lines[$x] =~ /<\/Reward>|<\/filename>|<\/Row>|<\/description>|<\/name>/i)
      {
         $right = 1;
      }

      #####################################################
      #                                                   #
      #####################################################
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
               $XMLkeys = uc "<data>,<description>";
               #my @table = &SCH_xmLRD($marker, $XMLkeys, @schData);
               #print @table;
            }


               if ($marker =~ /<REWARD>/i)
               {
                  $XMLkeys = uc "<reward>,<name>,<Picture>";
               }

               my @table = &SCH_xmLRD($marker, $XMLkeys, @schData);

               ##########################################
               # Decorate                               #
               ##########################################
               @table = &SCH_decorate(@table);

               ## FM 12/30/03
               # remove empty img's
               @table = &SCH_xmlRemoveEmptyPics(@table);
               ## FM 12/30/03


               print @table;
         }

         #default
         $XMLkeys = uc "<row>,<time>,<name>,<picture>";

         $marker = "";
         $left  = 0;
         $right = 0;
         next;
      }
      #####################################################
      #                                                   #
      #####################################################
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

