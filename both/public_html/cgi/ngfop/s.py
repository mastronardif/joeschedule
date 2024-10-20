#!/usr/bin/env python

import json
from sch00 import get_form_data

def return_json(data):
    print("Content-Type: application/json")  # Set the content type to JSON
    print()  # End of headers
    print(json.dumps(data))  # Convert the Python dictionary to JSON and print it

def redirect(url):
    print(f"Status: 302 Found")
    print(f"Location: {url}")
    print()

def expand_url(short_code):
    # long_url = 'url_store.get(short_code)'
    long_url = 'https://www.joeschedule.com/cgi-bin/cgi/ngfop/sch3b.py?htmlname=cb3amedia.jinja.htm&name=cb652190833.xml.json&sessionID=Bucci'
    
    if not long_url:
        return return_json({'error': 'URL not found'}), 404

    return redirect(long_url)


if __name__ == "__main__":
    # print("Content-Type: text/html\n")
    # print("Conasdfasfasdf")

    request_uri, request_body, result = get_form_data()
    
    short_url = result.get("s", {}).get("s", ["dummy"])[0]
    expand_url(short_url)
