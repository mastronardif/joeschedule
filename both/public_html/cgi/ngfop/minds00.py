#!/usr/bin/env python
# import cgi
import logging
from bs4 import BeautifulSoup
import urllib.parse
import sys
import os
import json
from mindsutilitys import set_form_inputs
from mindsutilitys import extract_form_data
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

    form_html = extract_form_data(file_path) 
    logging.debug(f"form_html 00= {form_html}") 
    with open("000.html", 'w') as file:
        file.write(form_html)  

    # Change the input fields to have unique id's
    form_html  = set_form_inputs(form_html)

    logging.debug(f"form_html 22= {form_html }")
    with open("111.html", 'w') as file:
        file.write(form_html)  

    
        # Extract the part before and after the <form> tags
                # Find the start and end of the <form> tags
        form_start = content.find('<form')
        form_end   = content.find('</form>', form_start) + len('</form>')

        before_form = content[:form_start]
        after_form = content[form_end:]

        # Construct the new HTML content
        new_html_content = f"{before_form}{form_html}{after_form}"

        # a cheesey technique for now.
        with open(file_path, 'w') as file:
            file.write(new_html_content)  

    ########

    # Set the content type to HTML
    print("Content-type: text/html\n")
    print(new_html_content)

def get_form_name(formid):
    # lookup

    return f"./minds/{formid}.html"


if __name__ == "__main__":
    params = handle_request()
    formid = params['formid']
    #logging.debug(f"params: {json.dumps(params, indent=2)}")
    # in_file_path = "./minds/GR-6900134(3-22).html" 
    in_file_path  = f"./minds/{formid}.html"
    out_file_path = f"./minds/out_{formid}.html" 
    
    if params['formid']:
        in_file_path = get_form_name(params['formid'])    
    
    # out_file_path = "./minds/out_GR-6900134(3-22).html"
    
    if params['caseid']  == "out":
        in_file_path = out_file_path
    
    #send_file(in_file_path)
    serve_html_file(in_file_path)


    