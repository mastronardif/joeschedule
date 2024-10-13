#!/usr/bin/python
from sch00 import get_form_data
from sch00 import SCH_getSession
import urllib.request
from html.parser import HTMLParser
import logging
import os

def render_template(template, fn, data, **kwargs):
    from jinja2 import Template
    with open(template) as f:
        tmpl = Template(f.read())
    # print("Content-type: text/html\n")
    # print(data)
    print(tmpl.render(
        FILENAME=fn,
        item_list=data,
        **kwargs 
    ))

def list_image_files(download_folder):
    image_extensions = ('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff')
    image_files = [f for f in os.listdir(download_folder) if f.lower().endswith(image_extensions)]
    return image_files


logging.basicConfig(level=logging.DEBUG)
config = { "download_folder": "members/Bucci/mypics",
  "mydomain": "https://joeschedule.com",
  "domain_path": "cgi/ngfop"
}

# Get parameters from CGI
request_uri, request_body, result = get_form_data()
jsquery    = '' #result["url_params"]["jsquery"][0]

idx = result["url_params"].get("idx", [""])[0]
# html_name = result["url_params"]["htmlname"][0] 
html_name = result["url_params"].get("htmlname", ["lwpyahoo.jinja.htm"])[0]
session = SCH_getSession()
MyPicFolder = 'mypics'
folder = f"{session['dir']}/{MyPicFolder}"
# Construct URL
# list images in folder see ____.py file.
image_files = list_image_files(folder)
logging.debug(image_files)
domain =config['mydomain']
domainpath = config['domain_path']\
# download_folder = config['download_folder']
json_data = {
        "data": {
            "description": "My Pics",
            "row": [
                {
                    "picture": f"{domain}/{domainpath}/{folder}/{image_file}"
                } for image_file in image_files
            ]
        }
    }
logging.debug(json_data)

image_urls = [item['picture'] for item in json_data['data']['row']]
# logging.debug(image_urls)

print("")

logging.debug(session)
fdesc = session['id'] #session['id']

render_template(html_name, fdesc, image_urls, jsquery=jsquery, idx=idx)
