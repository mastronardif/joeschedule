#!/usr/bin/perl -w
# Example 2-1. Hello world in GD

use strict;
use GD;

#for debuging only, remove in production. BEGIN
use CGI::Carp qw(fatalsToBrowser);
#for debuging only, remove in production. END


my $image = new GD::Image(401,201);
$image->trueColor();
my $gray = $image->colorAllocate(200, 200, 200);
my $red = $image->colorAllocate(255, 0, 0);
my $black = $image->colorAllocate(0, 0, 0);

# Draw a field of polka dots with random diameters

foreach my $i (0..10) {
    foreach my $j (0..5) {
        my $d = rand(50)+1;
        $image->arc($i*40, $j*40, $d, $d, 0, 360, $red);
        $image->fill($i*40, $j*40, $red);
    }
}

# Draw the text in black

my ($x1, $y1, $x2, $y2,
    $x3, $y3, $x4, $y4) = $image->stringFT($black, "./a010013l.afm", 48, 0, 40, 120, "Hello World");

# Outline the text with a black box

$image->rectangle($x1-10, $y1+10, $x3+10, $y3-10, $black);

print $image->png; 




