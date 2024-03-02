import logging
# import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from subprocess import Popen, PIPE
import sys
from sch00 import get_form_data

def mailtheform(email_from, email_to, subject, params):
    # Construct the message body
    print("Content-type: text/html\n") 
    logging.basicConfig(level=logging.DEBUG)
    logging.debug(f"File {params} {params}")
    sys.exit()

    html_body = ""
    # html_body = "<html><body>"
    # for key, values in params.items():
    #     values_str = ', '.join(values)
    #     html_body += f"<p><b>{key}:</b> {values_str}</p>"
    # html_body += f'<a href="https://www.joeschedule.com/cgi-bin/cgi/ngfop/sch3b.py?htmlname=cb3a.jinja.htm&name=cb632514019.json">bobo</a>'
    # html_body += "</body></html>"
    html_body += f'https://www.joeschedule.com/cgi-bin/cgi/ngfop/sch3b.py?htmlname=cb3a.jinja.htm&name=cb632514019.json'
    # msg_body = f"<data from paybycheck.pl/>\n"
    # for key, values in params.items():
    #     values_str = ', '.join(values)
    #     msg_body += f"<{key}>\n{values_str}\n</{key}>\n"

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

if __name__ == "__main__":
    print("Content-type: text/html\n") 
    request_uri, request_body, result = get_form_data()
    # xml_filename = result["form_data"]["xmlfilename"][0]


    # print (request_body)
    # print (request_uri)
    # form_data = urllib.parse.parse_qs(request_body, keep_blank_values=True)
    # print (urllib.parse.parse_qs(request_body, keep_blank_values=True))
    print("<hr/><hr/>results<br/>") 
    # print(result)

    email_from = "mastronardif@gmai.com"
    email_to = "9088580954@vtext.com,mastronardif@netcarrier.com"
    subject = "FM, JoeSchedule data"
    params = {
        "param1": ["value1", "value2"],
        "xml_filename": ['xml_filename'],
        # Add more parameters as needed
    }

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(f"File {params} {params}")
    # mailtheform(email_from, email_to, subject, params)
# if __name__ == "__main__":
#     query = ''
#     mailtheform(query)  # Call the function when the script is run

# Example usage
# python mailtheform.py param1=value1 param2=value2
# query = {'email': 'sender@example.com', 'key1': 'value1', 'key2': ['value2', 'value3']}
# mailtheform(query)
