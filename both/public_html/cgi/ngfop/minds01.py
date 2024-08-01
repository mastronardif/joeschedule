#!/usr/bin/env python
# import cgi
import logging
from bs4 import BeautifulSoup
import urllib.parse
import os
from urllib.parse import parse_qs
import sys
import re
#from sch00 import SCH_getSession
#from sch00 import get_fn
from sch00 import get_form_data
#from sch00 import SCH_ValidateFilename
#from sch00 import SCH_getUniqueFN
#from sch00 import SCH_deleteFile
import json

logging.basicConfig(level=logging.DEBUG)

def handle_request():
    request_body = sys.stdin.read()
    request_uri = os.environ.get('REQUEST_URI', '')
    
    # Parse URL parameters (if any)
    # url_params = urllib.parse.parse_qs(request_uri, keep_blank_values=True)
    url_params = urllib.parse.parse_qs(urllib.parse.urlparse(request_uri).query, keep_blank_values=True)
    
    
    # Format URL parameters into a dictionary with single values
    formatted_url_params = {key: value[0] for key, value in url_params.items()}
    
    # Parse form data
    form_data = urllib.parse.parse_qs(request_body, keep_blank_values=True)
    
    # Format form data into a dictionary with single values
    formatted_form_data = {key: value[0] for key, value in form_data.items()}
    
    # Combine formatted URL parameters and form data
    data = {
        'url_params': formatted_url_params,
        'form_data': formatted_form_data
    }
    
    logging.debug(f"ZZZZZZZZZZZZZ  data: {data}")

    return (data)

def handle_request00():
    # Read the request body
    request_body = sys.stdin.read()
    logging.debug(f"Raw request body: {request_body}")
    
    if not request_body:
        logging.error("Received empty request body.")
        return None  # Indicate an error occurred

    try:
        # Parse JSON data
        form_data = json.loads(request_body)
    except json.JSONDecodeError as e:
        logging.error(f"JSON Decode Error: {e}")
        return None  # Indicate an error occurred

    logging.debug(f"Form Data: {form_data}")
    return form_data

def handle_requestAA():
    #request_uri, request_body, result = get_form_data()
    request_uri, request_body, result = get_form_data22()
    logging.debug(f"result: {result}")
    # Get form data as a dictionary
    #form_data = {key: form.getvalue(key) for key in form.keys()}
    return result["form_data"]


def extract_form_data(file_path):
    """
    Extracts the HTML content between <form> tags from the specified file.

    Args:
    file_path (str): The path to the HTML file.

    Returns:
    str: The HTML content between the <form> tags, or an empty string if no <form> tag is found.
    """
    try:
        # Open and read the HTML file
        with open(file_path, 'r', encoding='utf-8') as file:
            html_content = file.read()
        #logging.debug(f"ZZZZZZZZZZ html_content {html_content}")
        # Parse the HTML content using BeautifulSoup
        soup = BeautifulSoup(html_content, 'html.parser')
        
        # Find the first <form> tag
        form_tag = soup.find('form')
        
        # Return the HTML content inside the <form> tag
        if form_tag:
            return str(form_tag)  # Convert BeautifulSoup tag to string
        else:
            return ""
    
    except FileNotFoundError:
        print(f"Error: The file {file_path} was not found.")
        return ""
    except Exception as e:
        print(f"An error occurred: {e}")
        return ""

def push_form_data(in_file_path, updated_form_html, out_file_path):
    try:
        with open(in_file_path, 'r') as file:
            html_content = file.read()

        # Find the start and end of the <form> tags
        form_start = html_content.find('<form')
        form_end = html_content.find('</form>', form_start) + len('</form>')

        if form_start == -1 or form_end == -1:
            raise ValueError("No <form> tags found in the HTML file.")

        # Extract the part before and after the <form> tags
        before_form = html_content[:form_start]
        after_form = html_content[form_end:]

        # Construct the new HTML content
        new_html_content = f"{before_form}{updated_form_html}{after_form}"

        # Write the new HTML content to the output file
        with open(out_file_path, 'w') as file:
            file.write(new_html_content)

        print(f"Updated HTML written to {out_file_path}")

    except Exception as e:
        print(f"An error occurred: {e}")

def update_form_fields(soup, form_data):
    # Update the form fields with data from form_data
    for name, value in form_data.items():
        # Handle text inputs and textareas
        input_element = soup.find('input', {'name': name})
        if input_element:
            if input_element.get('type') == 'checkbox':
                #logging.debug(f"Updating checkbox '{name}' to ___")
                # Handle checkboxes
                if value in ['on', 'checked', 'true', '1']:
                    input_element['checked'] = 'checked'
                else:
                    if 'checked' in input_element.attrs:
                        del input_element['checked']  # Remove 'checked' attribute if not checked                        
            else:
                # Handle other input types
                input_element['value'] = value
                #logging.debug(f"Updating input with name '{name}' to value: {value}")

        textarea_element = soup.find('textarea', {'name': name})
        if textarea_element:
            #logging.debug(f"Updating textarea with name '{name}' to value: {value}")
            textarea_element.string = value  
            
    # Handle unchecked checkboxes (behave defferent from oter inputs)
    all_checkboxes = soup.find_all('input', {'type': 'checkbox'})
    for checkbox in all_checkboxes:
        name = checkbox.get('name')
        if name not in form_data:
            # If the checkbox is not in form_data, make sure it is unchecked
            if 'checked' in checkbox.attrs:
                del checkbox['checked']


if __name__ == "__main__":
    inputs = handle_request()

logging.debug(f"ZZZZZZZZZZZZZ  inputs: {inputs}")    

form_data = inputs["form_data"] 
formid =  inputs["url_params"] ["formid"]
logging.debug(f"ZZZZZZZZZZZZZ  form: {formid}")    
logging.debug(f"ZZZZZZZZZZZZZ  ooooo: {form_data}")    

request_uri, request_body, result = get_form_data()

print("Content-type: text/html\n")  # CGI header
print("<html><head><title>Hello Python CGI</title></head><body>")
print("<h1>Hello, Python World!</h1>")
print("<hr/><hr/>Debug post data<br/>"
)  
print("<br/>request_body<br/>")
print (request_body)
print("<br/>request_uri<br/>")
print (request_uri)

print("<br/>form_data")
print("<br/>form_data<br/>")
print (form_data)

# in_file_path = "./minds/GR-6900134(3-22).html" 
# out_file_path = "./minds/out_GR-6900134(3-22).html" 
in_file_path  = f"./minds/{formid}.html"
out_file_path = f"./minds/out_{formid}.html" 
   
form_html = extract_form_data(in_file_path) 
 
soup = BeautifulSoup(form_html, 'html.parser')
update_form_fields(soup, form_data)

# Convert the updated soup object back to HTML
updated_form_html = str(soup)
#logging.debug(f"updated_form_html= {updated_form_html}")   
push_form_data(in_file_path, updated_form_html, out_file_path)
    
print("</body></html>")