#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";
use Time::Local;
use File::Find qw(finddepth);
use Cwd;

use File::Basename;
use LWP::Simple qw(get getstore);
use URI;
use URI::Escape;

use strict "vars";

#for debuging only, remove in production. BEGIN
#use CGI::Carp qw(fatalsToBrowser); 
#for debuging only, remove in production. END


=comment
File: editsch.pl

Purpose: , read xml convert to hml.
=cut

print "Content-type: text/html\n\n";

my $query = new CGI;
my $blankSchedule = "blank.xml";

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################

##############################
# get parameters from a form #
##############################

my $html        = $query->param('htmlname') || "./editschcgi.htm";
my $gStudent    = $query->param('student') || "";
my $xmlfilename = $query->param('name')    || $blankSchedule;
#my $actioncgi   = $query->param('action') || ""; # new for edit mode

my $usedir = "";
my @parts = split /,\s*/, $xmlfilename;
if (@parts == 2)
{
   $xmlfilename = $parts[0];
   $usedir = $parts[1];  
}

my $swms = "";

#if ($gStudent =~ /\.xml/) #saving
#{
#   $swms = $gStudent;
#}
#elsif (($gStudent !~ /\(.*\)/) && ($xmlfilename !~ /blank.xml/)) # reading
#{
#   $swms = &SCH_SWMs_GetRows($session{dir}, $gStudent, $xmlfilename);
#}

##########################################
# mangle the description into a filename.#
##########################################
my $description = $query->param('d0') || "";
{
## Fm wtf 2/21/19 $description =~ s/[^\w]//g;
## Fm wtf 2/21/19 $description = lc $description;
##########################################

# type = cb, sch
my $type        = $query->param('type') || "Sch";
$type = SCH_getScheduleType($type);

##################
# clean filename #
##################
$xmlfilename =~ tr/ /_/;
my @fileparts = split /\./, $xmlfilename;
$xmlfilename = "$fileparts[0].$fileparts[1]";

$usedir = $query->param('usedir') || "";
my $pubFN = "";
$usedir="usedir(Sussina)";

if ($usedir =~ m/usedir\s*\(/i)
{
    $usedir =~ /\((.*)\)/igs;

   #remove leading trailing ws
    my $trim = $1 || "";
    $trim =~ s/^\s+//;
    $trim =~ s/\s+$//;
    my $pubdir = $trim;
    $pubFN = "./members/$trim/$xmlfilename";
    
    if ($xmlfilename =~ /schs\//)
    {
      $pubFN = "./$xmlfilename";
    }
    
}

##################

my $action = $query->param('action') || "save";

open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

# set default file
my $defFile = $xmlfilename;

my $fn = "$session{dir}$xmlfilename";
if ($xmlfilename =~/^$blankSchedule/i)
{
   $fn = $blankSchedule;
}


########################################################
########################################################
if (!(-e $fn))
{
   # if calander file! user/yyyy_mm_dd or user/Day
   my @calparts1 = split /\//, $xmlfilename;
   if (@calparts1==2)
   {
      if ($calparts1[0]=~m/^schs$/i)
      {
         $fn = "$calparts1[0]/$calparts1[1]";

         $xmlfilename = "blank.xml";
      }
      else
      {
         my $root=$calparts1[0];
         my ($fn1st, $fn2nd) = &SCH_getCalFN($calparts1[1]);
         $fn1st="$root/$fn1st.xml";
         $fn2nd="$root/$fn2nd.xml";

         $defFile = "$fn1st";

         $fn = "$session{dir}$fn1st";
         if (!(-e "$session{dir}$fn1st"))
         {
            $fn = "$session{dir}$fn2nd";
            if (!(-e "$session{dir}$fn2nd"))
            {
               $fn = $blankSchedule;
            }
         }

         $xmlfilename = $defFile;

         my @parts = split /\./, $calparts1[1];

         ## FM 2/21/19 $description = "$calparts1[0] $parts[0]";
      }
   }
   
   if ($pubFN)
   {
      $fn = $pubFN;
   }
   
}
########################################################
########################################################


############################################
if ($action=~ /^save$/i)
{
   # save to file
   if ($description)
   {
   	$defFile = $xmlfilename = &saveList($session{dir}, $xmlfilename, $type);
   }

   ####################################
   # now return as if an edit request #
   ####################################
   $action = "edit";

   $fn = "$session{dir}$xmlfilename";
}
############################################


########################
#                      #
# XML Data             #
#                      #
########################
my $XMLkeys;
my @schData;
my $bStudentFile = 0;
if ($fn =~ /Students.xml/)
{
   $bStudentFile = 1;
   if (!(-e "$fn"))
   {
      $xmlfilename = "Duck.xml"; ##$query->param('name')    || $blankSchedule;

      $fn = $blankSchedule;;
   }
}

open(MSG, $fn) || ErrorMessage("$xmlfilename");
@schData = <MSG>;
close(MSG);

if ($bStudentFile)
{
   #Initially set description to Students.
   my $FMlines =  join ' ', @schData;
   $FMlines =~ s/Enter name here!/Students/igs;
   @schData =  split '\n', $FMlines;
}

if ($action=~ /^delete$/i)
{
   &SCH_deleteFile($xmlfilename);
}

   my $left   = 0;
   my $right  = 0;
   my $marker = "";
   my $blank  = "empty";

   for my $x(0 .. $#lines) {
      # get marker.
      if ($lines[$x] =~ /<swms>|<Reward>|<appendblanks>|<filename>|<Row>|<description>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      if ($lines[$x] =~ /<\/swms>|<\/Reward>|<\/appendblanks>|<\/filename>|<\/Row>|<\/description>/i)
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
            my $trim = ($1) || "";
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;
            
            $trim =~ s/<FILENAME>/$defFile/igs;
            print($trim);
         }
         else
         {
            if ($marker =~ /<description>/i)
            {
               $XMLkeys = uc "<data>,<description>";

               my @table;
               if ($description)
               {
my $bbb = <<HERE;
<data>
<description>
$description
</description>
</data>
HERE
               @table = &SCH_xmLRD($marker, $XMLkeys, $bbb);
}
else
{
               @table = &SCH_xmLRD($marker, $XMLkeys, @schData);
}
               print @table;
            }
            if ($marker =~ /<row>/i)
            {
               $XMLkeys = uc "<row>,<time>,<picture>,<name>,<pname>";
               my @table = &SCH_xmLRD($marker, $XMLkeys, @schData);
               print @table;
            }

           # if ($marker =~ /<REWARD>/i)
            #{
             #  $XMLkeys = uc "<reward>,<picture>,<name>";
              # my @table = &SCH_xmLRD($marker, $XMLkeys, @schData);
               #print @table;
            #}
         }

         # append blank rows if edit
         if ($action=~ /^edit$/i)
         {
            my $tag = "appendblanks";
            if ($marker =~ /<\/\b$tag\b>/i)
            {
               my @defaultData;
               open(MSG, $blankSchedule) || ErrorMessage($blankSchedule);
               @defaultData = <MSG>;
               close(MSG);

               $XMLkeys = uc "<row>,<time>,<name>";
               my @table = &SCH_xmLRD($marker, $XMLkeys, @defaultData);
               print @table;
            }
         }

         #default
         $XMLkeys = uc "<row>,<time>,<name>";

         $left  = 0;
         $right = 0;
         $marker = "";
         next;
      }

      if (!$left) {
         print "$lines[$x]\n";
      }
   }
}
###################################################################
###################################################################

sub ErrorMessage {
   my $fn = shift(@_);
        print "Content-type: text/html\n\n";
        print "FM, The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        exit;
}


sub saveList()
{
   #$xmlfilename = &saveList($session{dir}, $xmlfilename, $type);
   my($root, $fn, $type) = @_;

   ###################################
   # taint check
  $root =~ /(.+)/;
  $root = $1 || "ot oh!";

   (my $retval, $fn) = &SCH_ValidateFilename($fn);
   unless($retval){ SCH_ErrorMessage("Bad filename($fn)");}

   ###################################

   my $tag = "REWARD";
   my @extras;

   &SCH_checkDir () == 1 || SCH_ErrorMessage("You reached your limit of files.");

   #fm 8/13/8 &SaveStudentWMs();

   my $LOG;
   #########################$###########
   # If a not a calander file and new get a unique file handle #
   #####################################

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
   elsif ((length $fn) && (!($fn =~/^$blankSchedule/i)) )
   {
      open (LOG, ">>$root$fn") || SCH_ErrorMessage("$fn");
   }
   else  # new file name
   {
      ($LOG, $fn )= &SCH_getUniqueFH($root, $type);
   }
   ######################


   print LOG "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
   print LOG "<data>\n";

   my $description = $query->param('d0') || "";
   $description =~ tr/"/'/;
   $description =~ s/'/&\#39;/g;

   $description =~ s/^\s+//;       # trim leading  white space
   $description =~ s/\s+$//;       # trim trailing white space

   print LOG "<description>\n";
   print LOG ucfirst $description;
   print LOG "\n</description>\n";

   my @pics = $query->param('HR55');

   my @rows = $query->param('R55');

   my @times = $query->param('T1');
   ###print "\@times = ".scalar(@times);   print "\@times = @times";
   
   #FM 8/8/8
   my $studentWs = "(";
   my $studentMs = "(";

   my $ii = -1;
   my $row = 0;
   foreach my $value(@rows) 
   {
      $ii++;

      $value =~ s/^\s+//;       # trim leading  white space
      $value =~ s/\s+$//;       # trim trailing white space

      #skip blanks
      ##if (!($value =~/./))
      if (!($value =~/./) && !($pics[$ii] =~/./))
      {
         #print "empty ";
         next;
      }

      # special item Reward, ABC, Token, Social Story.....
      #if ($value =~ /<\b$tag\b>(.*)<\/\b$tag\b>/igs)
      #<REWARD>
      if ($times[$ii] =~ /Reward/i)
      {
         #push(@extras, $value);
my $reward = <<"END";         
<Reward><Time>Reward</Time><Picture>$pics[$ii]</Picture><Name>$value</Name></Reward>
END
         push(@extras, $reward);
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
         # copy, replace.
         my $newpic = "";
         if ($root !~ m/members\/Demo/)
         {
            $newpic = &SCH_copyPic($root, $pics[$ii]);
            if ($newpic) {
               $pics[$ii] = $newpic;
            }
         }

         print LOG "<picture>$pics[$ii]</picture>\n";
      }

      print LOG "<name>\n";
      print LOG "$value";
      print LOG "\n</name>\n";
      print LOG "</row>\n";
      


      $row++;

   }
   
#FM

 my $count = ($studentMs =~ tr/,//);
 
my $all = "";
if ( $row && ($row == $count) )
{
   $all = "(ALL Mastered)";
}

#print("<FM> \$all = $all </FM>");
#print("<FM> \$row = $row </FM>");
#print("<FM> \$count = $count </FM>");



#fm

chop $studentWs;
$studentWs .= ")";
if ($studentWs eq ")")
{
    #$studentWs = "()"; #empty set.
    $studentWs = "";
}

chop $studentMs;
$studentMs .= ")";
if ($studentMs eq ")")
{
    $studentMs = ""; #"()"; #empty set.
}

   #################
   # print Extras. #
   #################

   $"="\n";

   print LOG "@extras";

   print LOG "\n</data>\n";
   close (LOG);
   
   if ($studentWs)
   {
      $studentWs = "w$studentWs";
   }
   if ($studentMs)
   {
      $studentMs = "m$studentMs";
   }

   return $fn;
}

sub SCH_copyPic()
{
   my($root, $row) = @_;

   # Safety check
   if ($row !~ m/http:/i)
   {
      return "";
   }   
   #

  # taint check
  $root =~ /(.+)/;
  $root = $1 || "ot oh!";

  $row =~ /(.+)/;
  $row = $1 || "ot oh!";

   my $LocalPicRoot = "/cgi/ngfop/";
   my $uu = URI->new($query->url());

   my $trim = $row;
   $trim =~ s/^\s+//;
   $trim =~ s/\s+$//;
#1/7/7
my($directory, $httpfilename) = $trim =~ m/(.*http:\/\/)(.*)$/;
$httpfilename = "http://$httpfilename";
$httpfilename = uri_unescape($httpfilename);
$trim = $httpfilename;
#1/7/7


   my $fn = basename($trim);

   # Unescape chars
   $fn =~ s/%/_/g;
   $fn =~ s/\$/1/g;
   $fn =~ s/\?/2/g;

   if ( $fn ) {

      if ($fn ne "")
      {
         my $u3;
         $u3 = URI->new($trim, "http");

         if (URI::eq($uu->host, $u3->abs($uu)->host))
         {
            return "";
         }


         # Copy pic to 
         my $retval = getstore("$trim", "$root$fn");

         if (200 == $retval)
         {
            my $pic = "$root$fn";
            $pic =~ s/\.\//$LocalPicRoot/;

            return $pic;
         }
      }
   }
   return "";

}  # end func

