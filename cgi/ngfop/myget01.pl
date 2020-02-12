#!/usr/bin/perl

#use CGI qw(:standard escapeHTML);

=comment
File: .pl

Purpose: 
=cut

require 5;
use strict;
use strict 'vars';

use URI;
use LWP::Simple;
use HTML::TokeParser;
use HTML::TreeBuilder;

use HTML::Parse;

use HTML::FormatText;

#my $query = new CGI;


#open(DBG, ">fuck.txt") || die print "<hr>can not open fuck.txt";

#my $ref = "http://www.insects.org/entophiles/lepidoptera/";
#my $url = "http://images.search.yahoo.com/search/images?ei=UTF-8&fr=sfp&p=";
#$url = $ref;


my $url = $ARGV[0];


#print DBG "url($url)\n";

my $html   = get($url) || die "Couldn't get ($url)!";
##print $html;

##$plain_text = HTML::FormatText->new->format(parse_html($html));

#print $plain_text;
##$template_root->parse_file($fn) || die "Can't read template file: $!";
my $root = HTML::TreeBuilder->new;
#$root->store_comments(1);
$root->parse($html) || die "Can't read template file: $!";

foreach my $d ($root->look_down(
   sub {
      return 1 if $_[0]->tag eq 'img'; # we're looking for images

      return 1 if $_[0]->tag eq 'script'; # we're looking scripts

      #no class means ignore it
      my $class = $_[0]->attr('class') || return 0;

      return 1 if $class eq 'top_button_bar' or $class eq 'right_geegaws';
      return 0;
   }
   )) {
      $d->delete;
   }
   print $root->as_HTML(undef, '  '); # two-space indent in output.

$root->delete;

#print DBG "\n<FILE>\n";
#print DBG $html;
#print DBG "\n</FILE>\n";

#print DBG "<UNPARSE>\n";
#print DBG "$html\n";
#print DBG "</UNPARSE>\n";
