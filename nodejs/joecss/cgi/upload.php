<?php

//upload.php

if(isset($_POST["image"]))
{
 $fname = $_POST["fn"];
 $data = $_POST["image"];

 $image_array_1 = explode(";", $data);

 $image_array_2 = explode(",", $image_array_1[1]);

 $data = base64_decode($image_array_2[1]);

 $imageName = $fname; //time() . '.png';
 $nochache = 'dummy='. time();
 //$imageName = time() . '.png';

 //file_put_contents($imageName, $data);
 $cookie_name = "sessionID";
 //$root = './members/100170/';
 $root = './members/'.$_COOKIE[$cookie_name].'/';
 
 $fn = $root.$imageName; 
 file_put_contents($fn, $data);

 //echo 'fn = '.$fn;
 //echo 'fname = '.$fname;
 
 //my $root = "http://$ENV{HTTP_HOST}$uri$direcrtory";
 //echo '<img src="'.$imageName.'" class="img-thumbnail" />';
 echo '<img src="'."http://www.joeschedule.com/cgi/ngfop/members/100170/".$imageName.'?'.$nochache.'" class="img-thumbnail" />';
}

?>
