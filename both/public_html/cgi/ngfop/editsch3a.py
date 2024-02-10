#!/usr/bin/env python
import cgi
import sys
import re
from sch00 import get_session
from sch00 import get_fn
from sch00 import SCH_ValidateFilename
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

def saveList(query, root, fn, type):
    description = query.getvalue('d0')   
    # action = query.getvalue('action')    
    # xml_filename = query.getvalue('name') or "blankSchedule" 

    # Taint check
    root = re.match(r'(.+)', root).group(1) if re.match(r'(.+)', root) else "ot oh!"
    
    retval, fn = SCH_ValidateFilename(fn)
    if not retval:
        print("<hr/><hr/>Debug: SCH_ValidateFilename FAILED!!!<br/>")
        return
    
    pics = query.getlist('HR55')
    names = query.getlist('R55')

    data = {
        "data": {
            "description": description,
            "row": []
        }
    }
    # Add pictures and names to the "row" list
    for pic, name in zip(pics, names):
        data["data"]["row"].append({"picture": pic, "name": name})

    fname = f"{root}{fn}.json"
    with open(fname, 'w') as json_file:
        json.dump(data, json_file, indent=2)

    json_data = json.dumps(data, indent=2)
    # print(json_data)
    # print(fname)


def save(query,dir, fn, type):
    print("Content-type: text/html\n") 
    print("<hr/><hr/>Debug<br/>")
   
    description = query.getvalue('d0')   
    action = query.getvalue('action')    
    xml_filename = query.getvalue('name') or "blankSchedule" 

    print(f"action: {action}<br/>")
    print(f"description: {description}<br/>")   
    print(f"xml_filename: {xml_filename}<br/>")
    
        # Get the CGI form data
    # form = cgi.FieldStorage()

    # Get the values for 'HR55' parameter
    pics = query.getlist('HR55')
    names = query.getlist('R55')

    # Construct the JSON structure
    data = {
        "data": {
            "description": description,
            "row": []
        }
    }
    # Add pictures and names to the "row" list
    for pic, name in zip(pics, names):
        data["data"]["row"].append({"picture": pic, "name": name})
    
    # Convert dictionary to JSON
    json_data = json.dumps(data, indent=2)
    print(json_data)

    # Print the values
    # print("<br/>")
    # print("picture:", pics)
    # print("<br/>")
    # print("<br/>")
    # print("name:", names)


        
if __name__ == "__main__":
    session = get_session()
    # print(session)
    query = cgi.FieldStorage()     
    action = query.getvalue('action')
    html_name = query.getvalue('htmlname') or "./_____________editsch.htm"
    xml_filename = query.getvalue('name') or "blankSchedule" 
    type         = query.getvalue('type')

    ## sw/
    print("Content-type: text/html\n") 
    if action == 'save':
        saveList(query, session['dir'], xml_filename, type)
        # sys.exit()

    fn = get_fn(xml_filename)
    fname = f"{fn}.json" 
    with open(fname, 'r') as json_file:
        ddddJson = json.load(json_file)

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
