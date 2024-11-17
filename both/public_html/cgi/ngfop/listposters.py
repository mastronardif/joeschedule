#!/usr/bin/python
import os
import subprocess
import logging

logging.basicConfig(level=logging.INFO)

# Supported video file extensions
VIDEO_EXTENSIONS = ('.mp4', '.mov', '.avi', '.mkv', '.wmv')

def generate_poster(video_path, output_path):
    """Generates a poster image for a given video."""
    command = [
        'ffmpeg',
        '-i', video_path,
        '-ss', '00:00:01.000',  # Capture frame at 1 second mark
        '-vframes', '1',         # Capture only 1 frame
        '-y',                    # Overwrite output file if it exists
        output_path
    ]
    
    # Run the ffmpeg command
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    if result.returncode == 0:
        logging.info(f"Poster generated for {video_path}")
    else:
        logging.error(f"Failed to generate poster for {video_path}: {result.stderr.decode()}")

def listposters(infolder, outfolder):
    """Generates posters for all video files in the input folder and saves them in the output folder."""
    
    # Ensure the output directory exists
    if not os.path.exists(outfolder):
        os.makedirs(outfolder)

    # Iterate over files in the input folder
    for filename in os.listdir(infolder):
        if filename.lower().endswith(VIDEO_EXTENSIONS):  # Check if the file is a video
            video_path = os.path.join(infolder, filename)
            # poster_filename = f"{os.path.splitext(filename)[0]}_poster.jpg"
            poster_filename = poster_filename = f"{filename}.jpg"
            output_path = os.path.join(outfolder, poster_filename)
            
            # Generate the poster for the video
            generate_poster(video_path, output_path)

if __name__ == "__main__":
    infolder = "./members/Bucci/mypics"  # Replace with your input folder
    outfolder = "./members/Bucci/mypics/posters"     # Replace with your output folder
    
    listposters(infolder, outfolder)
