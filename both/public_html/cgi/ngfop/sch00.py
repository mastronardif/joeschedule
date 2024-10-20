# mylib.py
import urllib.parse
import json
import logging
import datetime
from http import cookies
import os
import re
import sys
import time

logging.basicConfig(level=logging.DEBUG)

def SCH_ErrorMessage(msg):
    print("Content-type: text/html\n\n")
    print(f"FM, The server can't! {msg}.\n")
    exit()

def SCH_getUniqueFH(root, type):
    # Calculate unique filename based on current time
    unq = int(time.time()) - 1073353928
    fn = f"{root}{type}{unq}.xml"

    # Fix potential tainting issues (not applicable in Python)
    # This section can be removed in Python

    # Open the file in append mode and return the file handle and filename
    try:
        log_file = open(fn, "a")
        return log_file, f"{type}{unq}.xml"
    except IOError:
        # Handle error if unable to open file
        SCH_ErrorMessage(fn)

def SCH_getUniqueFN(root, type):
    # Calculate unique filename based on current time
    unq = int(time.time()) - 1073353928
    fn = f"{root}{type}{unq}.xml"

    return f"{type}{unq}.xml"
        

def SCH_xmlRemoveEmptyPics(rows):
    results = []

    for row in rows:
        match = re.search(r'<IF_PICTURE>(.*?)<\/IF_PICTURE>', row, re.IGNORECASE | re.DOTALL)

        if match:
            trim = match.group(1) or ""
            src_match = re.search(r'src\s*=\s*"(.*?)"', trim, re.IGNORECASE)

            src = src_match.group(1) if src_match else ""

            if any(c.isalnum() for c in src):
                # Remove the wrappers
                row = row.replace('<IF_PICTURE>', '').replace('</IF_PICTURE>', '')
            else:
                # Clear
                row = re.sub(r'<IF_PICTURE>(.*?)<\/IF_PICTURE>', '', row, flags=re.IGNORECASE | re.DOTALL)

        results.append(row)

    return results


def myDirFileCountSize(directory):
    iCount = 0
    iTotal = 0

    for root, dirs, files in os.walk(directory):
        for fn in files:
            filepath = os.path.join(root, fn)
            iCount += 1
            iTotal += os.path.getsize(filepath)

    return (iCount, iTotal)

def SCH_getDescription(xmlfilename):
    session = SCH_getSession()

    file_path = os.path.join(session['dir'], xmlfilename)
    try:
        with open(file_path, 'r') as file:
            json_data = file.read()
            data = json.loads(json_data)
            description = data['data']['description']
            return description
    except (FileNotFoundError, json.JSONDecodeError, KeyError):
        return "Description not found or invalid JSON format"


def SCH_checkDir():
    session = SCH_getSession()

    # FM 3/3/4
    # For now Demo can't write data, protection from Crackers
    if 'members/Demo' in session['dir']:
        return 0
    # FM 3/3/4

    cnt, size = myDirFileCountSize(os.path.join(".", session['dir']))

    if cnt >= session['dirCount']:
        return -10

    if size >= session['dirSize']:
        return -20

    return 1

def SCH_deleteFile(xmlfilename):
    desc = ''
    retval, fn = SCH_ValidateFilename(xmlfilename)
    if not retval:
        SCH_ErrorMessage(f"Bad filename({xmlfilename})")
     # FM, cheezy, If you Demo you can not do file Create, Delete
    # if SCH_checkDir() != 0:
    check_result = SCH_checkDir()
    if check_result != 1:
        SCH_ErrorMessage(SCH_ErrorMessage(f"Your Not Allowed to Delete! ({check_result})"))

    ##################################
    # Get session data               #
    session = SCH_getSession()
    ##################################

    fn = os.path.join(session['dir'], xmlfilename)
    # fn = os.path.join(session['dir'], fn)
    # fn = fn.replace('.', os.getcwd())

    if os.path.exists(fn):
        desc = SCH_getDescription(xmlfilename)
        os.unlink(fn)
        logging.basicConfig(level=logging.DEBUG)
        logging.debug(f"File {fn} {desc}")

        # shutil.move(fn, f"{fn}.rem")  # Uncomment this line if you want to rename instead of delete
        # print(f"Removed ({desc})!<br>")
    else:
        print(f"File {fn} does not exist.")
        
    return desc


def SCH_ValidateFilename(fn):
    if fn.count("/") > 1:
        return (0, fn)
    
    # if fn.count(".") > 1 or re.search(r'/\.', fn):
    #     return (0, fn)
    
    if not re.match(r'^[\w./]+$', fn):
        return (0, fn)
    
    match = re.match(r'([\w./]+)', fn)
    fn = match.group(1) if match else ""
    
    return (1, fn)

def SCH_getSession():
    # Get the cookie string from the environment variable
    cookie_string = os.environ.get('HTTP_COOKIE', '')
    cookie = cookies.SimpleCookie(cookie_string)

    # Extract the sessionID from the cookie and make sure it's a string
    session_id = cookie.get('sessionID')
    session_id = session_id.value if session_id else "NO ID"

    # Define session details
    session = {}
    if session_id != "NO ID":
        session = {
            'id': session_id,  # Set the session ID
            'dir': f'./members/{session_id}/',  # Create the directory path based on session ID
            'dirCount': 3000,
            'dirSize': 100000000,  # 100 Megabytes
        }
    else:
        session = {
            'id': session_id,  # If no session ID, set as "NO ID"
            'dir': './members/NO_ID/',  # Fallback directory for no session ID
            'dirCount': 0,
            'dirSize': 0,  # No directory size for NO ID
        }

    # Log the session details
    logging.debug(f"\n\t\t session=  {session}")
    return session

def set_session_cookie(session_id):
    # Create a cookie object
    cookie = cookies.SimpleCookie()

    # Set the cookie for sessionID
    cookie["sessionID"] = session_id

    # Set the cookie to expire in 30 days
    expires = datetime.datetime.now() + datetime.timedelta(days=30)
    cookie["sessionID"]["expires"] = expires.strftime("%a, %d-%b-%Y %H:%M:%S GMT")

    # Set additional cookie attributes if needed
    cookie["sessionID"]["path"] = "/"  # Makes the cookie available site-wide
    cookie["sessionID"]["httponly"] = True  # Ensure the cookie is only sent over HTTP, not accessible via JavaScript for security

    # Output the cookie as an HTTP header
    print(cookie.output())  # This prints the Set-Cookie header


def get_fn(xml_filename):
    blank_schedule = "blank.xml"
    fn = ""

    # Get session data
    session = SCH_getSession()

    fn = f"{session['dir']}{xml_filename}"

    if xml_filename.lower().startswith(blank_schedule.lower()):
        fn = xml_filename

    if xml_filename.lower().startswith("schs/"):
        fn = xml_filename

    return fn

import re

def SCH_xmLRD(left_val, right_val, lines):
    results = []

    # Get the tag from left_val
    match = re.search(r'<(.*?)>', left_val, re.IGNORECASE)
    tag = match.group(1) if match else ""

    # Extract content between opening and closing tags in left_val
    match = re.search(r'<\s*\b{}\b\s*>(.*)<\s*\/\b{}\b\s*>'.format(tag, tag), left_val, re.IGNORECASE | re.DOTALL)
    left_val = match.group(1) if match else ""

    xml_keys = re.split(r',\s*', right_val)

    # Key, value pairs
    key_dict = {}

    for index, xml_key in enumerate(xml_keys):
        match = re.search(r'<\s*(.*?)\s*>', xml_key)
        trim = match.group(1).strip() if match else ""
        xml_keys[index] = trim
        key_dict[trim] = str(index)

    parent = xml_keys[0]
    section = ""
    left = False
    right = False

    xml_values = xml_keys.copy()

    for line in lines:
        if re.search(r'<\s*\b{}\b\s*>'.format(parent), line, re.IGNORECASE):
            left = True

        if re.search(r'<\/\s*\b{}\b\s*>'.format(parent), line, re.IGNORECASE):
            right = True

        if left and not right:
            # Copy section
            section += line

        if left and right:
            # Copy section
            section += line

            match = re.search(r'<\s*\b{}\b\s*>(.*?)<\s*\/\b{}\b\s*>'.format(parent, parent), section, re.IGNORECASE | re.DOTALL)
            section_content = match.group(1) if match else ""

            # Get section values
            for index, tag in enumerate(xml_keys):
                xml_values[index] = ""
                key_dict[tag] = ""

                match = re.search(r'<\s*\b{}\b\s*>(.*?)<\s*\/\b{}\b\s*>'.format(tag, tag), section_content, re.IGNORECASE | re.DOTALL)
                trim = match.group(1).strip() if match else ""

                if trim:
                    trim = trim.replace('"', "'").replace("'", '&#39;')
                    xml_values[index] = trim
                    key_dict[xml_keys[index]] = trim

            # Update left_val
            update = left_val

            for index, xml_key in enumerate(xml_keys):
                update = re.sub(r'<\s*{}\s*>'.format(xml_key), key_dict[xml_key], update, flags=re.IGNORECASE)

            results.append(update)

            left = False
            right = False
            section = ""

    return results

def get_form_data():
    request_body = sys.stdin.read()
    request_uri = os.environ.get('REQUEST_URI')
    url_params = urllib.parse.parse_qs(request_uri, keep_blank_values=True)
    
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
    json_data = json.loads(json_data)

    return (request_uri, request_body, json_data)


def greet(name):
    return f"Hello, {name}!"

def SCH_authenticate(id, pw):
    if id == 'Bucci' and pw == '123456':
        return 'Bucci'
    if id == 'Visitor'and pw == '123456':
        return 'Visitor'
    else:
        return 'fail'