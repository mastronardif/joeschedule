#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";
=comment
File: schABA22.pl

Purpose: read xml convert to hml.
=cut

use strict 'vars';


print "Content-type: text/html\n\n";

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################

my $query = new CGI;

#my $blankSchedule = "./blank.xml";
my $blankSchedule = "blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action') || ""; 

## FM 6/29/7 my $usedir = $query->param('usedir') || ""; 
my $usedir = $query->param('usedir') || $session{dir}; 

my $html = $query->param('htmlname') || "./sch3.htm";
my $student = $query->param('student') || "";

my $swms = "";
if ($student)
{
   $swms = &SCH_SWMs_GetRows($session{dir}, $student);
}


my $XMLkeys;
my @schData;

if ($usedir =~ m/usedir\s*\(/i)
{
    $usedir =~ /\((.*)\)/igs;

   #remove leading trailing ws
    my $trim = $1 || "";
    $trim =~ s/^\s+//;
    $trim =~ s/\s+$//;
    my $pubdir = $trim;

   $session{dir} = "./members/$pubdir/";
}


my $fn = "$session{dir}$xmlfilename";
if ($xmlfilename =~/^$blankSchedule/i)
{
   $fn = $xmlfilename;
}

if ($action =~ m/fromlist\s*\(/i)
{
    $action =~ /\((.*)\)/igs;

   #remove leading trailing ws
    my $trim = $1 || "";
    $trim =~ s/^\s+//;
    $trim =~ s/\s+$//;
    my $list = $trim;


   my $DBGschData = &fromlist($list);

   @schData =  split '\n', $DBGschData;
}
else
{
   open(MSG, $fn) || ErrorMessage($fn);
   @schData = <MSG>;
   close(MSG);
}


my %xfns;


open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";
   my $tag;

   foreach my $line22(@lines) {
      # get marker.

      if (!$left)
      {
      if ($line22 =~ /<swms>|<filename>|<Row>|<description>|<name>|<IF_EMBEDED_XB>/i)
      {
         #$left = 1;
         $line22 =~ /<(.*)>/igs;
         $left = $1;

         #$left = 1;
      }
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$line22";
      }

      if ($line22 =~ /<\/\b$left\b>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
         ###############################
         # if <IF_EMBEDED_XB>          #
         ###############################
         $tag = "if_embeded_xb";
         if ($marker =~ /<\/\b$tag\b>/i)
         {
            $_ = $marker;
      
            /<\b$tag\b>(.*)<\/\b$tag\b>/igs;
      
            #remove leading trailing ws
            my $trim = $1 || "";
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;

            # get cb list box data
            ## FM 1/13/7 %xfns = &getEcbData($trim, $session{dir}, $xmlfilename, "MK_LISTBOX");
            %xfns = &getEcbData($trim, $session{dir}, "FMxmlfilename", "MK_LISTBOX");

            $marker = "";
         }
         
         # 4/20/8
         ###############################
         # if <SWMS>                   #
         ###############################
         $tag = "SWMs";
         if ($marker =~ /<\/\b$tag\b>/i)
         {
            $_ = $marker;
      
            /<\b$tag\b>(.*)<\/\b$tag\b>/igs;    

            #remove leading trailing ws
            my $trim = $1 || "";
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;

            $trim =~ s/<SWMS>/$swms/igs;

            print $trim;
            $marker = "";
         }
         # 4/20/8

         ###############################
         # if <FILENAME>               #
         ###############################
         $tag = "filename";
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

            $marker = "";
         }
         else
         {
            $XMLkeys = uc "<row>,<time>,<picture>,<pname>,<pdescription>,<name>";
            if ($marker =~ /<description>/i)
            {
               $XMLkeys = uc "<data>,<description>";
            }

            if($marker ne "")
            {
               my @table = &SCH_xmLRD($marker, $XMLkeys, @schData);
               #print @table;
               # remove empty img's
               @table = &SCH_xmlRemoveEmptyPics(@table);

               @table = &expandXMLsToListBoxs(@table);

               print @table; 
            }

            $marker = "";
         }

         #default
         $XMLkeys = uc "<row>,<time>,<picture>,<pname>,<pdescription>,<name>";

         $marker = "";
         $left  = 0;
         $right = 0;
         next;
      }
      if (!$left) {
         print "$line22\n";
      }
   }


sub getEcbData()
{
   #%xfns = &getEcbData($trim, $session{dir}, $xmlfilename, "MK_LISTBOX");

   my($pic, $root, $fn, $tag) = @_;
   my %xfns;
   my $decks;
#   print $pic;

if ($fn =~/^$blankSchedule/i)
{
   $root = "";
}



######################################################
my $PICTURE1 = $pic;
my $trim;
my $pic1;
my $pic2;
my $pic3;
######################################################

   my @lines = @schData;

   foreach my $row(@lines) {
      if ($row =~ /<\b$tag\b>(.*)<\/\b$tag\b>/igs)
      {
         $trim = $1 || "";
         $trim =~ s/^\s+//;
         $trim =~ s/\s+$//;

      
         if(-e "$session{dir}$trim")
         {
            $xfns{$trim} = $trim;
            $xfns{$trim} = $trim;
         }
      }
   }

   if (!%xfns)
   {

print << "END";
<input type="hidden" NAME="Decks" value=""/>
END

      return %xfns;
   }


   #################
   # list of ebeds #
   # xlat fn's     #
   #################
   my $id = "0";
   foreach my $fn(keys(%xfns)) {

      #####################
      #####################
      # sw on file prefix #
      #####################
      if (10)
      {

######################################################
   my $ebedtag = "IF_EMBEDED_SCH";

   if ($fn=~/^cb/i)
   {
      $ebedtag = "IF_EMBEDED_CBS";
   }

   my $pic111 = $PICTURE1; #$pic;

   $pic111 =~ /<\b$ebedtag\b>(.*)<\/\b$ebedtag\b>/igs;

   $trim = $1 | "";
   $pic111 = $trim;

   $pic111 =~ /(.*)(<row>.*<\/row>)(.*)/igs;
   $pic1 = $1 || "";
   $pic2 = $2 || "";
   $pic3 = $3 || "";

######################################################
      }


      #####################
      #####################
      #####################


      open(MSG, "$root$fn") || ErrorMessage("getEcbData $root$fn");
      @lines = <MSG>;
      close(MSG);

      my $update = $pic1;
      my $ar = $fn;
      $ar =~ tr/./_/;    #tr/\.//;


      $xfns{$fn} = "$ar";
      $update =~ s/<FN>/$ar/;

my $MLkeys = uc "<data>,<description>";
my @WWWtableIn = &SCH_xmLRD($pic1, $MLkeys, @lines);


# Relace <description>*(/description) with _________
my $fuck=$update;   ## $pic1;


$fuck =~ s/<description>.*<\/description>/@WWWtableIn/is;
$update = $fuck;

$decks .= "CB$id,";
      $update =~ s/<DIVID>/CB$id/g;
      $id++;
                                                         
      my @tableIn = &SCH_xmLRD($pic2, uc "<row>,<picture>,<name>,<time>", @lines);

      @tableIn = &SCH_xmlRemoveEmptyPics(@tableIn);

      print ($update);
      print (@tableIn);
      print ("\n$pic3\n");
   }


   # .js
   #gxmldata1= new Array(_AcbList2, _AcbList2, _AcbList2);
   #gxmls1= new Array("fms.xml","cbList2","cbList3");

   my $gxmls = "gxmldata=new Array(";
   foreach my $fn(values(%xfns)) {
      $gxmls .= "$fn,";
   }
   chop($gxmls);
   $gxmls .= ");\n";
##FM 3/8/6      print $gxmls;

   $gxmls = "gxmls=new Array(";
   foreach my $fn(keys(%xfns)) {
      $gxmls .= "\"$fn\",";
   }
   chop($gxmls);
   $gxmls .= ");\n";
##FM 3/8/6      print $gxmls;

   
   $gxmls = "";
   foreach my $fn(keys(%xfns)) {
      $gxmls .= "$fn,";
   }
   chop($gxmls);
   chop($decks);

print << "END";
<input type="hidden" NAME="xmlDecks" value="$gxmls"/>
<input type="hidden" NAME="Decks" value="$decks"/>
END
   return %xfns;

}

sub listboxML()
{
   my($fn, $DivRowID) = @_;

my $results;

############################
# default first list item.
{
my @xmlData;
open(MSG, "$session{dir}$fn") || ErrorMessage("listboxML $session{dir}$fn");
@xmlData = <MSG>;
close(MSG);

my $pic1 = <<"END";
<!-- selection box -->
<div id="<CBNAME_N>">
			<table border="1" width = "100%" cellpadding="3" height="1">
			<tr onClick    ="bob4a('<FILENAME>', '<CBNAME_N>', '<DIVROW_N>');">
				<td width = "90%" >
END

my $pic2 = <<"END";
<row>
<div id="<DIVROW_N>">
<IF_PICTURE> 
				<IMG NAME="I550" input border="0" src="<PICTURE>" width="105" height="97" type="image">
</IF_PICTURE>
            <NAME>
</row>
END

my $pic3 = <<"END";
<div>
				</td>
				<td width = "10%" >
				<img src="/darrow3.gif" ALT="choice board" name=Warning00 border="0">
				</td>
		    </tr>
			</table>
</div>
<!-- selection box -->
END


my @tableIn = &SCH_xmLRD($pic2, uc "<row>,<picture>,<name>", @xmlData);
#Fm 3/1/6 @tableIn[0] = &SCH_xmlRemoveEmptyPics($tableIn[0]);
$tableIn[0] = &SCH_xmlRemoveEmptyPics($tableIn[0]);

$results = "$pic1$tableIn[0]$pic3";
}
############################


$results =~ s/<FILENAME>/$fn/igs;

$results =~ s/<DIVROW_N>/divRow$DivRowID/igs;
$results =~ s/<CBNAME_N>/CBNAME$DivRowID/igs;
return $results;

}

sub expandXMLsToListBoxs()
{

   my(@rows) = @_;
            
   my @results;

   ##################
   my $DivRowID = 1;
   ##################


   foreach my $row(@rows) {
      if($row =~ /<tr>/igs)
      {
      if($row =~ /<MK_LISTBOX>(.*)<\/MK_LISTBOX>/igs)
      {
         my  $trim = $1 || "";
         $trim =~ s/^\s+//;
         $trim =~ s/\s+$//;
         #print("<!--MK_LISTBOX = ($trim) -->");

         #replace if exists
         if($xfns{$trim})
         {
            my $listbox = &listboxML($trim, $DivRowID++);
            $row =~ s/<MK_LISTBOX>(.*)<\/MK_LISTBOX>/$listbox/ig;
         }
         
      }
      }

      push(@results, $row);
   }

   return @results;
}


sub ErrorMessage {
   my $fn = shift(@_);
        print "Content-type: text/html\n\n";
        print "The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        #exit;
}

sub fromlist()
{
   my($list) = @_;
   my @results;

my @files = split /\,/, $list;

my $left  = "<row><name>\n<MK_LISTBOX>";
my $right = "<\/MK_LISTBOX>\n<\/name>\n<\/row>\n";

my $text = "$left";
   $text .= join "$right$left", @files;
   $text .= "$right";

my $xml = <<"END";
<?xml version="1.0" encoding="UTF-8"?>
<data>
<description>
000 Kit - fffff
</description>
$text
</data>
END

   return $xml;
}

