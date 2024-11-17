#!/usr/bin/python
from sch00 import get_form_data
from sch00 import SCH_getSession
import urllib.request
import logging
import os
from jinja2 import Template

def render_template(template, fn, data, **kwargs):
    with open(template) as f:
        tmpl = Template(f.read())
    print(tmpl.render(
        FILENAME=fn,
        item_list=data,
        **kwargs
    ))

def list_media_files(download_folder):
    # Include both image and video extensions
    image_extensions = ('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff')
    video_extensions = ('.mp4', '.mov', '.avi', '.mkv', '.wmv')
    media_files = {'images': [], 'videos': []}

    # Separate images and videos based on their extensions
    for f in os.listdir(download_folder):
        if f.lower().endswith(image_extensions):
            media_files['images'].append(f)
        elif f.lower().endswith(video_extensions):
            media_files['videos'].append(f)
    
    return media_files

logging.basicConfig(level=logging.DEBUG)
config = {
  "download_folder": "members/Bucci/mypics",
  "mydomain": "https://joeschedule.com",
  "domain_path": "cgi/ngfop"
}

# Get parameters from CGI
request_uri, request_body, result = get_form_data()
jsquery = '' # result["url_params"]["jsquery"][0]

idx = result["url_params"].get("idx", [""])[0]
html_name = result["url_params"].get("htmlname", ["lwpyahoo.jinja.htm"])[0]
session = SCH_getSession()
MyPicFolder = 'mypics'
folder = f"{session['dir']}/{MyPicFolder}"

# List images and videos in the folder
media_files = list_media_files(folder)
image_files = media_files['images']
video_files = media_files['videos']

logging.debug(image_files)
logging.debug(video_files)

domain = config['mydomain']
domainpath = config['domain_path']

# Construct JSON data with both images and videos
json_data = {
    "data": {
        "description": "My Pics and Videos",
        "row": [
            {"picture": f"{domain}/{domainpath}/{folder}/{image_file}"} for image_file in image_files
        ] + [
            {"video": f"{domain}/{domainpath}/{folder}/{video_file}"} for video_file in video_files
        ]
    }
}

logging.debug(json_data)

media_urls = [item['picture'] if 'picture' in item else item['video'] for item in json_data['data']['row']]

print("")

logging.debug(session)
fdesc = session['id']  # session['id']

render_template(html_name, fdesc, media_urls, jsquery=jsquery, idx=idx)
