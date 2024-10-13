#!/usr/bin/env python
import imaplib
import email
import os
import json
from email.header import decode_header

# Load configuration from the JSON file
def load_config(config_file='config.json'):
    with open(config_file, 'r') as file:
        return json.load(file)

# Ensure the download directory exists
def ensure_download_directory(download_folder):
    if not os.path.exists(download_folder):
        os.makedirs(download_folder)

# Connect to the mail server and login
def connect_to_mail(imap_server, imap_port, email_account, email_password):
    mail = imaplib.IMAP4_SSL(imap_server, imap_port)
    mail.login(email_account, email_password)
    return mail

# Download images from unread emails
def download_images_from_unread_emails(mail, download_folder):
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
                filepath = os.path.join(download_folder, decoded_filename)
                with open(filepath, 'wb') as f:
                    f.write(part.get_payload(decode=True))

                print(f'Downloaded: {filepath}')

# Main function to connect and download images
if __name__ == '__main__':
    try:
        # Load configuration
        config = load_config()

        # Set up download folder
        ensure_download_directory(config['download_folder'])

        # Connect to the mail server
        mail = connect_to_mail(
            config['imap_server'],
            config['imap_port'],
            config['email_account'],
            config['email_password']
        )

        # Download images from unread emails
        download_images_from_unread_emails(mail, config['download_folder'])

        # Logout from mail server
        mail.logout()

    except Exception as e:
        print(f'Error: {e}')
