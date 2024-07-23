#!/usr/bin/env python

import cgi
import cgitb
import requests
import json
import os
import sys

cgitb.enable()  # Enable debugging

def print_headers():
    print("Content-Type: application/json")
    print("Access-Control-Allow-Origin: *")
    print("Access-Control-Allow-Methods: GET, POST, OPTIONS")
    print("Access-Control-Allow-Headers: Content-Type")
    print()

def call_api(url):
    response = requests.get(url)
    return response.json()

def main():
    # Check if running from command line
    if len(sys.argv) > 1:
        url = sys.argv[1]
    else:
        form = cgi.FieldStorage()
        if "url" not in form:
            print_headers()
            print(json.dumps({"error": "URL parameter is missing"}))
            return
        url = form.getvalue("url")

    try:
        data = call_api(url)
        print_headers()
        print(json.dumps(data, indent=4))
    except requests.exceptions.RequestException as e:
        print_headers()
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    main()
