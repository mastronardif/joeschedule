#!/usr/bin/python

import cgi
import cgitb
import sys
import os

# Enable debugging
cgitb.enable()

# print("Content-type: text/html\n")  # CGI header
# print("<html><head><title>Hello Python CGI</title></head><body>")
# print("<h1>Hello, Python World!</h1>")

# print("<h1>Last Modified: July 30 12024!</h1>")
# print("</body></html>")

# print("Content-type: text/html\n")
print("Content-Type: image/jpeg\n")

src =  "/usr/local/apache2/public_html/cgi/ngfop/untitled.png"
length = os.stat(src).st_size


sys.stdout.write("Content-Type: image/png\r\n\r\n")
sys.stdout.write("Content-Length: " + str(length) + "\n")
sys.stdout.write("\n")
sys.stdout.flush()
sys.stdout.buffer.write(open(src, "rb").read())
sys.stdout.flush()


# if __name__ == "__main__":
# Open the image file in binary mode
# with open("/usr/local/apache2/public_html/cgi/ngfop/members/Bucci/mypics/IMG_1521.jpg", "rb") as image_file:
#     # Read the image data
#     image_data = image_file.read()
#     print(image_data)

    # Set the content type header
    # print("Content-Type: image/jpeg\n")
    # print("Content-Type: text/html\n")


    # Send the image data to the browser
    # sys.stdout.buffer.write(image_data)