#!/usr/bin/env python
import os
import json

# Load configuration from config.json
def load_config(config_file='config.json'):
    with open(config_file, 'r') as file:
        return json.load(file)

# List all image files in the specified folder
def list_image_files(download_folder):
    image_extensions = ('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff')
    image_files = [f for f in os.listdir(download_folder) if f.lower().endswith(image_extensions)]
    return image_files

# Create a JSON structure for the images
def create_image_json(image_files, domain, domainpath, download_folder):
    json_data = {
        "data": {
            "description": "My Pics",
            "row": [
                {
                    "picture": f"{domain}/{domainpath}/{download_folder}/{image_file}"
                } for image_file in image_files
            ]
        }
    }
    return json_data

# Save the JSON to a file
def save_json(data, download_folder):
    output_file=f"{download_folder}/mypics.json"
    with open(output_file, 'w') as file:
        json.dump(data, file, indent=4)
    print(f"JSON data saved to {output_file}")

# Main function to create the JSON file of image URLs
if __name__ == '__main__':
    try:
        # Load the configuration
        config = load_config()

        # List image files from the download folder
        image_files = list_image_files(config['download_folder'])

        # Create the JSON data
        json_data = create_image_json(image_files, config['mydomain'], config['domain_path'], config['download_folder'])

        # Save the JSON to a file
        save_json(json_data, config['download_folder'])

    except Exception as e:
        print(f"Error: {e}")
