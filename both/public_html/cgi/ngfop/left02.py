#!/usr/bin/env python
# import cgi
import logging
import urllib.parse
import os
from urllib.parse import parse_qs
import sys
import re
from sch00 import SCH_getSession
from sch00 import get_fn
from sch00 import SCH_ValidateFilename
from sch00 import SCH_getUniqueFN
import xmltodict
import json
import xml.etree.ElementTree as E

def convert_xml_to_json00(xml_string):
    try:
        # print('kkkkkkkkkkkkkkkkkkkkkkkk data_dict')
        # print(xml_string)
        # print('zzzzzzzzzzzzzzzzzzzzzzzzzz data_dict')
        # Convert XML to Python dictionary
        data_dict = xmltodict.parse(xml_string)
        # print(data_dict)
        
        # Convert Python dictionary to JSON
        json_data = json.dumps(data_dict, indent=2)
        
        return json_data
    except Exception as e:
        # print('EEEEEEEEEEEEEEEEEEEEEEEEEEE data_dict')
        # print(str(e))
        return str(e)

def convert_xml_to_json(xml_string):
    try:
        # Convert XML to Python dictionary using xmltodict
        data_dict = xmltodict.parse(xml_string)
        
        # Extract the required data structure from the dictionary
        data = {
            "data": {
                "description": data_dict["data"]["description"],
                "row": [
                    {"picture": row["picture"], "name": row["name"]}
                    for row in data_dict["data"]["row"]
                ]
            }
        }

        # Convert Python dictionary to JSON
        json_data = json.dumps(data, indent=2)
        
        return json_data
    except Exception as e:
        return str(e)

def convert_xml_to_json22(fn):
    tree = E.parse(fn)
    root = tree.getroot()
    d={}
    for child in root:
        if child.tag not in d:
            d[child.tag]=[]
        dic={}
        for child2 in child:
            if child2.tag not in dic:
                dic[child2.tag]=child2.text
        d[child.tag].append(dic)
    return(d)

def convert_xml_to_json33(fn):
    tree = E.parse(fn)
    root = tree.getroot()
    result = {"description": {}, "row": []}

    for child in root:
        if child.tag == "description":
            # Assuming there is only one "description" element
            result["description"] = child.text.strip()
        else:
            element_data = {}
            for child2 in child:
                element_data[child2.tag] = child2.text.strip()

            result["row"].append(element_data)

    return result

def render_template(template, fn, data):
    from jinja2 import Template
    with open(template) as f:
        tmpl = Template(f.read())
    # print("Content-type: text/html\n")
    # print(data)
    print(tmpl.render(
        FILENAME=fn,
        item_list=data #['data']
    ))

def get_form_data(request_url,  request_body):
    url_params = urllib.parse.parse_qs(request_url, keep_blank_values=True)
    
    formatted_url_params = {}
    for key, value in url_params.items():
        # Extract the parameter name from the key
        param_name = key.split('?')[-1]
        # Store the parameter name and its value in the formatted dictionary
        formatted_url_params[param_name] = value

    form_data = urllib.parse.parse_qs(request_body, keep_blank_values=True)

    data = {
        'url_params': formatted_url_params, ##dict(url_params),
        'form_data': dict(form_data)
    }

    # Serialize the dictionary to JSON
    json_data = json.dumps(data, indent=2)

    return json_data

def print_form_data():
    print("Content-type: text/html\n")

    # Get the CGI form data
    form = cgi.FieldStorage()

    # Print GET parameters
    print("<h2>GET Parameters:</h2>")
    for key in form.keys():
        values = form.getlist(key)
        for value in values:
            print(f"<p>{key}: {value}</p>")

    # Read POST data from stdin
    content_length = int(os.environ.get("CONTENT_LENGTH", 0))
    post_data = sys.stdin.read(content_length)

    # Parse POST data and print
    if post_data:
        print("<h2>POST Data:</h2>")
        for key, value in cgi.parse_qs(post_data).items():
            for item in value:
                print(f"<p>{key}: {item}</p>")

def list_files_with_filter(folder_path, filter_func=None):
    files_data = {
        "data": {
            "description": "file list",
            "row": []
        }
    }

    files = os.listdir(folder_path)
    
    # Apply filter function if provided
    if filter_func:
        files = [file for file in files if filter_func(file)]

    for file_name in files:
        file_path = os.path.join(folder_path, file_name)
        
        # Check if file is a JSON file
        if file_name.endswith('.json'):
            with open(file_path, 'r') as f:
                json_data = json.load(f)
                description = json_data['data']['description']
                
                # Add filename and description to the result
                files_data["data"]["row"].append({"fn": file_name, "name": description})
    
    logging.basicConfig(level=logging.DEBUG)
    logging.debug(files_data)
    return files_data



def list_files_with_filter00(folder_path, filter_func=None):    
    """
    List files in a folder based on a filter function.

    Parameters:
    - folder_path (str): Path to the folder.
    - filter_func (function): Filter function that takes a file name as input and returns True or False.

    Returns:
    - files (list): List of file names in the folder that pass the filter function.
    """
    # Get list of all files in the folder
    files = os.listdir(folder_path)
    
    # Apply filter function if provided
    if filter_func:
        files = [file for file in files if filter_func(file)]
    
    return files

if __name__ == "__main__":
    print("Content-type: text/html\n") 
    request_body = sys.stdin.read()
    request_uri = os.environ.get('REQUEST_URI')
    result = json.loads(get_form_data(request_uri, request_body))

    session = SCH_getSession()
    # print(session)
    # print_form_data()
    # query = 0 #cgi.FieldStorage()     
    # action    = '' ##result["url_params"]["action"][0] ##query.getvalue('action')
    htmlname = result.get("url_params", {}).get("htmlname", ["dummy"])[0]
    # html_name = result["url_params"]["htmlname"][0] ##query.getvalue('htmlname') or "./_____________editsch.htm"
    type = 'cb'
    xml_filename = 'blank.xml'

    # if "name" in result["form_data"]:
    #     xml_filename = result["form_data"]["name"][0]
    
    # if "type" in result["form_data"]:
    #     type = result["form_data"]["type"][0]
    

    # xml_filename = result.get("form_data", {}).get("name", ["blank.xml"])[0]
        
    # xml_filename = result["form_data"]["name"][0]     #query.getvalue('name') or "blankSchedule22" 
    # xml_filename = result["form_data"]["name"][0]
    # type         = result["form_data"]["type"][0] #query.getvalue('type')  or "cb"

    ## sw/
    # print("Content-type: text/html\n") 
    # if action == 'save':
    #     # wtfQuery()
    #     ##fh, filename = SCH_getUniqueFH(session['dir'], 'type_value')
    #     if xml_filename == 'blank.xml':
    #         xml_filename = SCH_getUniqueFN(session['dir'], type)
    #     saveList(result, query, session['dir'], xml_filename, type)
    #     # sys.exit()

    # session['dir']
    filtered_files = list_files_with_filter(session['dir'], lambda x: x.endswith(".json"))
    # print(filtered_files)

    # fn = get_fn(xml_filename)
    # fname = f"{fn}.json" 
    # with open(fname, 'r') as json_file:
    #     ddddJson = json.load(json_file)

     # append blank rows if edit

    # print("Content-type: text/html\n")
    # print(ddddJson)

    # data = convert_xml_to_json(xml_string)
    # dddd = convert_xml_to_json33(fn)
    # print(f"html_name: {html_name}<br/>")
    template = htmlname #'leftsch.htm.jinja' #get_template(html_name)

    render_template(template, xml_filename, filtered_files['data']['row'])
 	
    
    ################################
    # Write JSON data to the file
    # with open('./fuck.json', 'w') as json_file:
    #    json.dump(dddd, json_file, separators=(',', ': '))
    
    
    ################################
    print("<hr/><hr/>Debug<br/>")    
    # print(f"action: {action}<br/>")
    print(f"htmlname: {htmlname}<br/>")
    print(f"XML Filename: {xml_filename}<br/>")
    # print(f"fn: {fn}<br/>")
    # print(f"fname: {fname}<br/>")
    print(f"session: {session}<br/>")
    print("<br/>")
    
    # print(f"ddddJson: {ddddJson}<br/>")

    print("<hr/><hr/>Debug post data<br/>")  
    print (request_body)
    print (request_uri)
    # form_data = urllib.parse.parse_qs(request_body, keep_blank_values=True)
    # print (urllib.parse.parse_qs(request_body, keep_blank_values=True))
    print("<hr/><hr/>results<br/>") 
    print(result)

    print("<hr/><hr/>QUERY params BEGIN<br/>") 
    # action_value   = result["url_params"]["action"][0]
    htmlname_value = result["url_params"]["htmlname"][0]
    # print(f"action: {action_value}<br/>")
    print(f"html_name: {htmlname_value}<br/>")

    # xml_filename = result["form_data"]["name"][0]  
    xml_filename = result.get("form_data", {}).get("name", ["dummy"])[0]
  
    #type = result["form_data"]["type"][0]
    type = result.get("form_data", {}).get("type", ["cb"])[0]
    #d0 = result["form_data"]["d0"][0]
    d0 = result.get("form_data", {}).get("do", ["dummyname"])[0]
    print(f"xml_filename: {xml_filename}<br/>")
    print(f"type: {type}<br/>")
    print(f"d0: {d0}<br/>")
    print("<hr/><hr/>QUERY params END<br/>") 
