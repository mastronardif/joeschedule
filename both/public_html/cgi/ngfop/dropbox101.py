#!/usr/bin/env python
import dropbox


# Your Dropbox API credentials
ACCESS_TOKEN = 'sl.B90NOTPGvTb7_TQqJUmwm8Us41nlzC3id0oKJ1WFWKQ1HtXzl40vDwo7u4Sq6d4UX23yi9p9eqWF0tcOWFk0FJVjP5A2pyGY256aDIm80R8WQqZsS-8g6SV5Naudk3MZ6inS9Gu9tbpP'  # Replace with your actual access token

# Initialize Dropbox client


# Function to list image files in a Dropbox folder
def list_image_files(folder_path):
    dbx = dropbox.Dropbox(ACCESS_TOKEN)
    
    # List folder contents
    try:
        response = dbx.files_list_folder(folder_path)
        files = [entry.name for entry in response.entries if isinstance(entry, dropbox.files.FileMetadata)]
        return files
    except dropbox.exceptions.ApiError as err:
        print(f"Error: {err}")
        return []
    
# Example usage
folder_path = '/jacq'  # Replace with your folder path in Dropbox
images = list_image_files(folder_path)

if images:
    print("Image files in the folder:")
    for image in images:
        print(image)
else:
    print("No image files found or an error occurred.")
