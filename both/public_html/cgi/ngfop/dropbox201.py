#!/usr/bin/env python
import dropbox
import json

# Your Dropbox API credentials
ACCESS_TOKEN = 'sl.B95PzEf1vGaiz3cEktL9Duj5Moti2yB5ccXzxRHCmcSVvh5htSuvVTohG-IASWvBoGSIkpoyFDNXSSCso1TAtTAk-rC1872tSq9-Q3H5vzY4XIa_-jO03SqBmQklQ5wBfQXt66fsLxa3QyE'  # Replace with your actual access token
folder_path = '/jacq/reflecting.oo3'  #'/Gutstein stuff'  # '/jacq' Replace with your folder path in Dropbox
folder_pathRoot = ''  # Root path or specify a folder
dbx = dropbox.Dropbox(ACCESS_TOKEN)

# Function to list available folders
def list_folders(path):
    try:
        response = dbx.files_list_folder(path)
        folders = []

        for entry in response.entries:
            if isinstance(entry, dropbox.files.FolderMetadata):
                folders.append({"folder_name": entry.name, "path": entry.path_lower})

        return folders
    except dropbox.exceptions.ApiError as e:
        print(f"Error: {e}")
        return None

# Function to list image files and generate direct download links
def get_or_create_shared_link(path):
    try:
        # First check if a shared link already exists
        result = dbx.sharing_list_shared_links(path=path)

        if result.links:
            # If a shared link exists, return the direct download link
            return result.links[0].url.replace('&dl=0', '&dl=1')
        else:
            # If no shared link exists, create a new one
            shared_link = dbx.sharing_create_shared_link_with_settings(path)
            return shared_link.url.replace('&dl=0', '&dl=1')
    except dropbox.exceptions.ApiError as e:
        print(f"Error: {e}")
        return None

# List folder contents and get shared links for each image file
if  False:
    response = dbx.files_list_folder(folder_path)
    images = []

    for entry in response.entries:
        if isinstance(entry, dropbox.files.FileMetadata):
            url = get_or_create_shared_link(entry.path_lower)
            if url:
                # Append the JSON object for each image
                images.append({"picture": url})

    # Print the list of image links as a JSON array
    print(json.dumps(images, indent=2))

if True:
    # List folders at the specified path (root if left blank)
    folders = list_folders(folder_path)

    # Print the list of folders as a JSON array
    if folders:
        print(json.dumps(folders, indent=2))
    else:
        print("No folders found or access error.")
