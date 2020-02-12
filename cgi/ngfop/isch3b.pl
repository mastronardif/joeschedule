#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";
=comment
File: sch3.pl

Purpose: read xml convert to hml.
=cut

use strict 'vars';


print "Content-type: text/html\n\n";

my $query = new CGI;

my $blankSchedule = "blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action');
my $html = $query->param('htmlname') || "./sch3.htm";
my $id = $query->param('id') || "";
my $pw = $query->param('pw') || "";

my %session = ();


#=comment
if ($id =~ /\.\.\/schs/)
{
 if ( $id )
 {
  %session = (
                dir=> ("./schs/")
#                dir=> ("$id/")
    );
 }
}
else
#=cut

{
my $authCode = &SCH_authenticate($id, $pw);
if($authCode =~ m/fail/i)
{
print <<"END";
   <p>
   <font color="#FF0000"><b>($authCode) Invalid ID/Password.<br />
   Please go back and try again.
   </b></font>
   </p>
END

   exit;
}

##################################
# Get session data by db.        #
#11/14/9 my %session = &SCH_getSessionByDB($id, $pw); #
# FM taint $id!!!!!!
my $sessionID = $authCode;
####my %session = ();
 %session = (
                #id => 'Bucci',
                #pw => '123456',
#                dir=> './members/Bucci/',
                dir=> ("./members/$sessionID/"),
                dirCount=> 3000,
                dirSize=> 100000000,  # 100Meg
    );
##############################################
}

my $XMLkeys;
my @schData;
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

#print "EEEE  @lines\n GGGGG\n";
#foreach my $ll(@lines) {
#print "HHH $ll KKK\n";
#}

   #for $x(0 .. $#lines) {
foreach my $line22(@lines) {

      # get marker.
      if (!$left)
      {
      #if ($lines[$x] =~ /<filename>|<Row>|<description>|<name>|<IF_EMBEDED_XB>/i)
      if ($line22 =~ /<filename>|<Row>|<description>|<name>|<IF_EMBEDED_XB>/i)
      {
         #$left = 1;
         #$lines[$x] =~ /<(.*)>/igs;
         $line22 =~ /<(.*)>/igs;
         $left = $1;
      }
      }

      if ($left && !$right)
      {
          # get marker.
          #$marker = "$marker$lines[$x]";
          $marker = "$marker$line22";
      }
      #if ($lines[$x] =~ /<\/\b$left\b>/i)
      if ($line22 =~ /<\/\b$left\b>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
         ###############################
         # if <IF_EMBEDED_XB>          #
         ###############################
###         $tag = "if_embeded_cbs";
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

            #%xfns = &getEcbData($trim, "", $xmlfilename, "MK_LISTBOX");

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
         #print "$lines[$x]\n";
         print "$line22\n";
      }
   }


sub getEcbData()
{
   #%xfns = &getEcbData($trim, $session{dir}, $xmlfilename, "MK_LISTBOX");

   my($pic, $root, $fn, $tag) = @_;
   my %xfns;

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

      #print("FUCK($fn)");

      ##$xfns{$fn} = "$ar$id";
      $xfns{$fn} = "$ar";
      ##$update =~ s/<FN>/$ar$id/;
      $update =~ s/<FN>/$ar/;

      $update =~ s/<DIVID>/CB$id/;
      $id++;

                                                         
      # FM 12/26/03                                      
      #print ("cunt($pic2)");
      my @tableIn = &SCH_xmLRD($pic2, uc "<row>,<picture>,<name>,<time>", @lines);

      ## FM 12/28/03
      @tableIn = &SCH_xmlRemoveEmptyPics(@tableIn);
      ## FM 12/28/03


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
      }
      #############################################


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
			<table border="0" width = "100%" cellpadding="3" height="1">
			<tr onClick    ="bob4a('<FILENAME>', '<CBNAME_N>', '<DIVROW_N>');">
				<td width = "90%" >
END

my $pic2 = <<"END";
<row>
<div id="<DIVROW_N>">
<IF_PICTURE> 
<IMG NAME="I550" border="0" src="<PICTURE>" width="105" height="97" type="image"> 
</IF_PICTURE>
            <NAME>
</row>
END

my $pic3 = <<"END";
 <div> 
		    </tr>
			</table>
</div>
<!-- selection box -->
END


my @tableIn = &SCH_xmLRD($pic2, uc "<row>,<picture>,<name>", @xmlData);
# FM 3/19/6 @tableIn[0] = &SCH_xmlRemoveEmptyPics($tableIn[0]);
## FM 2/6/7 $tableIn[0] = @tableIn[0] = &SCH_xmlRemoveEmptyPics($tableIn[0]);
#print <<END;
#<FM_DEBUG>
#@tableIn
#</FM_DEBUG>
#END

############## FM 11/29 $tableIn[0] = &SCH_xmlRemoveEmptyPics($tableIn[0]);
@tableIn = &SCH_xmlRemoveEmptyPics(@tableIn);

#print <<END;
#<FM_DEBUG 2>
#@tableIn
#</FM_DEBUG 2>
#END

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

