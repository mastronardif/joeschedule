#!/usr/bin/perl -wT

use CGI qw(:standard escapeHTML);
require "./sch00.lib";
#use Data::Dumper;

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

my $query = new CGI;
my $html        = $query->param('htmlname') || "./lwpyahoocgi.htm";

print "Content-type: text/html\n\n";

=comment
print 'sssssssssssssssss'; 
#print Dumper($ENV); 
print "List of all environment variables:\n";
while ( my($env_name,$env_value) = each %ENV ) {
    print "\t$env_name = $env_value\n";
}
=cut

##################################
my %session = &SCH_getSession(); #
##################################
my $direcrtory = $session{dir};

#HTTP_HOST = www.joeschedule.com
#REQUEST_URI = /cgi-bin/cgi/ngfop/mypicshtml.cgi
my $uri = $ENV{REQUEST_URI} || 'wtf';
## fm 6/30/20 fix this
$uri =~ s/\?.*//;

$uri =~ s|[^/]+$||; # remove  stuff after last slash

#print "\n uri= $uri\n";

substr($direcrtory,0,2)=""; # remove the ./ from ./members/__
my $root = "http://$ENV{HTTP_HOST}$uri$direcrtory";
#print "\n root= $root\n";
#my $root = "http://www.joeschedule.com/cgi-bin/cgi/ngfop/";
#$ENV{HTTP_REFERER};
#exit(0);



my @yahooimgs;

my $imageDir = $session{dir};
opendir DIR, "$imageDir" or die "Can't open $imageDir $!";
    my @images = grep { /\.(?:png|gif|jpg|jpeg)$/i } readdir DIR;
closedir DIR;

#exit(0);
    my $mypic;
	#my $nochache = 'dummy='. time();
	foreach my $image (@images){
		$mypic = "$root$image";
		##push (@yahooimgs, $mypic);
		#$nochache = 'dummy='. time();
		#$mypic =  $mypic.'?'.$nochache;
		push (@yahooimgs, $mypic);
	}

	my $marker = "My Pics";

   ################
   # re-build html
   ################
   my @schData;

   push(@schData, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
   push(@schData, "<data>\n");

   push(@schData, "<description>\n");

   push(@schData, $marker);

   push(@schData, "\n</description>");

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

my $xmlfilename = "yahoo";
########################################
# open html file                       #
########################################
open(MSG, $html) || ErrorMessage($html);
my @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;

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

         {
            if ($marker =~ /<description>/i)
            {
               $XMLkeys = uc "<data>,<description>"
            }
            else
            {
               $XMLkeys = uc "<row>,<picture>,<pname>,<pdescription>,<name>"
            }

            my @table = &SCH_xmLRD($marker, $XMLkeys, @schData);

            ##########################################
            # Decorate                               #
            ##########################################
            @table = &decorate(@table);

            print @table;
         }

         #default
         $XMLkeys = uc "<row>,<picture>,<pname>,<pdescription>,<name>";

         $marker = "";
         $left  = 0;
         $right = 0;
         next;
      }
      if (!$left) {
         print "$lines[$x]\n";
      }
   }

  ##print @images;
   
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

