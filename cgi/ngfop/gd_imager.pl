#!/usr/bin/perl

#############################
#
# ReJump DG Imager (web engine version)
#
# Image resizing tool (with cashing possibility)
#
# http://www.rejump.com
# V 1.2
#
# (c) 2003, mas
#
# mail: alexey@mas.kiev.ua
#       websoft@rejump.com
#
# Don't remove this, please! ;-)
#
#

use GD;
use CGI;

$cgi = new CGI;
my $img_sub_path = reDot($cgi->param('img'));


my $configFile = $cgi->param('conf');

my $Width, $Height, $dX, $dY, $Border, $Base, $Align, $VAlign;

if( $configFile ne "" )
{
	loadConfig($configFile);
	
	$Width		= readIntValue('width', 0);
	$Height		= readIntValue('height', 0);
	$dX		= readIntValue('dx', 0);
	$dY		= readIntValue('dy', 0);
	$Border		= readIntValue('border', -1);
	$Base		= readValue('base', '');	
	$Align		= readValue('align', 'center');	
	$VAlign		= readValue('valign', 'center');	
	$Cash_Dir	= readValue('cash_dir', '');	
	$Cash_Time	= readIntValue('cash_time', 60*60*24);	
	$Cash_Slash	= readValue('cash_slash', '--');	

	freeConfig();
}else{
	$Width = $cgi->param('width');
	$Width+=0;
	$Height = $cgi->param('height');
	$Height+=0;
	$Base   = reDot($cgi->param('base'));
	$dX = $cgi->param('dx');
	$dX+=0;
	$dY = $cgi->param('dy');
	$dY+=0;
	$Border = $cgi->param('border');
	if( $Border eq "")
	{
		$Border=-1;
	} 
	$Border+=0;

	$Align = $cgi->param('align');
	if( $Align ne "right" && $Align ne "left" )
	{
		$Align="center";
	} 
	$VAlign = $cgi->param('valign');
	if( $VAlign ne "top" && $VAlign ne "botton" )
	{
		$VAlign="center";
	} 

}

$img_path=$ENV{'DOCUMENT_ROOT'}.$img_sub_path;
#$img_path="http://joeschedule.com/cgi/ngfop/pics/book/ap0014.jpg";

if( $img_path!~/\.jpg/ && $img_path!~/\.jpeg/ && $img_path!~/\.png/ )
{
	open(IMG,$img_path);
        #open(IMG, "/cgi-bin/cgi/ngfop/pics/book/1010.jpg"); 

	binmode(IMG);
	print "Content-type: image/pjpeg\n\n";
	binmode(STDOUT);
	while(my $size=sysread(IMG,$buf,10000)){
		print $buf;
	}
	close(IMG);
	exit;
}


if( -d $Cash_Dir )
{
	$cashed_file_name=$img_sub_path;
	$cashed_file_name=~s/\//$Cash_Slash/g;
	if( -f $Cash_Dir."/".$cashed_file_name )
	{

		$cash_time=(stat($Cash_Dir."/".$cashed_file_name))[9];
		if($cash_time > $^T - $Cash_Time)
		{
			
			open(IMG,$Cash_Dir."/".$cashed_file_name);
			binmode(IMG);
			print "Content-type: image/pjpeg\n\n";
			binmode(STDOUT);
			while(my $size=sysread(IMG,$buf,10000)){
				print $buf;
			}
			close(IMG);
			exit;
		}
	}
}

if($Base eq "")
{

	if( -f $img_path)
	{
		$im = newFromJpeg GD::Image($img_path);

		($width,$height) = $im->getBounds();

		($new_width,$new_height) = newSize($width,$height,$Width,$Height);

	 	$im2 = new GD::Image($new_width,$new_height);
		$im2->copyResized($im,0,0,0,0,$new_width,$new_height,$width,$height);
		
		print "Content-type: image/pjpeg\n\n";
		binmode(STDOUT);
		print $im2->jpeg();
		exit;	
	}else{
		print "Content-type: text/html\n\n";
		print "Have no image\n";
	}

}else{

	$base_path=$ENV{'DOCUMENT_ROOT'}.$Base;

	# create a new image

	if( -f $img_path)
	{
		$im = newFromJpeg GD::Image($img_path);
		($width,$height) = $im->getBounds();
	}else{
		$im = newFromPng GD::Image($base_path);	
		print "Content-type: image/pjpeg\n\n";
		binmode(STDOUT);
		print $im->jpeg();
		exit;
	}

	$im2 = newFromPng GD::Image($base_path);
	
	($width2,$height2) = $im2->getBounds();

	if( $Width<=0 && $Height<=0 && Border>=0 )
	{
		if( $Align eq "center" )
		{
			$Width=$width2-$Border*2;
		}else{
			$Width=$width2-$Border;
		}
	}

	($new_width,$new_height) = newSize($width,$height,$Width,$Height);

	if( $Align eq "center" )
	{
		$border_x=$dX+int(($width2-$new_width)/2);
	}elsif( $Align eq "left" ){
		$border_x=$dX + (($Border>=0) ? $Border : 0);
	}elsif( $Align eq "right" ){
		$border_x=$width2-$new_width - $dX - (($Border>=0) ? $Border : 0);
	}

	if( $VAlign eq "center" )
	{
		$border_y=$dY+int(($height2-$new_height)/2);
	}elsif( $VAlign eq "top" ){
		$border_y=$dY + (($Border>=0) ? $Border : 0);
	}elsif( $Align eq "bottom" ){
		$border_y=$height2-$new_height - $dY - (($Border>=0) ? $Border : 0);
	}

	$im2->copyResized($im,$border_x,$border_y,0,0,$new_width,$new_height,$width,$height);

	print "Content-type: image/pjpeg\n\n";

	if( -d $Cash_Dir )
	{
		$cashed_file_name=$img_sub_path;
		$cashed_file_name=~s/\//$Cash_Slash/g;
		open(CASH,">".$Cash_Dir."/".$cashed_file_name);
		binmode(CASH);
		print CASH $im2->jpeg();
		close(CASH);
        }

	binmode(STDOUT);
	print $im2->jpeg();

}

exit;

sub newSize($$$$)
{
	my $width=shift();
	my $height=shift();
	my $Width=shift();
	my $Height=shift();

	my $new_width, $new_height;	

	if($Width<=0 && $Height>0)
	{
		$Width=10000;
	}else{
		if($Height<=0 && $Width>0)
		{
			$Height=10000;
		}
	}
	
	if($Width<=0 && $Height<=0)
	{
		return ($width,$height);
	}

	if($Width/$width > $Height/$height)
	{
		$new_height=$Height;
		$new_width=int(($Height/$height)*$width);
	}		
	if($Width/$width <= $Height/$height)
	{
		$new_width=$Width;
		$new_height=int(($Width/$width)*$height);
	}

	return ($new_width,$new_height);
}

sub loadConfig($)
{
	open(FILE, shift());
	@config = <FILE>;
	chomp(@config);
	close(FILE);
}

sub freeConfig()
{
	@config = ();
}

sub readValue($$)
{
	$quoted = 1;
	my $k = shift();
	foreach(@config)
	{
		if ($_ =~ /^\s*$k\s*=\s*(.+?)\s*$/)
		{
			$_ = $1;
			return $1 if (/^"(.+?)"$/);
			$quoted = 0;
			return $_;
		}
	}
	$quoted = 0;
	return shift();
}

sub readIntValue($$)
{
	return int(readValue(shift(), shift()));
}

sub readArray($)
{
	my $k = shift();
	my $v = readValue($k, '');
	return split(/"\s*,\s*"/, $v) if ($quoted);
	return split(/\s*,\s*/, $v);
}

sub readIntArray($)
{
	my @v = readArray(shift());
	foreach(@v)
	{
		$_ = int($_);
	}
	return @v;
}

sub reDot($)
{
	my $str=shift();
	$str=~s/\.\.//g;
	return $str;
}
