#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";

=comment
File: .pl

Purpose: get images from yahoo w/ out the noise.

Note: FM make this more robust, to get all images from other url that don't have images off the root.

api key: AIzaSyCNnRxzuGcCyLBQY-XzhZplafnGW3HqZmc

=cut


require 5;
use strict;
use strict 'vars';

use LWP::Simple;
use HTML::TokeParser;


print "Content-type: text/html\n\n";

my @gMyParams = (
        "jsquery",
        "jswrap",
    );

my $query = new CGI;
my $jsquery = $query->param('jsquery')|| "";
my $jswrap  = $query->param('jswrap') || "";

my $url = "http://images.search.yahoo.com/search/images?ei=UTF-8&fr=sfp&p=";

###my $url = "http://images.search.yahoo.com/search/images?fr=yfp-t-501&toggle=1&cop=mss&ei=UTF-8&p=";
#my $url = "http://images.search.yahoo.com/search/images;_ylt=A9iby4e8TgJHPnIBs02JzbkF?ei=UTF-8&fr=yfp-t-501&x=wrt&js=1&ni=20&p=";
#my $url= "http://images.google.com/images?svnum=10&um=1&hl=en&q=";



$url = "$url$jsquery";

if ($jsquery=~m{http://})
{
   $url = $jsquery;

   my $qs = &buildQueryWithoutMyParams(@gMyParams);
   $url = $qs;
}

#if ($jswrap=~m/Yahoo/i)
#{
#   my $SSS = $query->url(-path_info=>1,-query=>1);
#}

my $html   = get($url) || die print "Couldn't get it! $url";

#FM 4/5/4
#my $navs;
my   $p = HTML::TokeParser->new(\$html);


#FM 8/15/4
#open(DBG, ">fuck.txt") || die print "<hr>can not open fuck.txt";

my @yahooimgs;

# Fm 10/2/7
# FM 2/1/9 while($html =~ m/(].isrc=("(.*?)"))/g)
# FM 8/26/11 
# FM 10/16/15  while($html =~ m/<img src='(.*?)' /g)
while($html =~ m/<img data-src='(.*?)' /g)
{
#my $sss=$1 || "dddddddddddd";
#  $sss =~ s/isrc/<img src=/;
  #print DBG "SHIT\n";
  #print DBG "$1\n";
  #print DBG "$2\n";
  #Fm 2/1/9 push (@yahooimgs, $3);

  my $pic = $1;
  #$pic =~ tr/\\/X/;  
  #$pic =~ s/X//g;  
  $pic =~ s/\\//g;  
  push (@yahooimgs, $pic);

  #print DBG "SHIT\n";
}


# story is everything from <!-- story --> to <!-- /story -->
my $marker;

### 9/2/6 if ($html =~ m{<div id=yschpg>(.*?)</div>}s) {
## CHEESY for now FM 9/2/6
#FM 10/2/7 if ($html =~ m{<div id=yschpg>(.*?)<div id=yschmktg>}s) {
##if ($html =~ m{<div id=yschpg>(.*?)</div>}s) {
#FM 4/29/8 if ($html =~ m{<div id=yschpg>(.*?)<div id=yschmktg>}s) {
## Fm 11/8/08 if ($html =~ m{<div id=yschpg>(.*?)<div id="yschmktg">}s) {
## Fm 9/24/9 if ($html =~ m{<div id=yschpg>(.*?)<div id="ft">}s) {

#fm 9/3/10 if ($html =~ m{<div id=yschpg>(.*?)<div id='ysmcwrap'>}s) {
if ($html =~ m{<div id=yschpg .*?>(.*?)<div id=yschnxtb>}s) {

  my $story = $1;
  # ...
  #print DBG "<div id=yschpg>\n";
  #print DBG $story;
  #print DBG "</div>\n";

  $story =~ s/\?/&/g;

#  $story =~ s/<p>/<p style = >/g;
#  $story =~ s/big>/FFFFFFFFFFFF>/g;
#  $story =~ s/<\/big>/<\/FFFFFFFF>/g;

  $story =~ s/href="/href=lwpyahoocgi.pl?jswrap=yahoo&jsquery=/g;

#  $navs .= "<a href=/cgi-bin/cgi/ngfop/lwpyahoo.pl?jswrap=yahoo&jsquery=$url>$text</a>\&nbsp;\n";



$marker = <<"END";
  <div id=yschpg>
  $story
  </div>
END
#  print DBG "$marker\n";

}
# else {
#  print DBG "No story found in the page";
#}


=cumment
#<div id=yschpg><p>

#         while (my $token = $p->get_tag("div")) {

while (my $token = $p->get_token) {
#             print DBG "<fuckyou>\n";
#             print DBG "$token->[4]\n";

        if ($token->[4] =~ m{<div id=yschpg>})
        {
             #print DBG "<you>\n";

            #$token = $p->get_token;
        
             print DBG "$token->[4]\n";
             print DBG "$token->[0]\n";
             print DBG "$token->[2]\n";
             #print DBG $p->{textify};

             print DBG $p->get_tag("div", "/div");  
             
             print DBG "</you>\n";
        }
             print DBG "</fuckyou>\n";
         }
=cut




=cumment
print DBG "<ffff>\n";
if ($p->get_tag("title")) {
             my $title = $p->get_trimmed_text;
#             print "Title: $title\n";
print DBG "$title\n";
         }
<div id=yschpg>

print DBG "<ffff>\n";
if ($p->get_tag("div")) {
             my $title = $p->get_trimmed_text;
#             print "Title: $title\n";
print DBG "FUCK($title)\n";
         }
=cut



#############################################
#############################################









    while (my $token = $p->get_tag("a")) {
             my $url = $token->[1]{href} || "-";
             my $text = $p->get_trimmed_text("/a");
#FM 8/13/04
#             if ($url =~ m{http://us.rd.yahoo.com/search/images/navbar/})
             if ($url =~ m{http://rds.yahoo.com/S=})
#FM 8/13/04
             {
               $url =~ s/\?/&/;

               #$navs .= "<a href=/cgi-bin/cgi/ngfop/lwpyahoo.pl?jswrap=yahoo&jsquery=$url>$text</a>\&nbsp;\n";
             }
    }
#FM 4/5/4

my $stream = HTML::TokeParser->new(\$html);
my %image  = ();

while (my $token = $stream->get_token) {
#print("<FUCK>$token->[1]</FUCK>\n");
   if ($token->[0] eq 'S' && $token->[1] eq 'img') {
      # store src value in %image
      #FM 4/4/04$image{ $token->[2]{'src'} }++;
      ## Fm 4/4/04
      my $hhh = (defined($token->[2]{'height'})) ? ($token->[2]{'height'}) : 0;
      my $www = (defined($token->[2]{'width'}))  ? ($token->[2]{'width'}) : 0;
      ##if ((defined($token->[2]{'height'})) && (defined($token->[2]{'width'})) )
      {
      ##if ($token->[2]{'height'} > 49 && $token->[2]{'width'} > 49)
      if ( ($hhh > 49) && ($www > 49) )
      {
         if ($token->[2]{'src'}=~ m{http://})
         {
            $image{ $token->[2]{'src'} }++;
         }
         else
         {
               #$image{ $token->[2]{'src'} }++;
               #$image{"http://www.woodlandmouse.com/fancifulfrogs/$token->[2]{'src'}" }++;
               $image{"$url$token->[2]{'src'}" }++;
         }
        ## Fm 4/4/04
      }
      }
    }
}
#print join "<br/>", image;
#FM 8/26/11 
#foreach my $pic (sort keys %image) {
#print $pic;
#}
#FM 8/26/11 

   ################
   # re-build html
   ################
   my @schData;

   push(@schData, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
   push(@schData, "<data>\n");

   push(@schData, "<description>\n");
   
   #FM 8/13/04
   ##push(@schData, $navs);
   #push(@schData, "yo! fucker you changd $navs");
   push(@schData, $marker);
   #FM 8/13/04
   push(@schData, "\n</description>");


#FM 10/2/7 foreach my $pic (sort keys %image) {
foreach (@yahooimgs) {
         push(@schData, "<row>\n");
         push(@schData, "<Picture>\n");

         #fm 10/2/7 push(@schData,  "$pic");
         push(@schData,  $_);
         
         push(@schData,  "\n</Picture>\n");
         push(@schData, "</row>\n");
   }
   push(@schData, "\n</data>");
my $XMLkeys;
#FM 9/2/6my $html="catagory1.htm";
$html="lwpyahoocgi.htm";
my $xmlfilename = "yahoo";
########################################
# open html file                       #
########################################
open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   ##Fm 11/26/08 my $marker = "";
   $marker = "";
   my $x;


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


sub buildQueryWithoutMyParams()
{
   #my $qs = &buildQueryWithoutMyParams(@MyParams);
   my(@params) = @_;

   my $retval ="";

   #my $qs ="";

   my $omit .= join(", ",@params);

   #print "<br/><STRONG>$omit</STRONG><br/>";

   $retval = $query->param($params[0]);

   my $icnt=0;
   foreach my $key ($query->param) {

      #$qs .= "<STRONG>$key</STRONG> -> ";
      #my @values = $query->param($key);
      #$qs .= join(", ",@values);
      #$qs .="<BR>\n";

      
      if ("$omit" =~ /\b$key\b/i)
      {
         #print "<br/><STRONG>omit=>$key</STRONG><br/>";
         next;
      }

      if ($icnt==0)
      {
         $retval .= "?";
      }
      else
      {
         $retval .= "&";
      }
      $icnt=1;

      $retval .= "$key=";
       #Fm $/29/8 my @values = $query->param($key);
      my $values = $query->param($key);
      $values =~ s/'//g;

      #$retval .= "@values";
      $retval .= "$values";
   }

   return $retval;

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



__END__

