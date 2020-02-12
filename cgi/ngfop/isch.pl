#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";

use strict "vars";

=comment
File: isch.pl

Purpose: , read xml convert to hml.
=cut

print "Content-type: text/html\n\n";

my $query = new CGI;

my $xmlfilename = $query->param('name') || "cblist.xml";
my $action = $query->param('action');
my $html = $query->param('htmlname') || "ileftsch.htm";
my $id = $query->param('id') || "";
my $pw = $query->param('pw') || "";

#print<<EOF;
#<i>Welcome  = $id</i><br/>
#EOF

my $authCode = &SCH_authenticate($id, $pw);
if($authCode =~ m/fail/i)
{
print <<"END";
   <p>
   <font color="#FF0000"><b>Invalid ID/Password.<br />
   Please go back and try again.
   </b></font>
   </p>
END

   exit;
}


##################################
# Get session data by db.        #
#12/17/9 my %session = &SCH_getSessionByDB($id, $pw); #
# FM taint $id!!!!!!
my $sessionID = $authCode;
my %session = ();
 %session = (
                #id => 'Bucci',
                #pw => '123456',
#                dir=> './members/Bucci/',
                dir=> ("./members/$sessionID/"),
                dirCount=> 3000,
                dirSize=> 100000000,  # 100Meg
    );
##############################################

my @dirInfo = &getDir($session{dir});

open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";


   #for my $x(0 .. $#lines) {
   foreach my $line22(@lines) {
      #if ($lines[$x] =~ /<ID\/>/i)
      if ($line22 =~ /<ID\/>/i)
      {
          $line22 =~ s/<ID\/>/$id/ig;
          #$lines[$x] =~ s/<ID\/>/$id/ig;
      }

      if ($line22 =~ /<PW\/>/i)
      {
          $line22 =~ s/<PW\/>/$pw/ig;
      }



      # get marker.
#      if ($lines[$x] =~ /<filename>|<Row>|<description>|<ChoiceBoard>|<Schedule>/i)
      if ($line22 =~ /<filename>|<Row>|<description>|<ChoiceBoard>|<Schedule>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$line22";
#          $marker = "$marker$lines[$x]";
      }

#      if ($lines[$x] =~ /<\/filename>|<\/Row>|<\/description>|<\/ChoiceBoard>|<\/Schedule>/i)
      if ($line22 =~ /<\/filename>|<\/Row>|<\/description>|<\/ChoiceBoard>|<\/Schedule>/i)
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
         print "$line22\n";
#         print "$lines[$x]\n";
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
#print "$fn<br/>";

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

