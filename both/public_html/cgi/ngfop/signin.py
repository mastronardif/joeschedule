#!/usr/bin/env python
from urllib.parse import parse_qs
import logging
import socket
import os
import sys
import http.cookies
from sch00 import SCH_authenticate
# from sch00 import SCH_getSession
# from sch00 import get_fn
from sch00 import get_form_data
# from sch00 import SCH_ValidateFilename
# from sch00 import SCH_getUniqueFN
# import xmltodict
import json
import xml.etree.ElementTree as E

def SCH_SignOut00():
    # Reset the cookie
    cookie = http.cookies.SimpleCookie()
    cookie['sessionID'] = 'NULL'
    cookie['sessionID']['expires'] = 'Fri, 06-Apr-2001 10:00:00 GMT'

    # Start the HTML response and set the cookie in headers
    print("Content-Type: text/html")
    print(cookie.output())  # Set the cookie in the HTTP header
    print()
    return

    # Get the full URL (mocking this since QUERY_STRING may not give full URL)
    full_url = os.environ.get('REQUEST_URI', 'http://localhost/cgi-bin/cgi/ngfop/sch3.py')

    # Extract root domain
    root = '/'.join(full_url.split('/')[:3]) + '/'
    root = 'yahoo.com'

    # HTML response
    print(f"""
    <html>
    <body onLoad="redirTimer()">
    <script language="JavaScript1.2">
    <!-- Begin
    redirTime = "0";  // Immediately redirect
    redirURL = "{root}";
    function redirTimer() {{
        self.setTimeout("self.location.href = redirURL;", redirTime);
    }}
    // End -->
    </script>
    </body>
    </html>
    """)


def SCH_SignOut():
    # Clear the sessionID cookie
    print("Content-type: text/html\n")
    print("Set-Cookie: sessionID=; expires=Thu, 01 Jan 1970 00:00:00 GMT\n")  # Expire the cookie immediately
    
    # Determine the host
    host = os.environ.get('HTTP_HOST', 'localhost')
    
    # Redirect to the root URL
    redirect_url = f"http://{host}/indexjsv22.html"  
    logging.debug(f"redirect_url= {redirect_url}")
    
    print(f"""
    <html>
        <head>
            <meta http-equiv="refresh" content="0; url={redirect_url}">
        </head>
        <body>
            <p>You are being redirected to <a href="{redirect_url}">the home page</a>.</p>
        </body>
    </html>
    """)


##################################
# Get session data               #
#11/9/9my %session = &SCH_getSession(); #
##################################
request_uri, request_body, result = get_form_data()
# id = result.get("url_params", {}).get("id", ["dummy"])[0]
id = result.get("form_data", {}).get("id", ["dummy"])[0]
pw = result.get("form_data", {}).get("pw", ["dummy"])[0]
action = result.get("url_params", {}).get("action", [""])[0]
logging.debug(f"action = {action}")


##############################
if "signout" in action.lower():
   # sign out!!!
   SCH_SignOut()
   # print("Content-Type: text/html")
   # print(f"""
   #  <html>
   #  <body">
   #       ssssssssssssssss
   #  </body>
   #  </html>
   #  """)
   # print()
   sys.exit()

# action ="Demo";

# }
##############################
logging.basicConfig(level=logging.DEBUG)
# logging.debug(f"signin.py zzzz : {id} {pw}")

authCode = SCH_authenticate(id, pw)
id = authCode

if "fail" in authCode.lower():
   print("Content-type: text/html\n")
   print("""
   <p><font size="6" color="#FF0000"><b>fail({authCode})Invalid ID/Password.<br />
   Please go back and try again.
   </b></font></p>
   """.format(authCode=authCode))
   sys.exit()


# Create a cookie
oreo = http.cookies.SimpleCookie()
oreo['sessionID'] = id  # Assign your session ID value here
oreo['sessionID']['domain'] = '.joeschedule.com'
oreo['sessionID']['expires'] = 'Mon, 01-Jan-2025 00:00:00 GMT'  # Manually set an expiration date; adjust as needed

hostname = socket.gethostname()
logging.debug(f"hostname= {hostname}")

# Get the local IP address
try:
    local_ip = socket.gethostbyname(hostname)
    logging.debug(f"Local IP: {local_ip}")
except socket.gaierror:
    logging.debug("Failed to get local IP")

host = os.environ.get('HTTP_HOST', 'localhost')
request_uri = os.environ.get('REQUEST_URI', '')
logging.debug(f"request_uri= {request_uri}")
logging.debug(f"host= {host}")

# Determine if the connection is secure (https) or not (http)
if os.environ.get('HTTPS', 'off') == 'on':
    scheme = 'https'
else:
    scheme = 'http'

# Get the host and request URI to form the full URL
host = os.environ.get('HTTP_HOST', 'localhost')
request_uri = os.environ.get('REQUEST_URI', '')
# Full URL
url = f"{scheme}://{host}{request_uri}"
logging.debug(f"Full URL: {url}")

# Check if the IP is localhost.  Cheesey Docker test.
# if host.find('localhost') > -1 :
#     host = "http://localhost:8080"
# else:
#     host = "http://www.joeschedule.com"

# if hostname == 'localhost':
#     host = "http://localhost:8080"
# else:
#     host = "https://www.joeschedule.com"

whither = f"{scheme}://{host}/cgi/ngfop/new_page_3a.htm"
# whither  = "http://www.joeschedule.com/cgi/ngfop/new_page_3a.htm"
# whither  = "http://localhost:8080/cgi/ngfop/new_page_3a.htm"
logging.debug(f"whither =  {whither}")
print("Content-Type: text/html")
print(oreo.output())  # Set cookie in the HTTP response
print(f"Location: {whither}")  # Redirect to the new page
print()  # End headers

# You can also print optional HTML if necessary (e.g., in case the redirect doesn't work)
# print(f'<html><head><meta http-equiv="refresh" content="0;url={whither}"></head></html>')

sys.exit()