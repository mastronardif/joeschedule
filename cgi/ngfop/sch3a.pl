#!/usr/bin/perl -w

use CGI qw(:standard escapeHTML);
require "sch00.lib";
=comment
File: sch3.pl

Purpose: read xml convert to hml.
=cut

use strict 'vars';


print "Content-type: text/html\n\n";

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################

my $query = new CGI;

my $blankSchedule = "./blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action');
my $html = $query->param('htmlname') || "./sch3.htm";


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

   my $dayfile = $2 || "";

   my $ddd = $1 || "";
   $ddd =~ /(.+)(\/)/igs;
   $xmlfilename = "$1/$dayfile";

   ($xmlfilename) || ErrorMessage($xmlfilename);
}



my $XMLkeys;
my @schData;
#open(MSG, $xmlfilename) || ErrorMessage($xmlfilename);
open(MSG, "$session{dir}$xmlfilename") || ErrorMessage("$session{dir}$xmlfilename");

@schData = <MSG>;
close(MSG);

my %xfns;


open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";
   my $x;
   my $tag;

   for $x(0 .. $#lines) {

      # get marker.

      if (!$left)
      {
      if ($lines[$x] =~ /<filename>|<Row>|<description>|<name>|<IF_EMBEDED_CBS>/i)
      {
         #$left = 1;
         $lines[$x] =~ /<(.*)>/igs;
         $left = $1;
         #print("FUCKYOU(($lines[$x])$left)<br>");
         #print("FUCKYOU($left)<br>");

         #$left = 1;

      }
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      #if ($lines[$x] =~ /<\/filename>|<\/Row>|<\/description>|<\/name>|<\/IF_EMBEDED_CBS>/i)
      if ($lines[$x] =~ /<\/\b$left\b>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
         ###############################
         # if <IF_EMBEDED_CBS>         #
         ###############################
         $tag = "if_embeded_cbs";
         if ($marker =~ /<\/\b$tag\b>/i)
         {
            $_ = $marker;
      
            /<\b$tag\b>(.*)<\/\b$tag\b>/igs;
      
            #remove leading trailing ws
            my $trim = $1 || "";
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;

            # get cb list box data
            %xfns = &getEcbData($trim, $session{dir}, $xmlfilename, "MK_LISTBOX");

            $marker = "";
         }



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

               #print("<FUCK><br>"); 
               print @table; 
               #print("</FUCK><br>");
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
         print "$lines[$x]\n";
      }
   }


sub getEcbData()
{
   my($pic, $root, $fn, $tag) = @_;
   my %xfns;

   $pic =~ /(.*)(<row>.*<\/row>)(.*)/igs;
   my $pic1 = $1 || "";
   my $pic2 = $2 || "";
   my $pic3 = $3 || "";
   #print("\$pic1($pic1)");
   #print("\$pic2($pic2)");
   #print("\$pic3($pic3)");


   open(MSG, "$root$fn") || ErrorMessage("$root$fn");
   my @lines = <MSG>;
   close(MSG);


   my  $trim = "";
   foreach my $row(@lines) {
      if ($row =~ /<\b$tag\b>(.*)<\/\b$tag\b>/igs)
      {
         $trim = $1 || "";
         $trim =~ s/^\s+//;
         $trim =~ s/\s+$//;
      
         if(-e "$session{dir}$trim")
         {
            $xfns{$trim} = $trim;
         }
      }
   }

   if (!%xfns)
   {
      return %xfns;
   }


   # list of cb's
   my $id = "0";
   foreach my $fn(keys(%xfns)) {

      open(MSG, "$root$fn") || ErrorMessage("$root$fn");
      @lines = <MSG>;
      close(MSG);
      my $update = $pic1;
      
      #my $ff = "ASDFASDFASDF";
      #$fn =~ tr/a-z/A-Z/;    #tr/\.//;
      my $ar = $fn;
      $ar =~ tr/./_/;    #tr/\.//;

      #print("FUCK($fn)");

      $xfns{$fn} = "$ar$id";
      $update =~ s/<FN>/$ar$id/;
      $update =~ s/<DIVID>/CB$id/;
      $id++;

                                                         
      # FM 12/26/03                                      
      #print ("cunt($pic2)");
      my @tableIn = &SCH_xmLRD($pic2, uc "<row>,<picture>,<name>", @lines);

      ## FM 12/28/03
      @tableIn = &SCH_xmlRemoveEmptyPics(@tableIn);
      ## FM 12/28/03


      # fix the it(')s a boy apostrophee problem.

      ##@tableIn = &xlatMiddleApostrophees("\'", @tableIn);
      foreach my $row(@tableIn)
      {
         #s/'(.*)'/$1= s/'/F/g/eg;
         #s/'(.*)'/T/g;
         #$row =~ /'(.*)'/g;

         #$row=~/'(.*)'.*/g;
         #$row = "CC$`DD$&EE$'FF";
         #my @lines = split( /'/, $row);
         my @lines = split( /\n/, $row);

         my $lll;
         my $mmm;
         my $rrr;
         foreach my $ln(@lines)
         {
            #/'(.*)'/;
            #print ("FUCK($_)");
            $ln =~ /(.*?')(.*)('.*)/;
            #print("YOU(($1)($2)($3))");
            $lll = $1 || "";
            $mmm = $2 || "";
            $rrr = $3 || "";
            $mmm =~ s/'/\\'/g;
            $ln = "$lll$mmm$rrr";
         }

         $row = join('', @lines);
         #$row = "$1$temp$3";

         ##print join(':', @lines);
         #$row=~/'(.*)'/gs;
         #my $trim = $1 || "WhAT";
         #print("FUCK($trim)");
      }


      print ($update);
      print (@tableIn);
      print ("\n$pic3\n");

      # FM 12/26/03                                      


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
   print $gxmls;

   $gxmls = "gxmls=new Array(";
   foreach my $fn(keys(%xfns)) {
      $gxmls .= "\"$fn\",";
   }
   chop($gxmls);
   $gxmls .= ");\n";
   print $gxmls;



   return %xfns;

}

sub listboxML()
{
   my($fn, $DivRowID) = @_;

my $results;

=comment
my $results = <<"END";
<!-- selection box -->
<div id="<CBNAME_N>">
			<table border="1" width = "100%" cellpadding="3" height="1">
			<tr onClick    ="bob4a('<FILENAME>', '<CBNAME_N>', '<DIVROW_N>');">
				<td>

<div id="<DIVROW_N>">
				<IMG NAME="I550" input border="0" src="/cgi/ngfop/pics/iupset.gif" width="105" height="97" type="image">
				  select box 1 
<div>
				</td>
				<td>
				<img src="/cgi/ngfop/darrow3.gif" ALT="choice board" name=Warning00 border="0">
				</td>
		    </tr>
			</table>
</div>
<!-- selection box -->
END
=cut

############################
# default first list item.
{
my @xmlData;
open(MSG, "$session{dir}$fn") || ErrorMessage("$session{dir}$fn");
@xmlData = <MSG>;
close(MSG);

my $pic1 = <<"END";
<!-- selection box -->
<div id="<CBNAME_N>">
			<table border="1" width = "100%" cellpadding="3" height="1">
			<tr onClick    ="bob4a('<FILENAME>', '<CBNAME_N>', '<DIVROW_N>');">
				<td>
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
				<td>
				<img src="/cgi/ngfop/darrow3.gif" ALT="choice board" name=Warning00 border="0">
				</td>
		    </tr>
			</table>
</div>
<!-- selection box -->
END


my @tableIn = &SCH_xmLRD($pic2, uc "<row>,<picture>,<name>", @xmlData);
@tableIn[0] = &SCH_xmlRemoveEmptyPics($tableIn[0]);

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
=comment
=cut
      push(@results, $row);
   }

   return @results;

}



sub REMOVEME___removeEmptyPictures(@table)
{
   my(@rows) = @_;
   my @results;

   #for my $x(0 .. $#rows) {

   foreach my $row(@rows) {

      if($row =~ /<IF_PICTURE>(.*)<\/IF_PICTURE>/igs)
      {
         my  $trim = $1 || "";

         $trim =~ /src\s*=\s*"(.*?)"/i;
         my $src = $1 || "";

         if ($src =~ /\w/)
         {
            #$row = $trim;
            # remove the wrappers
            $row =~ s/<IF_PICTURE>//ig;
            $row =~ s/<\/IF_PICTURE>//ig;
         }
         else
         {
            # clear 
            $row =~ s/<IF_PICTURE>(.*)<\/IF_PICTURE>//igs;
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

