#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";
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

#my $blankSchedule = "./blank.xml";
my $blankSchedule = "blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action');
my $html = $query->param('htmlname') || "./sch3.htm";


##########################
# FM 11/23/03
# mov this calander stuff
# to the sch00.lib file.
##########################
# set default file
if (!(-e "$session{dir}$xmlfilename"))
{
   # if calander file, aka user/yyyy_mm_dd or user/Day
   my @calparts1 = split /\//, $xmlfilename;

   if (@calparts1==2)
   {
      my $root=$calparts1[0];

      my ($fn1st, $fn2nd) = &SCH_getCalFN($calparts1[1]);
      $fn1st="$root/$fn1st.xml";
      $fn2nd="$root/$fn2nd.xml";

      #########$defFile = "$fn1st.xml";

      $xmlfilename  = "$fn1st";

      if (!(-e "$session{dir}$fn1st"))
      {
         $xmlfilename = "$fn2nd";
         if (!(-e "$session{dir}$fn2nd"))
         {
            $xmlfilename = $blankSchedule;
         }
      }
   }
}


my $XMLkeys;
my @schData;
#open(MSG, $xmlfilename) || ErrorMessage($xmlfilename);
my $fn = "$session{dir}$xmlfilename";
if ($xmlfilename =~/^$blankSchedule/i)
{
   $fn = $xmlfilename;
}

open(MSG, $fn) || ErrorMessage($fn);

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
      if ($lines[$x] =~ /<filename>|<Row>|<description>|<name>|<IF_EMBEDED_XB>/i)
      {
         #$left = 1;
         $lines[$x] =~ /<(.*)>/igs;
         $left = $1;

         #$left = 1;
      }
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      if ($lines[$x] =~ /<\/\b$left\b>/i)
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
         print "$lines[$x]\n";
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


   open(MSG, "$root$fn") || ErrorMessage("$root$fn");
   my @lines = <MSG>;
   close(MSG);


   foreach my $row(@lines) {
      if ($row =~ /<\b$tag\b>(.*)<\/\b$tag\b>/igs)
      {
         $trim = $1 || "";
         $trim =~ s/^\s+//;
         $trim =~ s/\s+$//;

      
         if(-e "$session{dir}$trim")
         {
            $xfns{$trim} = $trim;

            ####################
            # keep the markup  #
            ####################
            #$trim = $row;
            #$trim =~ s/^\s+//;
            #$trim =~ s/\s+$//;
            #$xfns{$row} = $trim;
            ####################

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


      open(MSG, "$root$fn") || ErrorMessage("$root$fn");
      @lines = <MSG>;
      close(MSG);
      my $update = $pic1;
      
      #my $ff = "ASDFASDFASDF";
      #$fn =~ tr/a-z/A-Z/;    #tr/\.//;
      my $ar = $fn;
      $ar =~ tr/./_/;    #tr/\.//;


      ##$xfns{$fn} = "$ar$id";
      $xfns{$fn} = "$ar";
      ##$update =~ s/<FN>/$ar$id/;
      $update =~ s/<FN>/$ar/;

#FM 3/4/6      $update =~ s/<DIVID>/CB$id/;
$decks .= "CB$id,";
      $update =~ s/<DIVID>/CB$id/g;
      $id++;

                                                         
      # FM 12/26/03                                      
      #print ("cunt($pic2)");
      my @tableIn = &SCH_xmLRD($pic2, uc "<row>,<picture>,<name>,<time>", @lines);

      ## FM 12/28/03
      @tableIn = &SCH_xmlRemoveEmptyPics(@tableIn);
      ## FM 12/28/03

=comment
      #############################################
      # fix the it(')s a boy apostrophee problem. #
      #############################################
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
            $ln =~ /(.*?')(.*)('.*)/;
            #print("YOU(($1)($2)($3))");
            $lll = $1 || "";
            $mmm = $2 || "";
            $rrr = $3 || "";
            $mmm =~ s/'/\\'/g;
            $ln = "$lll$mmm$rrr";
         }

         $row = join('', @lines);
      }
      #############################################
=cut

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
open(MSG, "$session{dir}$fn") || ErrorMessage("$session{dir}$fn");
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

