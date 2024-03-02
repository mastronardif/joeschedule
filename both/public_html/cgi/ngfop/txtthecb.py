#!/usr/bin/python
import logging
# import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from subprocess import Popen, PIPE
import sys
from sch00 import get_form_data




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

    html_body = ""
    # html_body = "<html><body>"
    # for key, values in params.items():
    #     values_str = ', '.join(values)
    #     html_body += f"<p><b>{key}:</b> {values_str}</p>"
    # html_body += f'<a href="https://www.joeschedule.com/cgi-bin/cgi/ngfop/sch3b.py?htmlname=cb3a.jinja.htm&name=cb632514019.json">bobo</a>'
    # html_body += "</body></html>"
    html_body += f'https://www.joeschedule.com/cgi-bin/cgi/ngfop/sch3b.py?htmlname={htmlname}&name={xmlfilename}'
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
