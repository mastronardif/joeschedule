#!/usr/bin/perl -w
use strict 'vars';

use Net::POP3;

use URI;
use LWP::Simple;
use HTML::TokeParser;
use HTML::TreeBuilder;

my $fn = "mymaillog.txt";
open(DBG, ">$fn") || die print "can not open($fn)$!";

    my ($site, $username, $password, $pop3, $messagesref);
    my ($k,$v);
    $site = 'mail.netcarrier.com';
    $username = 'mastronardif';
    $password = '10566';
#    $site = 'mail.comcast.net';
#    $username = 'mastronardif';
#    $password = 'baseball';

    #$ARGV[0] =~ /subject:(.*)/i;
    #$subject = $ARGV[0]; #$1 || "";

    $pop3 = Net::POP3->new($site); 
    my $tot_msg;

    # Most error-checking deleted for clarity
    defined ($tot_msg = $pop3->login($username, $password))
        or die "Can't authenticate: $!";

    printf("\n   There are $tot_msg messages\n\n");


    $messagesref = $pop3->list;

    unless ($messagesref) {print "no mail.\n";}

LRM:   while ( ($k,$v) = each %$messagesref ) 
   {

      my $header = $pop3 -> top($k, 0);
      my ($subject, $from, $status) = analyze_header($header);


      print "$k:\t$v\n";

      printf("\$subject(%s)\n", $subject );
      printf("\$from(%s)\n",    $from );
      ##printf("\$status(%s)\n",  $status );



      if ($subject !~ /.*FM, myget/igs)
      {
         next LRM;
      }


      my $msgref = $pop3->top( $k, $v );

      #if ("@$msgref" =~ /$subject/igs)
      if(9==0)
      {
         #my $retval = $pop3->delete($k);
         #print ("\$retval = $retval\n");
         print "Holy fuck shit you match \($subject\)\n";
         print "delete \(subject:$subject\)\n";
      }





      print "\n<MYMAIL>\n";
      print DBG "\n<MYMAIL>\n";

      #if ("@$msgref" =~ /Subject: FM, myget/igs)
      #if ("@$msgref" =~ /Subject: .*FM, myget/igs)

      ######if ($subject =~ /.*FM, myget/igs)
      {
         print "\n<FM, MYGET>\n";

         "@$msgref" =~ /Return-Path: <(.*?)>/igs;

         print "\n<Return-Path:>\n";
         print($1);
         print "\n</Return-Path:>\n";

         print "$k:\t$v\n";

         #print "@$msgref\n";

      print "\n<HEADER>\n@$header\n</HEADER>\n";

=comment
      print DBG "\n<FFFF>\n";
      #print "@$msgref";
      print DBG "@$msgref";
      print DBG "\n</FFFF>\n";
=cut
      $msgref = &removeShit22($msgref);
      print DBG "\n<22>\n";
      print DBG "$msgref";
      print DBG "\n</22>\n";

=comment
      print "\n<FFFF22>\n";
      print "@$msgref";
#      print DBG "@$msgref";
      print DBG $msgref;
      print "\n</FFFF22>\n";
=cut




      ##=comment
      print "\n<TAGS>\n";
      print DBG "\n<TAGS>\n";

      ##Cheese for now, later use html::paraser you might have to encode it.
      # i.e. <a href="http://www.gazetteextra.com/diningout/main.html" target="new">

      my $root = HTML::TreeBuilder->new;
#      $root->parse("@$msgref") || die $!;
      $root->parse("$msgref") || die $!;
      #$root->parse_file($url) || die $!;
      foreach my $sss ($root->find_by_tag_name('a'))
      {
         #my $vvv = $sss->attr('class') || "aaaa";
            ##my $vvv = $sss->[1]{href} || "aaaa";
         #my $vvv = $sss->{href} || "aaaa";
         #print "FUCKYOU $vvv\n";

         #print $ref;
         print "\n<TAG>\n";

         ##print $sss->as_HTML;
         if ($sss) {
            print DBG "$sss->{'href'}\n";
         }

         #$sss =~ /a href<\"(.*)\"/i;
         #print $1 || "fu bud";

         print "\n</TAG>\n";

      }

      #print $root->dump;

      $root->eof();  # done parsing for this tree

      print "\n</TAGS>\n";
      print DBG "</TAGS>\n";

      ##       print "@$msgref\n";


      print "\n</FM, MYGET>\n";

      }  # end found the fuck.

      print "\n</MYMAIL>\n";
      print DBG "\n</MYMAIL>\n";

   }  ## loop thru mail.   

    $pop3 -> quit;  # deleted messages are deleted now


    print "\nthe end\n";


#    while (<DATA>) {
#      print "One $_";
#    }


sub analyze_header {
  my $header_array_ref = shift;

  my $header = join "", @$header_array_ref;

  my ($subject) = $header =~ /Subject: (.*)/m;
  my ($from   ) = $header =~ /From: (.*)/m;
  my ($status ) = $header =~ /Status: (.*)/m;


  if (defined $status) {
    $status = "Unread" if $status eq 'O';
    $status = "Read"   if $status eq 'R';
    $status = "Read"   if $status eq 'RO';
    $status = "Ne    $status = "-";w"    if $status eq 'NEW';
    $status = "New"    if $status eq 'U';
  }
  else {
    $status = "-";
  }

  return ($subject, $from, $status);
}

sub removeShit22()
{
  my $header_array_ref = shift;
  
  my $header = join "", @$header_array_ref;

#   print DBG "\n<HeAd>\n";   print DBG "$header";   print DBG "\n</HeAd>\n";


LINE:  foreach (@$header_array_ref)
  {
#   print DBG "($_)\n";

      #s/(href=3D)/href=/ig;
      s/=3D/=/ig;
#   print DBG "($_)\n";


      #s/=(?:20)?$//;
      s/(=20)?$//;
#   print DBG "($_)\n";
      if ($1) {next LINE};

      s/(=)?$//;
#   print DBG "($_)\n";
      if ($1) 
      {
         chop($_);
         #chop($_);

#   print DBG "($_)\n";
         #print "\n"; 
         next LINE;
      }

      #print $_;
#      print "FUCK\n";
  }

   $header = join "", @$header_array_ref;

=comment
   print DBG "\n<HeAd33>\n";
   print DBG "$header";
   print DBG "\n</HeAd33>\n";
=cut

return $header;


}


__END__
fish fly ox
species genus phylum
cherub radius jockey
index matrix mythos
phenomenon formula
