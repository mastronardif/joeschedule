# mylib.py

import json
import logging
import os
import re
import sys
import time

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
    # Check the HTTP_REFERER if needed
    # referer = os.environ.get('HTTP_REFERER', '')
    # if referer and not referer.startswith('http://example.com'):
    #     print("Hey, are you trying to do something sneaky? Email me, let's talk.")
    #     exit()

    # Get session ID from cookie or use a default value
    session_id = os.environ.get('HTTP_COOKIE', '').split('=')[-1] or "Bucci"

    # Untaint user input
    session_id = session_id[:30]  # Adjust the length if needed
    session_id = ''.join(c for c in session_id if c.isalnum() or c in ['_', '.', '/'])

    session = {}
    if session_id:
        session = {
            # 'id': 'Bucci',
            # 'pw': '123456',
            # 'dir': './members/Bucci/',
            'dir': f'./members/{session_id}/',
            'dirCount': 3000,
            # 'dirSize': 200000,
            'dirSize': 100000000,  # 100Meg
        }

    return session


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

# Example usage
# left_value = "<Tag>...</Tag>"
# right_value = "<Key1, Key2>"
# lines = ["<Parent>", "Content", "</Parent>", "<Parent>", "Content", "</Parent>"]

# result = xm_lrd(left_value, right_value, lines)
# print(result)


def greet(name):
    return f"Hello, {name}!"
