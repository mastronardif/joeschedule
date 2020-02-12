#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";
=comment
File: editabasch.pl


Purpose: read xml convert to hml.

Debug:
http://192.168.1.101/cgi-bin/cgi/ngfop/abakitbuild.pl?htmlname=abakitcatagory1.htm&action=dir
=cut

use strict 'vars';

print "Content-type: text/html\n\n";

my $query = new CGI;

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################

my $blankSchedule = "./blank.xml";
my $xmlfilename   = $query->param('name') || $blankSchedule;
my $actionFFF        = $query->param('actionFFF') || "";
my $html          = $query->param('htmlname') || "editabasch.htm"; #"./sch3.htm";

my $beenhere      = $query->param('beenhere') || "";

my $picRoot       = "/cgi/ngfop/pics/";

my $type        = $query->param('type') || "Sch";
$type = SCH_getScheduleType($type);

##################
# clean filename #
##################
$xmlfilename =~ tr/ /_/;
my @fileparts = split /\./, $xmlfilename;
$xmlfilename = "$fileparts[0].$fileparts[1]";

# set default file
my $defFile = $xmlfilename;

my $fn = "$session{dir}$xmlfilename";
if ($xmlfilename =~/^$blankSchedule/i)
{
   $fn = $blankSchedule;
}

# FM 12/16/06
############################################
=comment
print("actionFFF = [$actionFFF]");
if ($actionFFF=~ /^save$/i)
{
# save to file
print("<br>");
print("!1 actionFFF = [$actionFFF]");
print("<br>");
print("filename = [$xmlfilename]");
print("<br>");
 }
=cut
if(1==1)#if ($xmlfilename =~/^$blankSchedule/i)
{
   if ($actionFFF =~ /^save$/i)
   { 
      $defFile = $xmlfilename = &SCH_saveList($session{dir}, $xmlfilename, $type);

#FM 12/24/6 $actionFFF = "newSHit";
#FM 12/24/6 print("!2 actionFFF = [$actionFFF]");
   }

####################################
# now return as if an edit request #
####################################
#$action = "edit";


# set default file
#my $defFile = $xmlfilename;
#print($defFile);
#exit;

my $fn = "$session{dir}$xmlfilename";
if ($xmlfilename =~/^$blankSchedule/i)
{
   $fn = $blankSchedule;
}

}
else
{
#print("---- [$action]");
$actionFFF = "dir";
}

# FM 12/16/06

my $XMLkeys;
my @schData;
#open(MSG, $xmlfilename) || ErrorMessage($xmlfilename);
#@schData = <MSG>;
#close(MSG);

             

# FM 12/10/06

##************************************
# directory to ___xml info.
my @dirInfo =  &getDir($session{dir});
#print "<FFFF>\n @dirInfo </FFF>\n";

#Cheese for now
# 
my $xmdirInfo =  join ' ', @dirInfo;
#print "<hhh>\n $xmdirInfo </hhh>\n";

#$xmdirInfo =~ s/<description>/<ROW><description>/igs;
#$xmdirInfo =~ s/description>/NAME>/igs;
#$xmdirInfo =~ s/<\/picture>/<\/picture>\n<\/ROW>\n/igs;

#print "$xmdirInfo\n";
#print "<hhh>\n $xmdirInfo </hhh>\n";


@schData =  split '\n', $xmdirInfo;

##************************************


# FM 12/10/06


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

      # FM 12/22/04

      if ($lines[$x] =~ /<!-- hidden shits begin -->/i)
      {
   if ($actionFFF=~ /^save$/i)
   {
      # save to file
      #print("<br>");
      #print("actionFFF = [$actionFFF]");
      #print("<br>");
      #print("filename = [$xmlfilename]");
      #print("<br>");
   }

# 12/24/6
=comment
         my $now_string = gmtime;  # e.g., "Thu Oct 13 04:54:34 1994"
$lines[$x] = << "END"
<h1> hidden shits begin </h1>
$now_string
<br>
$actionFFF
<!-- hidden shits begin -->
<input  name=beenhere   size = "10" value="washere">
<input  name=actionFFF   size = "10" value="AAVe">
END
=cut
}

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
         if ($table[0] =~ /./)
         {
            my $desc = "@table";
            my $pic =  "";

            # FM 12/10/06

            #$qs .= join(", ",@values);
            my $text = join "\n", @schData;

            
            # get pic if there is one.
#            if (@schData =~ m{<picture>(.*?)</picture>}s) {
#            if ($text =~ m{<picture>(.*)</picture>}igs) {
            if ($text =~ /<picture>(.*?)<\/picture>/igs) {
               $pic =  $1 || "none";
            #remove leading trailing ws
            $pic =~ s/^\s+//;
            $pic =~ s/\s+$//;
            }


            # FM 12/10/06

            #remove leading trailing ws
            $desc =~ s/^\s+//;
            $desc =~ s/\s+$//;

           push(@col2,"\n<ROW>\n");

           push(@col2,"<pdescription>\n$desc\n</pdescription>\n<TIME>$fn</TIME>");
           if ($pic =~/./)
           {
               push(@col2,"\n<picture>\n$pic\n</picture>\n");
           }
           push(@col2,"</ROW>\n");

         }
      }
   }
   
   #sort by description
#FM 12/10/06   return  (sort(@col2));
   return  (@col2);
}

sub getInforFromDir22()
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

#FM 12/16/06
sub SCH_saveList()
{
   my($root, $fn, $type) = @_;

   my @rows = $query->param('R55');
   my @pics = $query->param('HR55');
   my $ii = -1;
   my $bHasArow=0;
   if (@rows)
   {
      foreach my $value(@rows) 
      {
         $ii++;
         $value =~ s/^\s+//;       # trim leading  white space
         $value =~ s/\s+$//;       # trim trailing white space

         #print ("<abr>");
         #print ($value) ;
         #print ("</abr>");


         if (!($value =~/./) && !($pics[$ii] =~/./))
         {
            next;
         }
         $bHasArow=1;
         last;

      }
   }
   if ($bHasArow==0)
   {
      return $fn;
   }


   ###################################
   # taint check
  $root =~ /(.+)/;
  $root = $1 || "ot oh!";

   (my $retval, $fn) = &SCH_ValidateFilename($fn);
   unless($retval){ SCH_ErrorMessage("Bad filename($fn)");}

   #print ("filename($fn)");


   ###################################

   my $tag = "REWARD";
   
   ##### FM 12/16my @extras;

##Fm 11/26/03   
   SCH_checkDir () == 1 || SCH_ErrorMessage("You reached your limit of files.");
##Fm 11/26/03   



   # FM 1/6/4 open (LOG, ">$fn") || &ErrorMessage($fn);
   my $LOG;

   ##########################
   # if cal or file exists! #
   ##########################
   if ( (($fn =~ tr/\//\//) == 1) || (-e "$root$fn"))
   {
      my $fname = "$root$fn";
      #$fname =~ /(.+)/;
      #$fname = $1 || "ot oh!";

      open (LOG, ">$fname") || &ErrorMessage("$fn");
   }
   else  # new file name
   {
      ($LOG, $fn )= &SCH_getUniqueFH($root, $type);
   }



   ######################


   print LOG "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
   print LOG "<data>\n";


   my $description = $query->param('d0') || "";
   # FM 1/26/04 replace " and '
   $description =~ tr/"/'/;
   $description =~ s/'/&\#39;/g;
   # FM 1/26/04

   $description =~ s/^\s+//;       # trim leading  white space
   $description =~ s/\s+$//;       # trim trailing white space


   print LOG "<description>\n";
   ## FM 1/4/4
   #print LOG "$description";
   print LOG ucfirst $description;
   ## FM 1/4/4
   print LOG "\n</description>\n";

   ##my @pics = $query->param('HR55');


   ##my @rows = $query->param('R55');

   my @times = $query->param('T1');

   my $ii = -1;
   foreach my $value(@rows) 
   {
      $ii++;

      $value =~ s/^\s+//;       # trim leading  white space
      $value =~ s/\s+$//;       # trim trailing white space

      #skip blanks
      ##if (!($value =~/./))
      if (!($value =~/./) && !($pics[$ii] =~/./))
      {
         next;
      }

      # special item Reward, ABC, Token, Social Story.....
      #if ($value =~ /<\b$tag\b>(.*)<\/\b$tag\b>/igs)
      #<REWARD>
#print LOG "FUCK($time[$ii])";
      if ($times[$ii] =~ /Reward/i)
      {
         #push(@extras, $value);
my $reward = <<"END";         
<Reward><Time>Reward</Time><Picture>$pics[$ii]</Picture><Name>$value</Name></Reward>
END
         # FM 12/16 push(@extras, $reward);

         next;
      }


      print LOG "\n<row>";

      if (($times[$ii] =~ /.+/))
      {
         print LOG "\n<time>$times[$ii]</time>\n";
      }

      $pics[$ii] =~ s/^\s+//g;       # trim leading  white space
      $pics[$ii] =~ s/\s+$//g;       # trim trailing white space


      if ($pics[$ii] =~ /./)
      {

      # FM 11/2/6
      # copy, replace.
      my $newpic = "";
      ##$newpic = &SCH_copyPic("$session{dir}", $pics[$ii]);
      # FM 11/4/6
      if ($root =~ m/members\/Bucci/)
      {
#FM 12/17/06      $newpic = &SCH_copyPic($root, $pics[$ii]);
      if ($newpic) {


         print "<FMDEBUG>";
         print $newpic;
         print "</FMDEBUG>";

         $pics[$ii] = $newpic;
      }
      }
      # FM 11/2/6




         print LOG "<picture>$pics[$ii]</picture>\n";
      }

      print LOG "<name>\n";
      print LOG "$value";
      print LOG "\n</name>\n";
      print LOG "</row>\n";
}

   #################
   # print Extras. #
   #################

   $"="\n";

#   print LOG "@extras";

   print LOG "\n</data>\n";
   close (LOG);

   return $fn;
}


