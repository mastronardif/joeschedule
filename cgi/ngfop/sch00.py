# mylib.py

import os
import re

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

# Example usage
# input_rows = ["<IF_PICTURE>...</IF_PICTURE>", "<IF_PICTURE>...</IF_PICTURE>", "<IF_PICTURE>...</IF_PICTURE>"]
# output_rows = xml_remove_empty_pics(input_rows)
# print(output_rows)


def get_session():
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
    session = get_session()

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
