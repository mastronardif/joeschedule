/**
 * Created by remi on 17/01/15.
 */
// alert('upload.js');
(function () {

    var uploadfiles = document.querySelector('#uploadfiles');
    uploadfiles.addEventListener('change', function () {
        var files = this.files;
        for(var i=0; i<files.length; i++){
			console.log("fmdebug "+this.files[i].name); 
			//document.write(this.files[i].name);
            uploadFile(this.files[i]);
        }

    }, false);


    /**
     * Upload a file
     * @param file
     */
    function uploadFile(file){
        //var url = "../server/index.php";
		var url = "/cgi-bin/cgi/ngfop/uploadimgs.cgi";

        var xhr = new XMLHttpRequest();
        var fd = new FormData();
        xhr.open("POST", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                // Every thing ok, file uploaded
                console.log(xhr.responseText); // handle response.
				document.write(xhr.responseText);
            }
        };
        fd.append('uploaded_file', file);
        xhr.send(fd);
    }
}());