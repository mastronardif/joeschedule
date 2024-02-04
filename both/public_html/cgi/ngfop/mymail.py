import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart 

def send_email(subject, body, to_email):
    # Set up the parameters
    sender_email = 'mastronardif@gmail.com'
    sender_password = 'Gold112898'
    smtp_server = 'teddy0501.mail.pairserver.com' #'smtp.gmail.com'
    smtp_port = 587

    # Create the MIME object
    message = MIMEMultipart()
    message['From'] = sender_email
    message['To'] = to_email
    message['Subject'] = subject

    # Attach the text to the email
    message.attach(MIMEText(body, 'plain'))

    # Connect to the SMTP server
    server = smtplib.SMTP(smtp_server, smtp_port)
    server.starttls()

    # Log in to the email account
    server.login(sender_email, sender_password)

    # Send the email
    server.sendmail(sender_email, to_email, message.as_string())

    # Quit the server
    server.quit()

# Example usage
subject = 'Test Email'
body = 'Hello, this is a test email from Python!'
to_email = 'mastronardif@gmail.com'

send_email(subject, body, to_email)
