#!/usr/bin/perl -w

use CGI qw(:standard escapeHTML);
require "sch00.lib";

=comment
File: week.pl

Purpose: , read xml convert to hml.
=cut

print "Content-type: text/html\n\n";

##################################
# Get session data               #
my %session = &SCH_getSession(); 
##################################

$query = new CGI;

my $blankSchedule = "blank.xml";
my $xmlfilename = $query->param('name') || $blankSchedule;
my $action = $query->param('action');
my $html = "./week.htm";



#Removing leading path from filename 
#s(^.*/)()

my $filename = $xmlfilename;

$filename =~ s/(^.*\/)//;
##my $dir = $1;
my $dir = "$session{dir}$1";

##########################
# FM 11/23/03
# mov this calander stuff
# to the sch00.lib file.
##########################
# set default file
my $defFile = $xmlfilename;
#if (!(-e $xmlfilename))
if (!(-e "$session{dir}$xmlfilename"))
{
   $xmlfilename =~ /(.+\.)(.+\.xml)/igs;
   my $dayfile = $2;

   my $ddd = $1;
   $ddd =~ /(.+)(\/)/igs;
   #$xmlfilename = "$1/$dayfile";
   $defFile = "$1/$dayfile";
   $xmlfilename = $defFile;

   if (!(-e "$session{dir}$defFile"))
   {
      #print "fuck $xmlfilename aint their I'll default to $blankSchedule <br>";
      $xmlfilename = $blankSchedule;
   }
}



my $weekdays = "Sun.xml Mon.xml Tue.xml Wed.xml Thu.xml Fri.xml Sat.xml";
my @days = split /\s+/, $weekdays;  # $word[0] = 'Calvin'
my $iii = 0;
                              






open(MSG, $html) || ErrorMessage($htm);
 @lines = <MSG>;
close(MSG);

   my $left   = 0;
   my $right  = 0;
   my $marker = "";


   for $x(0 .. $#lines) {

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
         #if ($marker =~ /<\/filename>/i)

         my $tag = "filename";
         if ($marker =~ /<\/\b$tag\b>/i)
         {
            $_ = $marker;
      
            /<\b$tag\b>(.*)<\/\b$tag\b>/igs;
      
            #remove leading trailing ws
            $trim = $1;
            $trim =~ s/^\s+//;
            $trim =~ s/\s+$//;
            printf($trim, $defFile);
         }
         else
         {
            &readxml($marker, "$dir@days[$iii++]");
         }

         $left  = 0;
         $right = 0;
         $marker = "";
         next;
      }

      if (!$left) {
         print "$lines[$x]\n";
      }
   }


sub readxml()
{
#   my $a1 = shift(@_);
#   my $fn = shift(@_);
  ($a1, $fn) = @_;

   #add filename
   my @fnxml = ("<filename>", "$fn", "</filename>");

#   open(MSG, $fn) || die print "<hr>can not open $fn";
   open(MSG, $fn) || print "<hr>can not open $fn";
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
      
         #remove leading trailing ws
         $trim = $1;
         $trim =~ s/^\s+//;
         $trim =~ s/\s+$//;

         printf($a1, $trim);

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

   #print "fn = $fn\n";

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
		  <option>$fn</option>
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


sub saveList()
{
   open (LOG, ">./$xmlfilename") || &ErrorMessage($xmlfilename);

   print LOG "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
   print LOG "<data>\n";


   my $description = $formdata{'d0'};

   $description =~ s/^\s+//;       # trim leading  white space
   $description =~ s/\s+$//;       # trim trailing white space



   print LOG "<description>\n";
   print LOG "$description";
   print LOG "\n</description>\n";

   my $items = $formdata{'R55'};
   @list = split(/,/, $items);

   foreach $value(@list) {

   $value =~ s/^\s+//;       # trim leading  white space
   $value =~ s/\s+$//;       # trim trailing white space


   #skip blanks
   if (!($value))
   {
      next;
   }

   #print LOG "\nvalue($value)\n";
   #print "<P>($key)($value)<br>";
   #print "$key, $value ";

   print LOG "<name>\n";
   print LOG "$value";
   print LOG "\n</name>\n";

}

   print LOG "\n</data>\n";
   close (LOG);
}
