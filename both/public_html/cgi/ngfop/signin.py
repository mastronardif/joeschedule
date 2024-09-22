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



# Get the hostname and environment variables
hostname = socket.gethostname()

# Get the host and request URI to form the full URL
host = os.environ.get('HTTP_HOST', 'localhost')
request_uri = os.environ.get('REQUEST_URI', '')
logging.debug(f"request_uri= {request_uri}")
logging.debug(f"host= {host}")

# Determine if the connection is secure (https) or not (http)
scheme = 'https' if os.environ.get('HTTPS', 'off') == 'on' else 'http'

# Full URL
url = f"{scheme}://{host}{request_uri}"
logging.debug(f"Full URL: {url}")

# Create the session ID cookie
oreo = http.cookies.SimpleCookie()
oreo['sessionID'] = id  # Replace with actual session ID
oreo['sessionID']['expires'] = 'Mon, 01-Jan-2025 00:00:00 GMT'

# Only set domain for joeschedule.com
if 'localhost' not in host:
    oreo['sessionID']['domain'] = '.joeschedule.com'

logging.debug(f"oreo['sessionID'] = {oreo['sessionID']}")

# Determine the redirection URL based on the host
if 'localhost' in host:
    whither = f"{scheme}://localhost:8080/cgi/ngfop/new_page_3a.htm"
else:
    whither = f"{scheme}://www.joeschedule.com/cgi/ngfop/new_page_3a.htm"

logging.debug(f"whither = {whither}")

# Print headers (make sure to print them in correct order)
print("Content-Type: text/html")
print(oreo.output())  # Set the cookie in the HTTP response
print(f"Location: {whither}")  # Redirect to the new page
print()  # End headers

sys.exit()
