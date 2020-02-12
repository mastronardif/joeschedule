#!/usr/bin/perl -wT
use strict;
use warnings;
use CGI qw(:standard escapeHTML);
require "./sch00.lib";
use Time::Local;
use File::Find qw(finddepth);
use Cwd;

use File::Basename;
use LWP::Simple qw(get getstore);
use URI;
use URI::Escape;

use strict "vars";
use Data::Dumper;

#for debuging only, remove in production. BEGIN
#use CGI::Carp qw(fatalsToBrowser); 
#for debuging only, remove in production. END


=comment
File: uploadimgs.pl

Purpose: upload img files to user folder.
=cut

print "Content-type: text/html\n\n";

#my $query = new CGI;

##################################
# Get session data               #
my %session = &SCH_getSession(); #
##################################
my $direcrtory = $session{dir};

my $q = CGI->new();
#print $q->header;

#my $upload_folder = '/var/www/html/uploads';
my $upload_folder =  "$session{dir}";

my $fn = $q->param('fn');
my $email = $q->param('email');

my @files = $q->param('multi_files');
#my @files = $q->param('uploaded_file');

print "upload_folder = $upload_folder <br>";
print @files;

foreach my $upload(@files){
    print "Upload this please -- $upload<br>";
    my $upload_file  = $q->upload($upload);

    #if (0 && $upload_file){
	if ($upload_file){
        #open (OUTFILE,">$upload_folder/$upload") or die $!;
		open (OUTFILE,">$upload_folder$upload") or print $!;
        binmode OUTFILE;
        while (<$upload_file>) {
            print OUTFILE;
        }
    }
    else {
        print "<b>Guess it's broken</b><br/>";
    }
}

print "<p><b>Name</b> -- $name<br><b>Email</b> -- $email<br><b>Comment
+s</b> -- $upload_folder<br>";

print $q->end_html;

