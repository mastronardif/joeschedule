#!/usr/bin/env python
from urllib.parse import parse_qs
import re
from sch00 import SCH_getSession
from sch00 import get_fn
from sch00 import get_form_data
from sch00 import SCH_ValidateFilename
from sch00 import set_session_cookie

from sch00 import SCH_getUniqueFN
import json
import xml.etree.ElementTree as E


def render_template(template, fn, data):
    from jinja2 import Template
    with open(template) as f:
        tmpl = Template(f.read())
    # print("Content-type: text/html\n")
    # print(data)
    print(tmpl.render(
        DESC=data['description'],
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

    # print(f"<br/>name len= {(len(names))}<br/>")
    # print(f"pics len= {(len(pics))}<br/>")

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

def redirect(url):
    print("Status: 302 Found")
    print(f"Location: {url}")
    print()

if __name__ == "__main__":
    request_uri, request_body, result = get_form_data()
    
    htmlname = result.get("url_params", {}).get("htmlname", ["dummy"])[0]
    xml_filename = result.get("url_params", {}).get("name", ["dummy"])[0] #'blank.xml'
    sessionID = result.get("url_params", {}).get("sessionID", [""])[0]

    if (sessionID):
        set_session_cookie(sessionID)
        # Remove sessionID from URL for redirect
        original_url = request_uri.split("?")[0]
        query_params = result.get("url_params", {})
        query_params.pop("sessionID", None)  # Remove sessionID from query params

        # Rebuild the query string without sessionID
        query_string = "&".join([f"{k}={v[0]}" for k, v in query_params.items()])

        # Redirect to the original URL without sessionID
        redirect(f"{original_url}?{query_string}")
        exit()

    print("Content-type: text/html\n") 

    fn = get_fn(xml_filename)
    fname = fn
    if fn == 'blank.xml':
        fname = f"{fn}.json"

    with open(fname, 'r') as json_file:
        ddddJson = json.load(json_file)
    
    render_template(htmlname, xml_filename, ddddJson['data'])
