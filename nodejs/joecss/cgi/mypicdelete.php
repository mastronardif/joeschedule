<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
 
$request_method=$_SERVER["REQUEST_METHOD"]; 
// get product id
$data = json_decode(file_get_contents("php://input"));
 
 if ($request_method != 'DELETE')
 {
	 //405 Method Not Allowed
	 http_response_code(405);
	 echo json_encode(array("message" => "405 Method Not Allowed.",
							"id" => $data->id));
	 return;
 }

// delete the product
	$cookie_name = "sessionID";
	$imageName = $data->id ;
	$msg = "wtf";
if(delete($imageName, $msg)){	
 
    // set response code - 200 ok
    http_response_code(200);
 
    // tell the user
	// $data->id;
    echo json_encode(array("message" => "api mypics/delete.",
	                       "id" => $data->id,
						   "msg" => $msg));						   
} 
// if unable to delete the product
else{
 
    // set response code - 503 service unavailable
    http_response_code(503);
 
    // tell the user
    echo json_encode(array("message" => "Unable to delete product.",
										"id" => $data->id,
										"msg" => $msg,						   
										"fn" => $imageName));
}

// delete the product
function delete($id, &$msg)
{
	$retval = true;
	$cookie_name = "sessionID";
	$root = './members/'.$_COOKIE[$cookie_name].'/';
	
	// sanatize file name.
	$imageName = basename($id);
	$fn = $root.$imageName;
 
	if (file_exists($fn)) {
		$retval = unlink($fn);
		if ($retval){
			$msg = "File $imageName removed.";
		} else {
			$msg = "unable to unlink $fn";
		}
	} else {
		$msg = "The file $imageName does not exists";
    }
	return $retval;
}

?>