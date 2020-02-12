#!/usr/bin/perl -wT
use CGI qw(:standard escapeHTML);
require "./sch00.lib";
=comment
File: abakitbuild.pl
Purpose: read xml convert to hml.
Debug:
http://192.168.1.101/cgi-bin/cgi/ngfop/abakitbuild.pl?htmlname=abakitcatagory1.htm&action=dir
=cut

use strict 'vars';

my $output = "";
print "Content-type: text/html\n\n";

my $query = new CGI;

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################

my $blankSchedule = "./blank.xml";

my $xmlfilename = $query->param('name')     || $blankSchedule;
my $student     = $query->param('student')  || "";
my $action      = $query->param('action')   || "";
my $html        = $query->param('htmlname') || "abakitcategory32.htm";
my $type        = $query->param('type')     || "Sch";
my $prg         = $query->param('prg')      || ""; #prg{w,m}

my $picRoot = "/cgi/ngfop/pics/";

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

=comment
fm remove below
# FM 12/16/06
############################################
if ($action=~ /^save$/i)
{
# save to file
$defFile = $xmlfilename = &SCH_saveList($session{dir}, $xmlfilename, $type);

####################################
# now return as if an edit request #
####################################
#$action = "edit";

my $fn = "$session{dir}$xmlfilename";
if ($xmlfilename =~/^$blankSchedule/i)
{
   $fn = $blankSchedule;
}

}
FM remove above
//////////////////////////////////////////
=cut
######$action = "dir";
# FM 12/16/06

########################################
# open html file                       #
########################################
open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);
########################################
########################################

my $FMlines =  join ' ', @lines;

# Fm 3/29/9
   $FMlines =~ s/<PRG\/>/$prg/igs;
#

my $XMLkeys;
my @schData;

my $swms = "";
my @swms = ();
my @xmlWMs;
if ($student)
{
   $swms = &SCH_SWMs_GetRows($session{dir}, $student);
   my @rows =  split '\|', $swms;
   @swms =  split '\|', $swms;
   #FM 3/29/9 if ($action =~ m/AllMs/i)
   if ($prg =~ m/w|m/i)
   {
#print("\n<br>FFFF BEFORE Filter out non AllMs\n\$swms($swms)<br>\n");
      
      ##FM 8/23/8 my @rows =  split '\|', $swms;
      my $rows = "";
      
      foreach(@rows) 
      {
      if ( (!(m/w\(/i)) &&  (!(m/\(All Mastered\)/i)) )  
      {
         next;
      }
=comment
# FM 4/6/9      
         #if (!(m/All Mastered/i))
         if ($prg =~ m/w/i)   # Worinking on
         {
            if (!(m/w\(/i))   # Alvin sch69196891.xml(w(0)m(1))
            {
               next;
            }
         }
         
         if ($prg =~ m/m/i)   # Mastered
         {
            if (!(m/m\(/i))   # Alvin sch69196891.xml(w(0)m(1))
            {
               next;
            }
         }
=cut
         $rows .= $_;
         $rows .= "|";
      }
  #print("Filtered out non AllMs\n\$rows($rows)\n");
  #print("All wm's \n\@rows(@rows)\n");
      
      
      $swms =  $rows;
#print("\n<br>FFFF AFTER  Filter out non AllMs\n\$swms($swms)<br>\n");
      
      #fm 8/19/8
      # change background color, try change style sheet later fm.
      ##<body bgcolor="#FFFFFF" background="/cgi/ngfop/bg1.gif">
      ##$FMlines =~ s/\<body bgcolor="#FFFFFF"/<body bgcolor="#009966"/ig;
      #html,body{margin:0;padding:0; background-color: rgb(222,32,1)}
      #######FM 3/29/9 $FMlines =~ s/background-color: rgb\(\d+,\d+,\d+\)/background-color: rgb(102,255,153)/i;

      
      #fm 8/19/8
   }

   
   #Fm 8/18/8 @xmlWMs = ($swms =~ /( .*?xml)/ig);
   my @xmlWMs = ($swms =~ /( \w+\.xml)/ig);
   
   
#print("All wm's \n\@rows(@rows)\n");   print join('<br>',   @rows);
#print("All wm's \n\@xmlWMs(@xmlWMs)\n"); print join('<br>', @xmlWMs);

   
   my $ff;
   my $wmMark = "green";
   #Fm 8/23/8 foreach $ff(@xmlWMs)
   foreach (@rows)
   {
=comment
      if (m/Mastered/i) 
      {
         $wmMark = "green";
      }
      else
      {
         $wmMark = "red";
      }
=cut      
      /( \w+\.xml)/ig;
      $ff = $1 || "";
      
      
      $ff =~ s/^\s+//;       # trim leading  white space
      $ff =~ s/\s+$//;       # trim trailing white space
      
      # mark sWM's
      #if ($FMlines =~ s/\<!--$ff-->/<b style="color: red;">*<\/b>/ig)
      ###if ($FMlines =~ s/\<!--$ff-->/<b style="color: $wmMark;">*<\/b>/ig)
      
=comment      
Fm 3/29/9
      #if ($FMlines =~ m/\<!--$ff-->/i)
      #{
      #   # If match remove name because it is already in the hard coded list of aba programs.
      #   $swms =~ s/$ff/---/;
      #}
=cut      
   }
   
   @lines =  split '\n', $FMlines;
}

# directory to ___xml info.

my $pubdir = "./members/Sussina/";
#FM 3/29/9 if ($student && ($action =~ m/AllWs/i))
if(1==1)
{
   ##########@xmlWMs = ($swms =~ /( \w+\.xml)/ig);
   @xmlWMs = ($swms =~ /(\w+\.xml)/ig);
   #####print("All wm's \n\@xmlWMs(@xmlWMs)\n"); 
   @schData=  &getXmlInfoForSWs($session{dir}, $pubdir, @xmlWMs);
}
#if ($student && ($action =~ m/AllMs/i))
#{
#   @schData=  &getXmlInfoForSWs($session{dir}, $pubdir, @xmlWMs);
#   print("FFFF Filter out non AllMs\n\@schData(@schData)\n");
#}
else
{
   @schData =  &getDirWhere($session{dir}, $swms);
}

   my $left   = 0;
   my $right  = 0;
   my $marker = "";
   my $x;

#print<<EOF;
#<\@schData>
#@schData
#</\@schData>
#EOF
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

            ##FM 8/23/8 print $trim;
            $output .= $trim;
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
            @table = &SCH_xmlRemoveEmptyPics(@table);

            ##########################################
            # Decorate                               #
            ##########################################
            @table = &decorate(@table);

            ##FM 8/23/8 print @table;
            $output .= "@table";
         }

         #default
         $XMLkeys = uc "<row>,<time>,<picture>,<pname>,<pdescription>,<name>";

         $marker = "";
         $left  = 0;
         $right = 0;
         next;
      }
      if (!$left) {
         ##FM 8/23/8 print "$lines[$x]\n";
         $output .= "$lines[$x]\n";
      }
   }
   
# Fm 8/23/8
   # Mark sWM's
   my $wmMark = "";
   my $ff = "";
   ###print "\@swms(@swms)\n";
   foreach (@swms)
   {
      $wmMark  = "";
      #if (m/Mastered/i)      
      #if (m/m\(/i) 
      if((m/\(All Mastered\)/i))
      {
         $wmMark = "<input type=\"hidden\" name=\"PR55\" value=\"M\"><b style=\"color: green;\">* <\/b>" ###"green";
      }
      elsif (m/w\(/i) 
      {
         $wmMark .= "<input type=\"hidden\" name=\"PR55\" value=\"W\"><b style=\"color: red;\">*<\/b>"; ###"red" Working ON;
      }
      
      /( \w+\.xml)/ig;
      $ff = $1 || "";
      $ff =~ s/^\s+//;       # trim leading  white space
      $ff =~ s/\s+$//;       # trim trailing white space
      
      # mark sWM's
        #if ($FMlines =~ s/\<!--$ff-->/<b style="color: red;">*<\/b>/ig)
      ###if ($output =~ s/\<!--$ff-->/<b style="color: $wmMark;">*<\/b>/ig)
      
      $output =~ s/\<!--$ff-->/$wmMark/ig;
   }
# Fm 8/23/8   
   
#print join('<br>', @swms);
   print $output;


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
           push(@col2,"<description>\n$desc\n</description>\n<TIME>$fn</TIME>");
           if ($pic =~/./)
           {
               push(@col2,"\n<picture>\n$pic\n</picture>\n");
           }
         }
      }
   }
   
   #sort by description
#FM 12/10/06   return  (sort(@col2));
   return  (@col2);
}

sub getXmlInfoForSWs()
{
   #my @dirInfo =  &getXmlInfoForSWs($session{dir}, $pubdir, @xmlWMs);
   my($dir11, $dir22, @logfiles) = @_;
#print "GGGGGGGG <br/>$dir11 <br/>$dir22 <br/>@logfiles<br/>";   
   my @col2;
   my $fn;
   
   foreach $fn(@logfiles) 
   {
      # Filter *.htm, .html, .cgi, .pl
      my @schData;
      my $myfn="";
      if (-e "$dir11$fn")
      {
         $myfn = "$dir11$fn";
      }
      elsif (-e "$dir22$fn")
      {
         $myfn = "$dir22$fn";
      }
      
      #print "\$dir11\$fn($dir11$fn) \$myfn($myfn)\n";
      open(MSG, "$myfn") || next;
      @schData = <MSG>;
      close(MSG);

      # Check if file has a description
      my @table = &SCH_xmLRD("<Ass><DESCRIPTION></Ass>", uc "<data>,<description>", @schData);
      if ($table[0] =~ /./)
      {
         my $desc = "@table";
         my $pic =  "";

         my $text = join "\n", @schData;
            
         # get pic if there is one.
         if ($text =~ /<picture>(.*?)<\/picture>/igs) {
             $pic =  $1 || "none";
            #remove leading trailing ws
            $pic =~ s/^\s+//;
            $pic =~ s/\s+$//;
         }

         push(@col2,"\n<row>\n");

         #remove leading trailing ws
         $desc =~ s/^\s+//;
         $desc =~ s/\s+$//;
         #FM 7/24/8 push(@col2,"<description>\n$desc\n</description>\n<TIME>$fn</TIME>");
         push(@col2,"\n<Pdescription>\n$desc\n</Pdescription>\n<TIME>$fn</TIME>");
         if ($pic =~/./)
         {
            push(@col2,"\n<picture>\n$pic\n</picture>\n");
         }
         push(@col2,"\n</row>\n");
      }
   }
   
   #sort by description
   #FM 12/10/06   return  (sort(@col2));
   return  (@col2);
}

# FM 6/19/8
sub getDirWhere()
{
   #my @dirInfo =  &getDirWhere($session{dir}, $swms);
   my($dir, $where) = @_;

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
         
         # The where clause.
         unless ($where =~ /\b$fn\b/) {next;}
         #unless ($where =~ /$fn/) {next;}
         

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


            # FM 7/24/8
            push(@col2,"\n<row>\n");

            #remove leading trailing ws
            $desc =~ s/^\s+//;
            $desc =~ s/\s+$//;
           push(@col2,"<Pdescription>\n$desc\n</Pdescription>\n<TIME>$fn</TIME>");
           if ($pic =~/./)
           {
               push(@col2,"\n<picture>\n$pic\n</picture>\n");
           }
       
            # FM 7/24/8
            push(@col2,"\n</row>\n");
         }
      }
   }
   
   #sort by description
#FM 12/10/06   return  (sort(@col2));
   return  (@col2);
}
#FM 6/19/8