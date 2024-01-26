#!/usr/bin/python
import os

print("Content-type: text/html\n")  # CGI header
print("<html><head><title>Hello Python CGI</title></head><body>")
print("<h1>Hello, Python World!</h1>")
for param in os.environ.keys():
	print(f"{param}: {os.environ[param]}<br>")
print("</body></html>")
