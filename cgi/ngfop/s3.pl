#!/usr/bin/perl -w
# Example 3-2. 
 
use strict;
use Image::Magick;
my $img = new Image::Magick;

# Read all of the images with a .gif 
# extension in the current bdirectory

my $status = $img->Read("*.gif");
if ($status) {
    die "$status";
}

# Montage() returns a new image

my $montage = $img->Montage(geometry    =>'100x100',
                            tile        =>'3x2',
                            borderwidth => 2);
$montage->Write('png:montage1.png');

# Also try:
# my $montage = $img->Montage(
#    geometry=>'100x100',
#    tile => '3x2',
#    background => '#FFFFFF',
#    pointsize => 12,
#    label => "%f\n%wx%h\n(%b)",
#    fill => '#000000',
#    borderwidth => 2
#);

#my $montage = $img->Montage(
#    geometry     => "100x100+10+10",
#    tile        => '3x2',
#    background  => '#FFFFFF',
#    label       => "%f",
#    mode        => 'Frame',
#    frame       => "10x10+2+4"
#);

