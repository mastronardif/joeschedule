#!/usr/bin/perl5 -w

die "please supply a filename as an argument.\n" unless $ARGV[0];

open(SENDMAIL, "|/usr/sbin/sendmail -oi -t")
                        or die "Can't fork for sendmail: $!\n";
    
    #print SENDMAIL "From: mastronardif\@netcarrier.com\n";
    #print SENDMAIL << EOF;

=comment    
    print SENDMAIL "From: mastronardif\@gw.example.org\n";
    print SENDMAIL "To: mastronardif\@comcast.net\n";
    print SENDMAIL "Subject: This is from $0\n";


   print SENDMAIL "MIME-Version: 1.0\n";
   print SENDMAIL "Content-Type: text/html; charset=\"UTF-8\"\r\n";
=cut
#    print SENDMAIL "Body of the message goes here, in as many lines as you like.\n";

#open(MYDATA, "perl ./myget01.pl http://www.themonroetimes.com/o1008aut.htm |")
#open(MYDATA, "cat ./mymaillog.txt |")
open(MYDATA, "cat ./$ARGV[0] |")
                        or die "Can't cat ./$ARGV[0]: $!\n";
    print SENDMAIL <MYDATA>;

#   print SENDMAIL "Content-Type: text/html; charset=\"UTF-8\"\r\n";
#open(MYDATA, "cat ./mymaillog.txt |")
#                        or die "Can't fork for myget01: $!\n";
    print SENDMAIL <MYDATA>;


#    print SENDMAIL "<hr></hr>";
#open(MYDATA, "perl ./myget01.pl http://www.joeschedule.com |")
#                        or die "Can't fork for myget01: $!\n";
#    print SENDMAIL <MYDATA>;

    #while (<MYDATA>){print ;}



   # print SENDMAIL ".\n";   
close(SENDMAIL)     or warn "sendmail didn't close nicely";

