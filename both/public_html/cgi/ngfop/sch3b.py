#!/usr/bin/env python
# import cgi
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


def render_template(template, fn, data):
    from jinja2 import Template
    with open(template) as f:
        tmpl = Template(f.read())
    # print("Content-type: text/html\n")
    # print(data)
    print(tmpl.render(
        FILENAME=data['description'],
        item_list=data #['data']
    ))

def get_template(html_name):
    # Use an if-else statement to determine the template based on html_name
    if html_name == 'editschhead3a.htm':
        return 'editschhead3a.htm'
    elif html_name == 'editsch3a.htm':
        return 'editsch3a.htm'
    else:
        # Default template if no match
        return 'default_template.jinja'

    # # form = query
    # print("<hr/><hr/>Debug: begin begin <br/>")
    # # Print the name of each field
    # for field in query.keys():
    #     print(field)

    # # Print the value of each field
    # for field in query.keys():
    #     print({query[field].value})
    # print("<hr/><hr/>Debug: lplplplplplpl <br/>")

    description = postData["form_data"]["d0"][0] ##query.getvalue('d0')   
    # action = query.getvalue('action')    
    # xml_filename = query.getvalue('name') or "blankSchedule" 

    # Taint check
    root = re.match(r'(.+)', root).group(1) if re.match(r'(.+)', root) else "ot oh!"
    
    retval, fn = SCH_ValidateFilename(fn)
    if not retval:
        print("<hr/><hr/>Debug: SCH_ValidateFilename FAILED!!!<br/>")
        return
    
    # pics = data["form_data"]["HR55"][0]   ##query.getlist('HR55')
    pics = postData["form_data"].get("HR55", [])
    # names = data["form_data"]["R55"][0] #query.getlist('R55')
    names = postData["form_data"].get("R55", [])

    print(f"<br/>name len= {(len(names))}<br/>")
    print(f"pics len= {(len(pics))}<br/>")

    data = {
        "data": {
            "description": description,
            "row": []
        }
    }

    for pic, name in zip(pics, names):
        if pic or name:  # Check if either pic or name is not empty
            if pic and not name:  # Check if pic is not empty and name is empty
                data["data"]["row"].append({"picture": pic})
            elif name and not pic:  # Check if name is not empty and pic is empty
                data["data"]["row"].append({"name": name})
            else:
                data["data"]["row"].append({"picture": pic, "name": name})


    # for pic, name in zip(pics, names):        
    #     if pic and not name:  # Check if pic is not empty and name is empty
    #         data["data"]["row"].append({"picture": pic})
    #     elif name and not pic:  # Check if name is not empty and pic is empty
    #         data["data"]["row"].append({"name": name})
    #     else:
    #         data["data"]["row"].append({"picture": pic, "name": name})        

    fname = f"{root}{fn}.json"
    with open(fname, 'w') as json_file:
        json.dump(data, json_file, indent=2)

    json_data = json.dumps(data, indent=2)
    # print(json_data)
    # print(fname)

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
    xml_filename = result.get("url_params", {}).get("name", ["dummy"])[0] #'blank.xml'

    # session['dir']

    fn = get_fn(xml_filename)
    fname = fn
    if fn == 'blank.xml':
        fname = f"{fn}.json"  # fname = f"{fn}.json" 

    with open(fname, 'r') as json_file:
        ddddJson = json.load(json_file)
    
    # template = get_template(htmlname)
    render_template(htmlname, xml_filename, ddddJson['data'])

    
	
    
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
    print(f"fname: {fname}<br/>")
    print(f"session: {session}<br/>")
    print("<br/>")
    
    print(f"ddddJson: {ddddJson}<br/>")

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

