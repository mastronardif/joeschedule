#!/usr/bin/env python

import subprocess
import os
import logging
import sys
import cgi
import cgitb
from time import sleep
cgitb.enable()  # Enable CGI traceback for debugging

logging.basicConfig(level=logging.DEBUG)

def generate_poster(video_path, output_path):
    # Use ffmpeg to generate a poster frame from the video
    command = [
        'ffmpeg',
        '-i', video_path,
        '-ss', '00:00:01.000',  # Extract frame at the 1st second
        '-vframes', '1',
        '-y',                    # Overwrite if the file exists
        output_path
    ]
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    # Check if ffmpeg executed correctly
    if result.returncode != 0:
        sys.stderr.write(f"FFmpeg error: {result.stderr.decode()}\n")
        return False
    return True

def main():
    logging.debug(f"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ generating poster\n")
    try:
        # Set headers early to indicate the type of content (image)
        print("Content-Type: image/jpeg\n")  # Output correct headers for an image
        # print("Content-Type: text/html\n")

        # Parse query parameters
        form = cgi.FieldStorage()
        media = form.getvalue("media")

        if media and os.path.exists(media):  # Ensure the media file exists
            # Define a path for the generated poster image
            # output_poster_path = "/tmp/poster.jpg"
            output_poster_path = "./members/Bucci/mypics/poster.jpg"
            logging.debug(f"BBBBBBBBBBBBBBBBBBBBBBBBBBBB generating poster\n")

            # Generate poster and check if it was successful
            if generate_poster(media, output_poster_path):
                logging.debug(f"CCCCCCCCCCCCCCCCCCCCCCCCCCCC generating poster\n")
                # Open and read the generated image
                # print ('are you writing something?')
                output_poster_path = "./members/Bucci/mypics/IMG_1559.JPEG"
                with open(output_poster_path, "rb") as img_file:                
                # with open('/usr/local/apache2/public_html/cgi/ngfop/members/Bucci/mypics/IMG_1559.JPEG', "rb") as img_file:
                    # logging.debug(f"DDDDDDDDDDDDDDDDDDDDDDDDDDD {img_file.read()} generating poster\n")
                    sys.stdout.buffer.write(img_file.read())  # Output the image as binary content
                    sys.stdout.flush()
                    sleep(2)
                    logging.debug(f"EEEEEEEEEEEEEEEEEEEEEEE generating poster\n")
            else:
                logging.debug(f"Error generating poster\n")
                sys.stderr.write("Error generating poster\n")
                
        else:
            logging.debug(f"222222222222222222222222222 generating poster\n")
            sys.stderr.write("Error: Media file not found or not provided\n")
    except Exception as e:
        sys.stderr.write(f"Error: {str(e)}\n")

if __name__ == "__main__":
    main()
