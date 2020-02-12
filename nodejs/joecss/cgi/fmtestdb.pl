#!/usr/bin/perl
require "./schdb.lib";
use strict;
use Authen::Users;

my $GROUP= "s1";

my $error="";
my $id='Bucci';
my $pw='123456';
my $fn='Frank';
my $ln='Mastro';
my $email='mastronardifXgmail.com';

#$error = &SCHDB_Adduser($id, $pw, "$fn $ln", $email);
#$error = &SCHDB_Adduser($id, $pw, "Frank Mastronadi", $email);

#$error = SCHDB_DoesIDExists('Bucci');
#my $authCode = &SCH_authenticate('Bucci', '123456');
#my $authCode = &SCH_authenticate('Webb', 'Carmel');
#print $authCode;

#$error =   SCHDB_Validate('Bucci', '123456');

#$error = SCHDB_UserInfo('Visitor');
my $authen = new Authen::Users(dbtype => 'MySQL', dbhost => 'www3.pairlite.com', dbname => 'pl1321_dbjs',  
                                NO_SALT => 1, dbuser =>'pl1321_w', dbpass => 'Fm123456', dbname =>'pl1321_dbjs', create => 0);

							   
print "what the hell \n";

tellMeAbout('Webb');
tellMeAbout('Css');

##$authen->add_user('s1', 'Smiith', 'Doug', 'Doug Smith', 'mastronardifXgmail.com', 'f', 'u') or die  $authen->error;
##$error = SCHDB_Adduser22('Smiith44', 'Doug', 'Doug Smith44', 'mastronardifXgmail.com');

#$authen->authenticate('s1', 'Webb', 'Carmel');
##$error = $authen->is_in_table($GROUP, 'Smiith');
##$error = SCHDB_DoesIDExists('SmiithXX');

# fails.... $authen->authenticate('s1', 'Css', 'Joe');
$error = &SCHDB_Validate22('Css', 'Joe');
##my $href = &SCHDB_UserInfo('Css');
##print "$href->{dir} \n";

print "\n validate = $error \n";

print $authen->errstr();
print $authen->error;
print "fuck";
=comment
my $href;
$href = $authen->user_info_hashref($GROUP, 'Bucci') or $authen->errstr;	

#$error = $authen->is_in_table($GROUP, $id);
=cut

print "\n The end \n"; 
print $error;


sub  SCHDB_Validate22()
{
   #SCHDB_Validate(id, pw)
   my($id, $pw) = @_;
   
   #my $authen = new Authen::Users(dbtype => 'MySQL', dbhost => 'www3.pairlite.com', dbname => 'pl1321_dbjs',  
   #                             NO_SALT => 1, dbuser =>'pl1321_w', dbpass => 'Fm123456', dbname =>'pl1321_dbjs', create => 0);
  
   # FM 1/20/9 return $authen->authenticate($GROUP, $id, $pw);
   #if ($authen->authenticate($GROUP, $id, $pw))
   {
      my $href = &SCHDB_UserInfo($id);
	  
	  my $fullname = $href->{fullname};
	  my @array1 = split /\s+/, $fullname;
	  my $pwDB = @array1[0];
	  
	  if ($pw eq $pwDB) 
	  {
		return $href->{dir};
	  }

      
   }
   return 0;
}

sub  SCHDB_Adduser22()
{
   my($id, $pw, $fullname, $email) = @_;

my $authen = new Authen::Users(dbtype => 'MySQL', dbhost => 'www3.pairlite.com', dbname => 'pl1321_dbjs',  
                               NO_SALT => 1, dbuser =>'pl1321_w', dbpass => 'Fm123456', dbname =>'pl1321_dbjs', create => 0);
   
#   my $authen = new Authen::Users(dbtype => 'MySQL', dbhost => 'www3.pairlite.com', dbname => 'pl1321_dbjs',  
#                              dbuser => 'pl1321_w', dbpass => 'Fm123456', dbname =>'pl1321_dbjs', create => 0);
   $authen->add_user($GROUP, $id, $pw, $fullname, $email, "", "") or return $authen->error;                               
   
   return "";
}


sub tellMeAbout()
{
   my ($id) = @_;

   if ($authen->not_in_table($GROUP, $id))
   {
        print "********** $id not in the database.\n";
        return;
   }

print "*****************************\n";

my $href;
$href = $authen->user_info_hashref($GROUP, $id) or die "Cannot retrieve information about $id in group $GROUP:
$authen->errstr";

#print "$href->{email}\n";

while( my ($k, $v) = each %$href ) 
{
   #print "key: $k, value: $v.\n";
   if ($k=~/created|modified|pw_timestamp/i)
   {
      print "$k(";
      print scalar localtime ($href->{created});
      print ")\n";
   }
   else
   {
      print "$k($v)\n";
   }
}
}
