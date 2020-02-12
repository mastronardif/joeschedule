#!/usr/bin/perl -wT
use File::Copy;
use CGI qw(:standard escapeHTML);
require "./sch00.lib";
use strict 'vars';

=comment
File: schtemplates.pl

Purpose: Manage templates.
=cut

#print "Content-type: text/html\n\n";

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################

##############
# Get params #
##############
my $query = new CGI;

=comment
1. Open template comboard
2. Parse, get xml files
3. Copy whats needed
4. return comboard
=cut

#my $fnTemplate="sch86278290.xml";
my $fnTemplate="schMyComBoard01.xml";
my $mycb="/members/Templates/$fnTemplate";

# 1. Open template comboard
open(MSG,"./$mycb") || ErrorMessage("./$mycb");
my @lines = <MSG>;
close(MSG);

# 2. Parse, get xml files
my $FMlines =  join '', @lines;
#my @xmlfns = split /<NAME>(\.xml?)<\/NAME>/ig, $FMlines;

#my @xmlfns = ($FMlines =~ /(\w+\.xml)/ig);

my @xmlfns = ($FMlines =~ m#<NAME>.*?(\w+\.xml.*?).*?</NAME>#igs);
my $len = @xmlfns;

#print <<END;
#$len
#@xmlfns
#END

#3. Copy whats needed
#remove dulicate filenames.
my %hash = ();
$hash{$fnTemplate } = $fnTemplate;

my $fn;
foreach $fn(@xmlfns)
{
   $hash{ $fn } = $fn;
}
my $srcDir = "./members/Templates/";
my $destDir = "$session{dir}";

while ( my ($key, $value) = each(%hash) ) 
{
   if(!(-e "$destDir$key"))
   {
      #print "cp ($key)\n"
#      print "cp $srcDir$key  $destDir$key \n";
      mycopy("$srcDir$key", "$destDir$key") || ErrorMessage("<br><br>** $0 File($key) cannot be copied!");
#      copy($srcDir$key, $destDir$key) || ErrorMessage("<br><br>** $0 File($key) cannot be copied!");
   }
}

#4. return comboard
#print `/usr/bin/perl ./sch3b.pl`;
 require "./sch3b.pl";
exit(0);

sub ErrorMessage {
   my $fn = shift(@_);
        print "Content-type: text/html\n\n";
        print "The server can't open the file($fn). It either doesn't exist or the
               permissions are wrong. \n";
        #exit;
}

sub mycopy {
   my($src, $dest) = @_;

   if (-e "$dest")
   {
      open (LOG, "+<$dest") || &ErrorMessage("$fn");
   }
   else  # new file name
   {
      open (LOG, "+>$dest") || SCH_ErrorMessage("FM 12/13/9  $fn");
   }



   seek (LOG, 0, 0);
   #seek (LOG, 0, SEEK_SET);
   truncate(LOG, 0);
   
   # src
   open(MSG, $src) || ErrorMessage($src);
   my @src2 = <MSG>;
   close(MSG);

   print LOG "@src2";
   close (LOG);

   return 1;
}
