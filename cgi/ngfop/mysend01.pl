#!/usr/bin/perl5 -w

open(SENDMAIL, "|/usr/sbin/sendmail -oi -t")
                        or die "Can't fork for sendmail: $!\n";
    
    #print SENDMAIL "From: mastronardif\@netcarrier.com\n";
    #print SENDMAIL << EOF;
    
    print SENDMAIL "From: mastronardif\@netcarrier.com\n";
    print SENDMAIL "To: mastronardif\@netcarrier.com\n";
    print SENDMAIL "Subject: This is from $0\n";


   print SENDMAIL "MIME-Version: 1.0\n";
   print SENDMAIL "Content-Type: text/html; charset=\"UTF-8\"\r\n";

#    print SENDMAIL "Body of the message goes here, in as many lines as you like.\n";

open(MYDATA, "perl ./myget01.pl http://teachers.net/mentors/special_education/topic12196/10.14.05.18.31.05.html |")
                        or die "Can't fork for myget01: $!\n";
    print SENDMAIL <MYDATA>;

    print SENDMAIL "<hr></hr>";

open(MYDATA, "perl ./myget01.pl http://teachers.net/mentors/special_education/topic12280/10.14.05.17.50.16.html |")
                        or die "Can't fork for myget01: $!\n";
    print SENDMAIL <MYDATA>;

    #while (<MYDATA>){print ;}

print SENDMAIL "<b>thank you for using joemailweb</b";


    print SENDMAIL ".\n";   
close(SENDMAIL)     or warn "sendmail didn't close nicely";

