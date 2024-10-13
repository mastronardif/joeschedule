#!/usr/bin/env python
import imaplib
import email
import os
from email.header import decode_header
import base64
import quopri

# Mail server settings
IMAP_SERVER = 'teddy0501.mail.pairserver.com'
IMAP_PORT = 993  # Secure IMAP port
EMAIL_ACCOUNT = 'joemail@joeschedule.com'
EMAIL_PASSWORD = 'Jsapple1!'

# Directory to save downloaded images
DOWNLOAD_FOLDER = './downloads'

# Ensure download directory exists
if not os.path.exists(DOWNLOAD_FOLDER):
    os.makedirs(DOWNLOAD_FOLDER)

# Connect to the mail server and login
def connect_to_mail():
    mail = imaplib.IMAP4_SSL(IMAP_SERVER, IMAP_PORT)
    mail.login(EMAIL_ACCOUNT, EMAIL_PASSWORD)
    return mail


def download_images_from_unread_emails(mail):
    # Select the inbox folder
    mail.select('inbox')

    # Search for unread emails
    result, data = mail.search(None, '(UNSEEN)')

    # If no unread emails found, stop
    if data[0] == b'':
        print("No unread emails found.")
        return

    # Process each unread email
    for num in data[0].split():
        result, message_data = mail.fetch(num, '(RFC822)')
        raw_email = message_data[0][1]
        msg = email.message_from_bytes(raw_email)

        # Decode the email subject
        subject, encoding = decode_header(msg['Subject'])[0]
        if isinstance(subject, bytes):
            subject = subject.decode(encoding or 'utf-8')

        print(f'Processing email: {subject}')

        # Check for image parts in the email (attachments or inline images)
        for part in msg.walk():
            content_type = part.get_content_type()
            content_disposition = str(part.get('Content-Disposition'))

            if 'image' in content_type:
                # If the part is an image (either attachment or inline)
                if part.get_filename():
                    # If it's an attachment
                    filename = part.get_filename()
                else:
                    # If it's an inline image without a filename
                    filename = 'inline_image.png'

                # Decode the filename if necessary
                decoded_filename = decode_header(filename)[0][0]
                if isinstance(decoded_filename, bytes):
                    decoded_filename = decoded_filename.decode()

                # Save the image to the folder
                filepath = os.path.join(DOWNLOAD_FOLDER, decoded_filename)
                with open(filepath, 'wb') as f:
                    f.write(part.get_payload(decode=True))

                print(f'Downloaded: {filepath}')

# Main function to connect and download images
if __name__ == '__main__':
    try:
        mail = connect_to_mail()
        download_images_from_unread_emails(mail)
        mail.logout()
    except Exception as e:
        print(f'Error: {e}')