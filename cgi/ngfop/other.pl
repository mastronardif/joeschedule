#!/usr/bin/perl

use CGI qw(:standard escapeHTML);
#require "/usr/home/mastronardif/dev/perl/cgi/subparseform.lib";

=comment
File: other.pl

Purpose: read cb xml convert to hml.
=cut

print "Content-type: text/html\n\n";

$query = new CGI;
#&Parse_Form;
#print keys(%formdata);
#print values(%formdata);

my $blankSchedule = "blank.xml";
#my $xmlfilename = $formdata{'name'} || "blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
#my $action = $formdata{'action'};
my $action = $query->param('action');

#my $htmfilename = $formdata{'htmlname'};
my $htmfilename = $query->param('htmlname');

# sort keys(%formdata);
#@sortedkeys = sort keys(%formdata);
#print @sortedkeys;
#print "<br>";
#return;

if ($action=~ /^new$/i)
{
   $xmlfilename = "sch101.xml";
}

if ($action=~ /^pdf$/i)
{

   if (-r $xmlfilename)
   {
      print "<font size=\"1\"></code>/fop.sh -xsl 2cols.xsl -xml $xmlfilename  -pdf $xmlfilename.pdf</code></font>";
      system "./fop.sh -xsl 2cols.xsl -xml $xmlfilename  -pdf $xmlfilename.pdf";
      print "<hr></hr>";
      print "You can view $xmlfilename.pdf w/ Acrobat Reader if you like<br>";
      printf ("<A HREF=\"/cgi/ngfop/%s\">%s</A><br>", "$xmlfilename.pdf", "$xmlfilename.pdf");
   }
   else
   {
      print "xmlfilename($xmlfilename) don't exist's";
   }
   
   return;
}


open(MSG,"./$htmfilename") || ErrorMessage("./$htmfilename");
 @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";


   for $x(0 .. $#lines) {

=comment
      # get marker.
      if ($lines[$x] =~ /<filename>|<Row>|<description>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      if ($lines[$x] =~ /<\/filename>|<\/Row>|<\/description>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
         &readxml($marker, $xmlfilename);

      if ($lines[$x] =~ /<\/Row>/i)
      {

      $appendmarker = $marker;
      $appendmarker =~ s/r%d/sr%d/g;
&readxml($appendmarker, "sch101.xml");
}

         $left  = 0;
         $right = 0;
         next;
      }
=cut
      if (!$left) {
         print "$lines[$x]\n";
      }
   }



sub readxml()
{
   my $a1 = shift(@_);
   my $fn = shift(@_);

   #add filename
   my @fnxml = ("<filename>", "$xmlfilename", "</filename>");

   open(MSG, $fn) || die print "<hr>can not open $fn";
   my @lines = <MSG>;
   close(MSG);
   @lines = (@lines, @fnxml);


   my $ii     = 0;
   my $left   = 0;
   my $right  = 0;
   my $marker = "";

   my $mm = "";
   my $tag = "";

   $_ = $a1;
   if (/<filename>(.*)<\/filename>/igs)
   {
      $tag = "filename";
   }


   if (/<row>(.*)<\/row>/igs)
   {
      $tag = "Name";
   }

   if (/<description>(.*)<\/description>/igs)
   {
      $tag = "description";
   }

   $a1 = $1;

   for $x(0 .. $#lines) {

      # get marker.
      if ($lines[$x] =~ /<\b$tag\b>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }
      
      if ($lines[$x] =~ /<\/\b$tag\b>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
         #print "<mark>\n$marker\n</mark>";

         $_ = $marker;
      
         /<\b$tag\b>(.*)<\/\b$tag\b>/igs;
      
         $trim = $1;
         $trim =~ s/^\s+//;
         printf($a1, $ii, $trim, $ii);
         $ii++;

      
         $left  = 0;
         $right = 0;
         $marker = "";
      }
   }
}


sub ErrorMessage {
   my $fn = shift(@_);
        print "Content-type: text/html\n\n";
        print "The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        #exit;
}

