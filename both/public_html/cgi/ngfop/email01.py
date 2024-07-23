#!/usr/bin/python
import logging
# import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from subprocess import Popen, PIPE
import sys
from sch00 import get_form_data




def mailtheform(email_from, email_to, subject, params):
    # Construct the message body
    # print("Content-type: text/html\n") 
    logging.basicConfig(level=logging.DEBUG)
    logging.debug(f"params= {params}")
    htmlname     = 'txtthecb.jinja.htm'
    xml_filename = 'cb648146512.xml.json'

    # xmlfilename = params["xmlfilename"][0]
    logging.debug(f"xmlfilename= {xml_filename}")
    logging.debug(f"htmlname= {htmlname}")
    # sys.exit()

    # Define these once; use them twice!
    strFrom = 'mastronardif@netcarrier.com'
    strTo = 'mastronardif@netcarrier.com'
    to_addresses = ['mastronardif@gmail.com', 'mastronardif@netcarrier.com']

    # Create the root message and fill in the from, to, and subject headers
    msgRoot = MIMEMultipart('related')
    msgRoot['Subject'] = 'FM test message'
    msgRoot['From'] = strFrom
    # msgRoot['To'] = strTo
    msgRoot['To'] = ', '.join(to_addresses)
    msgRoot.preamble = 'This is a multi-part message in MIME format.'
    # Encapsulate the plain and HTML versions of the message body in an
    # 'alternative' part, so message agents can decide which they want to display.
    msgAlternative = MIMEMultipart('alternative')
    msgRoot.attach(msgAlternative)

    # We reference the image in the IMG SRC attribute by the ID we give it below
    msgText = MIMEText('<b>Some <i>HTML</i> text</b> and an image.<br><img src="cid:image1"><br>Nifty!', 'html')
    msgAlternative.attach(msgText)

    # msgText = MIMEText('This is the alternative plain text message.')
    # msgAlternative.attach(msgText)

    # We reference the image in the IMG SRC attribute by the ID we give it below
    msgText = MIMEText('<b>Some <i>HTML</i> text</b> and an image.<br><img src="cid:image1"><br>Nifty!', 'html')
    msgAlternative.attach(msgText)

    # This example assumes the image is in the current directory
    fp = open('abaprogs.jpg', 'rb')
    msgImage = MIMEImage(fp.read())
    fp.close()

    # Define the image's ID as referenced above
    msgImage.add_header('Content-ID', '<image1>')
    msgRoot.attach(msgImage)

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

    # logging.debug(f"msgRoot=  {msgRoot}")

    # Call sendmail to send the email
    with Popen(["/usr/sbin/sendmail", "-t"], stdin=PIPE, universal_newlines=True) as sendmail_proc:
        sendmail_proc.communicate(msgRoot.as_string())


    # Send the email (this example assumes SMTP authentication is required)
    import smtplib
    smtp = smtplib.SMTP()
    smtp.connect('teddy0501.mail.pairserver.com')
    smtp.login('teddy0501', 'Gold112898')
    smtp.sendmail(strFrom, strTo, msgRoot.as_string())
    smtp.quit()

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
# request_uri, request_body, result = get_form_data()

logging.basicConfig(level=logging.DEBUG)
# logging.debug(f"result= {result}")
# xml_filename = result["form_data"]["xmlfilename"][0]
# xml_filename = result["form_data"]["name"][0]

htmlname    = 'txtthecb.jinja.htm'
xmlfilename = 'cb648146512.xml.json'

print("<html><head><title>Hello Python CGI</title></head><body>")
# print (request_body)
# print (request_uri)
email_from = "mastronardif@gmai.com" 
email_to = "9088580954@vtext.com,mastronardif@netcarrier.com"
subject = "FM, JoeSchedule data"
params = {
        "param1": ["value1", "value2"],
        "xmlfilename": xmlfilename,
        "htmlname": htmlname,
        # Add more parameters as needed
}

# logging.basicConfig(level=logging.DEBUG)
# logging.debug(f"File {request_uri} {request_body}")


mailtheform(email_from, email_to, subject, params)

logging.debug(f"params=  {params}")
print("<h1>Hello, Python World!</h1>")
print("</body></html>")
