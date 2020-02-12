#!/usr/bin/perl

use CGI qw(:standard escapeHTML);

=comment
File: top.pl

Purpose: read xml convert to hml.
=cut

print "Content-type: text/html\n\n";

#&Parse_Form;
#print keys(%formdata);
#print values(%formdata);

$query = new CGI;

my $blankSchedule = "blank.xml";
#my $xmlfilename = $formdata{'name'} || "./food.xml";
 my $xmlfilename = $query->param('name') || $blankSchedule;

#my $action = $formdata{'action'};
my $action = $query->param('action');
my $html = "./top.htm";

# sort keys(%formdata);
#@sortedkeys = sort keys(%formdata);
#print @sortedkeys;
#print "<br>";
#return;


open(MSG, $html) || ErrorMessage($htm);
 @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";


   for $x(0 .. $#lines) {

      # get marker.
      #if ($lines[$x] =~ /<filename>|<Row>|<description>/i)
      if ($lines[$x] =~ /<filename>|<Row>|<description>|<name>/i)
      {
         $left = 1;
      }

      if ($left && !$right)
      {
          # get marker.
          $marker = "$marker$lines[$x]";
      }

      #if ($lines[$x] =~ /<\/filename>|<\/Row>|<\/description>/i)
      if ($lines[$x] =~ /<\/filename>|<\/Row>|<\/description>|<\/name>/i)
      {
         $right = 1;
      }
      if ($left && $right)
      {
         &readxml($marker, $xmlfilename);
         # Aug 5, 03
         $marker = "";
         # Aug 5, 03

         $left  = 0;
         $right = 0;
         next;
      }

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

   my $mkselect = 0;

   $_ = $a1;

   if (/<name>(.*)<\/name>/igs)
   {
      $tag = "Name";
   }



   if (/<filename>(.*)<\/filename>/igs)
   {
      $tag = "filename";
   }


   if (/<row>(.*)<\/row>/igs)
   {
      $tag = "Name";
      $mkselect = 1;
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
      
         #remove leading trailing ws
         $trim = $1;
         $trim =~ s/^\s+//;
         $trim =~ s/\s+$//;


         #if ($trim =~ /\.xml$/i)
         if ($mkselect && $trim =~ /\.xml$/i)
         {
            $trim = &mkselect($trim);
            printf($a1, $ii, $trim, $ii);
         }
         else
         {
            printf($a1, $ii, $trim, $ii);
         }

         $ii++;

      
         $left  = 0;
         $right = 0;
         $marker = "";
      }
   }
}

sub buf_readxml()
{
   my $a1 = shift(@_);
   my $fn = shift(@_);

   my $results = "";

   open(MSG, $fn) || die print "<hr>can not open $fn";
   my @lines = <MSG>;
   close(MSG);


   my $ii     = 0;
   my $left   = 0;
   my $right  = 0;
   my $marker = "";

   my $mm = "";
   my $tag = "";

   $_ = $a1;

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
      
         #remove leading trailing ws
         $trim = $1;
         $trim =~ s/^\s+//;
         $trim =~ s/\s+$//;


         #printf($a1, $ii, $trim, $ii);
         #$results += sprintf($a1, $trim);
         #$results = $results + sprintf($a1, $trim);

         #$results = "$results sprintf($a1, $trim)";
         $results0 = sprintf($a1, $trim);
         $results = "$results $results0";

         $ii++;

      
         $left  = 0;
         $right = 0;
         $marker = "";
      }
   }

   return $results;
}



sub mkselect()
{
   my $fn = shift(@_);
   my $results = "";


$marker = <<"END";
        <description>
		  <select name="D1" size="1">
		  <option selected>
        %s
        </option>
        </description>
END
   $results = &buf_readxml($marker, $fn);

#return $results;

$marker = <<"END";
        <row>
		  <option>%s</option>
        </row>
END

   $results0 = &buf_readxml($marker, $fn);
   $results = "$results $results0";

$marker = <<"END";
          </select>
END

   $results = "$results $marker";

   return $results;

}


sub ErrorMessage {
   my $fn = shift(@_);
        print "Content-type: text/html\n\n";
        print "The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        exit;
}

