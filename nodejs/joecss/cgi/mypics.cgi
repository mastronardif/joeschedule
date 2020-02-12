#!/usr/bin/perl -wT
use CGI qw(:standard escapeHTML);
use JSON; # imports encode_json, decode_json, to_json and from_json.
use strict;
use warnings;
require "./sch00.lib";
use Data::Dumper;
use HTML::Entities            qw/encode_entities/;

my $q = CGI->new();
#print $q->header;

my $params = $q->Vars();
my $data = $q->param('POSTDATA');

#print "Content-type: text/html\n\n";
print "Content-Type: application/json\n\n";



#print "Thanks for your inquiry.";
#print $params; 
#print Dumper(\$params); 
#print Dumper(\$data); 

#my $sss = $ENV{HTTP_REFERER};
#DOCUMENT_ROOT
#REQUEST_URI

my $sss = $ENV{REQUEST_METHOD};
my @names = ($sss, "Foo", "Bar", "Baz");
my $json = JSON->new->allow_nonref;
#$data = '{"fuck": 123}';
#my $json_text = $json->encode($data);
my $json_text = $json->encode(\@names);

#my $json_text   = $json->to_json( $data, { ascii => 1, pretty => 1 } );
print $json_text;