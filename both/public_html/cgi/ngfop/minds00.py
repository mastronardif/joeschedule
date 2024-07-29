#!/usr/bin/env python
# import cgi
import logging
from bs4 import BeautifulSoup
import urllib.parse
import sys
import os
import json
#from sch00 import get_form_data


# from urllib.parse import parse_qs
# import sys
# import re

# import json

# ttp://localhost:8080//cgi-bin/cgi/ngfop/minds00.py?formID=234
logging.basicConfig(level=logging.DEBUG)
in_file_path = "./minds/GR-6900134(3-22).html"  
    
def handle_request():
    """ Handle the request and print form data. """
    # Read the query string from environment variable
    query_string = os.environ.get('QUERY_STRING', '')

    # Parse query string into dictionary
    form_data = urllib.parse.parse_qs(query_string)

    logging.debug(f"Form Data: {form_data}")

    # Access individual parameters
    form_id = form_data.get('formid', [''])[0]  # Get the first value if it exists, default to empty string
    case_id = form_data.get('caseid', [''])[0]
    
    params = {
        'formid': form_id,
        'caseid': case_id
    }

    return params

def serve_html_file(file_path):
    # Check if the file exists
    if not os.path.isfile(file_path):
        print("Content-type: text/html\n")
        print("<html><body><h1>File not found</h1></body></html>")
        return

    # Read the HTML file content
    with open(file_path, 'r') as file:
        content = file.read()

    # Set the content type to HTML
    print("Content-type: text/html\n")
    print(content)


if __name__ == "__main__":
    params = handle_request()
    #logging.debug(f"params: {json.dumps(params, indent=2)}")
    
    in_file_path = "./minds/GR-6900134(3-22).html" 
    out_file_path = "./minds/out_GR-6900134(3-22).html"
    
    if params['caseid']  == "out":
        in_file_path = out_file_path
    
    #send_file(in_file_path)
    serve_html_file(in_file_path)


    