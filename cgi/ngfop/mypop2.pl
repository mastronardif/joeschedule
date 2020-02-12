#!/usr/bin/perl -w
use strict 'vars';

use Net::POP3;

use URI;
use LWP::Simple;
use HTML::TokeParser;
use HTML::TreeBuilder;

#exit 123;

#$ARGV[0] =~ /subject:(.*)/i;

    my ($site, $username, $password, $pop3, $messagesref);
    my ($k,$v);
    $site = 'mail.netcarrier.com';
    $username = 'mastronardif';
    $password = '10566';
#    $site = 'mail.comcast.net';
#    $username = 'mastronardif';
#    $password = 'baseball';

    #$ARGV[0] =~ /subject:(.*)/i;
#    my $subjectKey = $ARGV[0] || "";

    $pop3 = Net::POP3->new($site); 
    my $tot_msg;
    $tot_msg=0;

    # Most error-checking deleted for clarity
    defined ($tot_msg = $pop3->login($username, $password))
        or die "Can't authenticate: $!";

    printf("There are $tot_msg messages\n\n");

    if (0==$tot_msg) {exit;}

     

    $messagesref = $pop3->list;

    unless ($messagesref) {print "no mail.\n";}

   my $isOpen = 0;
   my %tags;
LRM:   while ( ($k,$v) = each %$messagesref ) 
   {
      %tags = ();
      my $header = $pop3 -> top($k, 0);
      ##FM 5/27/7 my ($subject, $from, $status) = analyze_header($header);

      my ($subject, $from, $status) = get_header_info($header);

      print "$k:\t$v\n";

      printf("\$from(%s)\n",    $from );
      printf("\$subject(%s)\n", $subject );
      ##printf("\$status(%s)\n",  $status );

      #if ("@$msgref" =~ /$subject/igs)
#      if ($subject eq  $subjectKey)
#      {
#         my $retval = $pop3->delete($k);
#         #print ("\$retval = $retval\n");
#         print "Holy shit shit you match \($subject\)\n";
#         print "delete \($k subject:$subject\)\n";
#         next LRM;
#      }

      if ($subject !~ /.*joemailweb/igs)
      {
         next LRM;
      }

      ##########################
      #  Open file             #
      ##########################
      if (!$isOpen) {
         $isOpen = 1;
      
         my $fn = "mymaillog.txt";  # get file names
         my $fnlog = "mymaillog.raw.txt";
         open(DBGlog, ">>$fnlog") || die print "can not open($fnlog)$!";
         open(DBG, ">$fn") || die print "can not open($fn)$!";

         printf DBGlog "\n   There are $tot_msg messages\n\n";
      
      }

      my $msgref = $pop3->top( $k, $v );

      printf DBGlog "Message $k:\tSize: $v\n";
      #print DBGlog (@$msgref);
      print DBGlog (join "", @$msgref);
                               

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

      $msgref = &removeShit22($msgref);
      print DBG "\n<HEADER>\n";
      printf (DBG "From: %s\n",    $from );
      printf (DBG "Subject: %s\n", $subject );
      print DBG "\n</HEADER>\n";

      print "\n<TAGS>\n";

      my $root = HTML::TreeBuilder->new;
      $root->parse("$msgref") || die $!;
      #$root->parse_file($url) || die $!;
      foreach my $sss ($root->find_by_tag_name('a'))
      {
         #print $ref;
         print "\n<TAG>\n";

         ##print $sss->as_HTML;
         if ($sss) {
            #print DBG "$sss->{'href'}\n";
            $sss->{'href'} =~ s/\n//g;

            $tags{$sss->{'href'}} = $sss->{'href'};
         }

         #$sss =~ /a href<\"(.*)\"/i;
         #print $1 || "fu bud";

         print "\n</TAG>\n";

      }

#test
print DBG "\n<TAGS>\n";
foreach (keys(%tags)) 
{
   if (/^http:\/\//) {print DBG "$_\n"};
}
print DBG "\n</TAGS>\n";
#test

      $root->eof();  # done parsing for this tree

      print "\n</TAGS>\n";

      print "\n</FM, MYGET>\n";

      }  # end found the fuck.

      print "\n</MYMAIL>\n";
      print DBG "\n</MYMAIL>\n";


      #delet mail
      if (9==9)
      {
         my $retval = $pop3->delete($k);
         print "Holy shit shit you match \($subject\)\n";
         print "delete \($k subject:$subject\)\n";
      }

   }  ## loop thru mail.   

    $pop3 -> quit;  # deleted messages are deleted now


    print "\nthe end\n";

    ##return $tot_msg;


#    while (<DATA>) {
#      print "One $_";
#    }

sub get_header_info {
  my $header_array_ref = shift;

  my $header = join "", @$header_array_ref;

  my ($subject) = $header =~ /Subject: (.*)/m;
  my ($from   ) = $header =~ /From: (.*)/m;

#  my ($from   ) = $header =~ /Return-Path: (.*)/m;
#  my ($from   ) = $header =~ /Message-ID: (.*)/m;

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




sub analyze_header {
  my $header_array_ref = shift;

  my $header = join "", @$header_array_ref;

  my ($subject) = $header =~ /Subject: (.*)/m;

  my ($from   ) = $header =~ /From: (.*)/m || "";
  my ($status ) = $header =~ /Status: (.*)/m;
print "from ffff = $from\n";

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

  return ($subject||"", $from, $status);
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

return $header;


}


__END__
mastronardif@comcast.net
mastronardif@netcarrier.com
fmastronardi@interlink.bz
