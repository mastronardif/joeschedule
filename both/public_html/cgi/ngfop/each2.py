#!/usr/bin/env python
# import cgi
import logging
from bs4 import BeautifulSoup
import urllib.parse
# import os
from urllib.parse import parse_qs
import sys
import re
#from sch00 import SCH_getSession
#from sch00 import get_fn
import os
from sch00 import get_form_data
#from sch00 import SCH_ValidateFilename
#from sch00 import SCH_getUniqueFN
#from sch00 import SCH_deleteFile
# import xmltodict
import json
import xml.etree.ElementTree as E

logging.basicConfig(level=logging.DEBUG)

def get_form_data22():
    request_body = sys.stdin.read()
    request_uri = os.environ.get('REQUEST_URI')
    
    # Parse URL parameters (if any)
    url_params = urllib.parse.parse_qs(request_uri, keep_blank_values=True)
    
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
    
    # Serialize the dictionary to JSON
    json_data = json.dumps(data, indent=2)
    json_data = json.loads(json_data)

    return (request_uri, request_body, json_data)



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

def handle_request():
    #request_uri, request_body, result = get_form_data()
    request_uri, request_body, result = get_form_data22()
    logging.debug(f"aaaaaaaaaaaaaaaaa result: {result}")
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
        logging.debug(f"ZZZZZZZZZZ extract_form_data {file_path}")
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
    """
    Replaces the content between <form> tags in the file at file_path
    with updated_form_html and writes the result to out_file_path.

    :param file_path: Path to the input HTML file.
    :param updated_form_html: HTML content to replace inside the <form> tags.
    :param out_file_path: Path to the output HTML file.
    """
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
   

if __name__ == "__main__":
    ooooo = handle_request() 
     
logging.debug(f"aaaaaaaaaaaaaaaaa ooooo: {ooooo}")

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

print("<br/>ooooo")
print("<br/>form_data<br/>")
print (ooooo)
#print(json.dumps(ooooo, indent=2))

#jobjAA = {
#    "t101": "XXXXXXXXXXXXXXX YOUVE BEEN UPDATED",
#    "client": "Miss. Asswipes",
#    "dob": "",
#    "date": "",
#    "therapist": "",
#    "time_in": "",
#    "time_out": "",
#    "duration": "",
#    "location": ""
#}

in_file_path = "./minds/GR-6900134(3-22).html"  
out_file_path = "./minds/out_GR-6900134(3-22).html"  
   
form_html = extract_form_data(in_file_path) 
#logging.debug(f"ZZZZZZZZZZ form_html= {form_html}")

 
jobj = ooooo
logging.debug(f"jobj= {jobj}")
html_string = """
<form id="myForm" action="http://localhost:8080/cgi-bin/cgi/ngfop/each2.py" method="POST">
    <div class="container">
        <div class="header">
            <h2>DCC Treatment Note: Play Therapy Session</h2>
            <div>
                <span class="label">Client:</span>
                <span class="input"><input type="text" name="client" id="client123" value="John Doe"></span>
                <span class="label">D.O.B:</span>
                <span class="input"><input type="date" name="dob" placeholder="1/1/12"></span>
            </div>
            <div>
                <span class="label">Date:</span>
                <span class="input"><input type="date" name="date" placeholder="8/30/21"></span>
                <span class="label">Therapist:</span>
                <span class="input"><input type="text" name="therapist" placeholder="Phelps Johnston"></span>
            </div>
            <div>
                <span class="label">Time in:</span>
                <span class="input"><input type="time" name="time_in" placeholder="2:00pm"></span>
                <span class="label">Time out:</span>
                <span class="input"><input type="time" name="time_out" placeholder="3:50pm"></span>
                <span class="label">Duration:</span>
                <span class="input"><input type="text" name="duration" placeholder="1 hr, 50 min"></span>
            </div>
            <div>
                <span class="label">Location:</span>
                <span class="input"><input type="text" name="location" placeholder="Client Home"></span>
            </div>
        </div>
    </div>
    
     <table>
            <tbody><tr>
                <th>Developmental Level/ Focus Area</th>
                <th>Goal</th>
                <th>+/-</th>
                <th>Comments</th>
            </tr>
            <tr>
                <td rowspan="">1. Regulation</td>
                <td class="goal">John will increase ability to maintain self-regulation (calm and organized state/remain calm and organized while participating in a pleasurable activity alone or with someone else) for 15 minutes. Currently he is able to remain self-regulated for 5 minutes.</td>
                <td></td>
                <td><textarea name="t101" id="t101">UPDATE ME</textarea></td>
            </tr>
        </tbody></table>
    <button type="submit">Submit</button>
    <footer>
        <span id="formID">GR-6900134 (3-22) </span>
    </footer>
    <input type="button" value="Submit" onclick="submitForm()">
</form>
"""


#form_html = html_string
form_data = jobj #"{}"
soup = BeautifulSoup(form_html, 'html.parser')
#logging.debug(f"soup= {soup}")

# Update the form fields with data from form_data
for name, value in form_data.items():
    input_element = soup.find('input', {'name': name})
    if input_element:
        input_element['value'] = value
        
    textarea_element = soup.find('textarea', {'name': name})
    if textarea_element:
        logging.debug(f"Updating textarea with name '{name}' to value: {value}")
        textarea_element.string = value

# Convert the updated soup object back to HTML
updated_form_html = str(soup)
#logging.debug(f"updated_form_html= {updated_form_html}")   
push_form_data(in_file_path, updated_form_html, out_file_path)
    
print("</body></html>")