#!/usr/bin/env python
import cgi
import urllib.parse
import os
from urllib.parse import parse_qs
import sys
import re
from sch00 import get_session
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

def get_template(html_name):
    # Use an if-else statement to determine the template based on html_name
    if html_name == 'editschhead3a.htm':
        return 'editschhead3a.htm'
    elif html_name == 'editsch3a.htm':
        return 'editsch3a.htm'
    else:
        # Default template if no match
        return 'default_template.jinja'

def saveList(postData, query, root, fn, type):
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

def wtfQuery():

    form = cgi.FieldStorage()

    # Print the name of each field
    for field in form.keys():
        print(field)

    # Print the value of each field
    for field in form.keys():
        print(form[field].value)

    query_string = os.environ.get("QUERY_STRING", "")
    print("<hr/><hr/>Debug: BEGIN <br/>")
    print(f"query_string: {query_string}<br/>")

    content_length = int(os.environ.get("CONTENT_LENGTH", 0))
    post_data = sys.stdin.read(content_length)
    print("POST data:")
    print(post_data)
    print("<hr/><hr/>Debug: END <br/>")

def get_form_data(request_url,  request_body):
    url_params = urllib.parse.parse_qs(request_url, keep_blank_values=True)
    
    formatted_url_params = {}
    for key, value in url_params.items():
        # Extract the parameter name from the key
        param_name = key.split('?')[-1]
        # Store the parameter name and its value in the formatted dictionary
        formatted_url_params[param_name] = value
    
    # Parse form data
    form_data = urllib.parse.parse_qs(request_body, keep_blank_values=True)

    # Construct a dictionary to hold the data
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
        
if __name__ == "__main__":
    print("Content-type: text/html\n") 
    request_body = sys.stdin.read()
    request_uri = os.environ.get('REQUEST_URI')
    # result = get_form_data(request_uri, request_body)
    result = json.loads(get_form_data(request_uri, request_body))

    session = get_session()
    # print(session)
    # print_form_data()
    query = 0 #cgi.FieldStorage()     
    action    = result["url_params"]["action"][0] ##query.getvalue('action')
    html_name = result["url_params"]["htmlname"][0] ##query.getvalue('htmlname') or "./_____________editsch.htm"
    type = 'cb'
    xml_filename = 'blank.xml'

    if "name" in result["form_data"]:
        xml_filename = result["form_data"]["name"][0]
    
    if "type" in result["form_data"]:
        type = result["form_data"]["type"][0]
    

    # xml_filename = result.get("form_data", {}).get("name", ["blank.xml"])[0]
        
    # xml_filename = result["form_data"]["name"][0]     #query.getvalue('name') or "blankSchedule22" 
    # xml_filename = result["form_data"]["name"][0]
    # type         = result["form_data"]["type"][0] #query.getvalue('type')  or "cb"

    ## sw/
    # print("Content-type: text/html\n") 
    if action == 'save':
        # wtfQuery()
        ##fh, filename = SCH_getUniqueFH(session['dir'], 'type_value')
        if xml_filename == 'blank.xml':
            xml_filename = SCH_getUniqueFN(session['dir'], type)
        saveList(result, query, session['dir'], xml_filename, type)
        # sys.exit()

    fn = get_fn(xml_filename)
    fname = f"{fn}.json" 
    with open(fname, 'r') as json_file:
        ddddJson = json.load(json_file)

     # append blank rows if edit

    # print("Content-type: text/html\n")
    # print(ddddJson)

    # data = convert_xml_to_json(xml_string)
    # dddd = convert_xml_to_json33(fn)
    # print(f"html_name: {html_name}<br/>")
    template = get_template(html_name)
    # render_template(template, xml_filename, dddd)
    render_template(template, xml_filename, ddddJson['data'])

    
	
    
    ################################
    # Write JSON data to the file
    # with open('./fuck.json', 'w') as json_file:
    #    json.dump(dddd, json_file, separators=(',', ': '))
    
    
    ################################
    print("<hr/><hr/>Debug<br/>")    
    print(f"action: {action}<br/>")
    print(f"html_name: {html_name}<br/>")
    print(f"XML Filename: {xml_filename}<br/>")
    print(f"fn: {fn}<br/>")
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
    action_value   = result["url_params"]["action"][0]
    htmlname_value = result["url_params"]["htmlname"][0]
    print(f"action: {action_value}<br/>")
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


    R55 = result.get("form_data", {}).get("R55", ["r55555"])[0]
    #  html_name = query.getvalue('htmlname') or "./_____________editsch.htm"
    # xml_filename = query.getvalue('name') or "blankSchedule22" 
    # type         = query.getvalue('type')  or "cb"
    # print(result["form_data"]["R55"])
    # complex_key_value = result["url_params"]["/cgi-bin/cgi/ngfop/editsch3a.py?action"]
    # action_value = complex_key_value[0]
    # action_value = result["url_params"]["action"][0]
    # type_value   = result["url_params"]["type"]
    # name_value   = result["url_params"]["name"]
    # htmlname_value=result["url_params"]["htmlname"]
    # print("<hr/><hr/>QUERY  params<br/>") 
    # print(f"action_value: {action_value}<br/>")
    # print(f"htmlname_value: {html_name}<br/>")
    print("<hr/><hr/>QUERY params END<br/>") 

    # print(result["<br/>form_data"]["d0"])
    # print(result["<br/>form_data"]["R55"])
    print (R55)
    # print(result["<br/>form_data"]["HR55"])

    #print(xml_string)
    # print(json.dumps(data, indent=2))  # Print the data dictionary with indentation

    # message = get_session()
    # print(message)

    # tree = E.parse(fn)
    # root = tree.getroot()
    # d={}
    # for child in root:
    #     if child.tag not in d:
    #         d[child.tag]=[]
    #     dic={}
    #     for child2 in child:
    #         if child2.tag not in dic:
    #             dic[child2.tag]=child2.text
    #     d[child.tag].append(dic)
    # print(d)

    # print("<br/>")
