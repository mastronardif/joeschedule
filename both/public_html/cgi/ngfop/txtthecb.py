#!/usr/bin/python
import logging
# import zlib
# import base64
# import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from subprocess import Popen, PIPE
import sys
from sch00 import get_form_data


# def compress_url(url):
#     # https://www.joeschedule.com/cgi-bin/cgi/ngfop
#     # Compress the URL using zlib
#     compressed_data = zlib.compress(url.encode('utf-8'))
    
#     # Encode the compressed data to base64 for safe transmission
#     base64_encoded = base64.urlsafe_b64encode(compressed_data)
    
#     # Convert to a string
#     return base64_encoded.decode('utf-8')

# def decompress_url(compressed_url):
#     # Decode from base64
#     compressed_data = base64.urlsafe_b64decode(compressed_url)
    
#     # Decompress using zlib
#     decompressed_data = zlib.decompress(compressed_data)
    
#     # Convert back to a string
#     return decompressed_data.decode('utf-8')

def expandShort(short_url):
    # Replace 'R' back with the original base URL to expand it
    base_url = "https://www.joeschedule.com/cgi-bin/cgi/ngfop"
    expanded_url = short_url.replace("R", base_url)
    return expanded_url

def makeShort(long_url):
    # Replace the base URL with 'R' for shortening
    base_url = "https://www.joeschedule.com/cgi-bin/cgi/ngfop"
    short_url = long_url.replace(base_url, "R")
    return short_url

def mailtheform(email_from, email_to, subject, params):
    # Construct the message body
    # print("Content-type: text/html\n") 
    logging.basicConfig(level=logging.DEBUG)
    logging.debug(f"params= {params}")
    htmlname     = result["form_data"]["htmlname"][0] 
    xml_filename = result["form_data"]["xmlfilename"][0]
    # xmlfilename = params["xmlfilename"][0]
    logging.debug(f"xmlfilename= {xml_filename}")
    logging.debug(f"htmlname= {htmlname}")
    # sys.exit()
    long_url = f'https://www.joeschedule.com/cgi-bin/cgi/ngfop/sch3b.py?htmlname={htmlname}&sessionID=Bucci&name={xmlfilename}'
    html_body = ""
    # html_body = "<html><body>"
    # for key, values in params.items():
    #     values_str = ', '.join(values)
    #     html_body += f"<p><b>{key}:</b> {values_str}</p>"
    # html_body += f'<a href="https://www.joeschedule.com/cgi-bin/cgi/ngfop/sch3b.py?htmlname=cb3a.jinja.htm&name=cb632514019.json">bobo</a>'
    # html_body += "</body></html>"    

    # short_url = makeShort(long_url)
    # html_body = f'https://www.joeschedule.com/cgi-bin/cgi/ngfop/s.py?s={short_url} \n'
    html_body = f'https://www.joeschedule.com/cgi-bin/cgi/ngfop/s.py?s={xml_filename} \n'
    # html_body += f'{long_url}'

    # html_body += f'https://www.joeschedule.com/cgi-bin/cgi/ngfop/sch3b.py?htmlname={htmlname}&sessionID=Bucci&name={xmlfilename}'
    # msg_body = f"<data from paybycheck.pl/>\n"
    # for key, values in params.items():
    #     values_str = ', '.join(values)
    #     msg_body += f"<{key}>\n{values_str}\n</{key}>\n"
    logging.debug(f"html_body= {html_body}")
    # Construct the email message
    msg = MIMEMultipart("alternative")
    msg["From"] = email_from
    msg["To"] = email_to
    msg["Subject"] = subject

    msg.attach(MIMEText(html_body, "html"))

    # Call sendmail to send the email
    with Popen(["/usr/sbin/sendmail", "-t"], stdin=PIPE, universal_newlines=True) as sendmail_proc:
        sendmail_proc.communicate(msg.as_string())


    # Send the email
    # try:
    #     print("mailing\n")
    #     smtpObj = smtplib.SMTP('localhost')
    #     smtpObj.send_message(message)
    #     smtpObj.quit()
    #     print("Successfully sent email")
    # except Exception as e:
    #     print("Error: unable to send email")
    #     print(e)
    print("END\n")


print("Content-type: text/html\n")  # CGI header
request_uri, request_body, result = get_form_data()

logging.basicConfig(level=logging.DEBUG)
logging.debug(f"result= {result}")
# xml_filename = result["form_data"]["xmlfilename"][0]
# xml_filename = result["form_data"]["name"][0]

htmlname    = result["form_data"]["htmlname"][0] 
xmlfilename = result["form_data"]["xmlfilename"][0]

print("<html><head><title>Hello Python CGI</title></head><body>")
print (request_body)
print (request_uri)
email_from = "mastronardif@gmai.com" 
email_to = "9088580954@vtext.com,mastronardif@netcarrier.com"
subject = "FM, JoeSchedule data"
params = {
        "param1": ["value1", "value2"],
        "xmlfilename": xmlfilename,
        "htmlname": [htmlname],
        # Add more parameters as needed
}

# logging.basicConfig(level=logging.DEBUG)
# logging.debug(f"File {request_uri} {request_body}")


mailtheform(email_from, email_to, subject, params)

logging.debug(f"params=  {params}")
print("<h1>Hello, Python World!</h1>")
print("</body></html>")
