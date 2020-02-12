#!/usr/bin/perl -wT
use CGI qw(:standard escapeHTML);
use strict;
use warnings;
require "./sch00.lib";
use Data::Dumper;
use HTML::Entities            qw/encode_entities/;

my $q = CGI->new();
print $q->header;

##########################
# Get session data               #
my %session = &SCH_getSession(); #
##################################
my $direcrtory = $session{dir};

unless ($q->param('multi_files')) { 
print '
<html>
    <head>
        <title>Stupid Test Site</title>
    </head>
    <body>
        <h1>This is a test</h1>
        
        <form action="uploadimgs22.cgi"  enctype="multipart/form-data". method="POST">
            Your Name: <input type="text" name="name"><br>
            Email Address: <input type="text" name="email"><br>
            Select PO folder: <input name="multi_files" type="file" multiple accept="image/png, image/jpeg"><br/>
            Comments:<br>
            <textarea name="comments" rows="5" cols="60"></textarea><br>
            <input type="submit" value="Send">
        </form>
    </body>
</html>
'; 
exit; 
} 

#my $upload_folder = '/var/www/html/uploads';
my $upload_folder =  "$session{dir}";


my $name = $q->param('name');
my $email = $q->param('email');

my $comments = $q->param('comments');

my @files = $q->param('multi_files');

my $tostdout=0; 

###### see 
###### http://stackoverflow.com/questions/3196783/perl-file-upload-cant-init-filehandle
###### File upload forms need to specify enctype="multipart/form-data".  ----- Sinan Ünür 
my @io_handles=$q->upload('multi_files');

print '<pre>'; 
print "\$upload_folder= $upload_folder <br/>";
print Dumper(\@files); 
print Dumper(\@io_handles); 
print '</pre>'; 
print '<br>step0';
my $dest = "";


for my $upload (@files){
    print "<br>Upload this please -- $upload<br>";
    if ($upload){	
       eval { 
           if ($tostdout) { 
             print '<pre>' ; 
             while ( my $buffer  = <$upload>) {
               print STDOUT  encode_entities($buffer);
             } # while 
             print '</pre>' ; 
           } # tostdout 
           else { 
		     &SCH_checkDir() == 1 || SCH_ErrorMessage("You reached your limit of files.");
			 #open (OUTFILE,">$upload_folder/$upload") or die $!;
			 $dest = "$upload_folder$upload";
			 print "DEST= $dest <br/>";	 

             open (OUTFILE,">>$dest") or die $!;
             binmode OUTFILE;
             while ( my $buffer  = <$upload>) {
               print OUTFILE $buffer;
             } # while 
             close OUTFILE; 
			   } # notstdout
          };  # eval 
		  
     print 'error:'.$@.'<br>' if $@; 
	 
	 	  #print "EEEEE"; exit;
	
    } # upload 
    else {
        print "<br><b>Guess it's broken</b><br/>";
    } # else 
} # $upload 

print "<p><b>Name</b> -- $name<br><b>Email</b> -- $email<br><b>Comments</b> -- $comments<br>";

print $q->end_html;