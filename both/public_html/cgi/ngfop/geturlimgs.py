#!/usr/bin/env python
import urllib.request
from bs4 import BeautifulSoup

# Fetch the webpage

url = "https://www.youtube.com/results?search_query=cats"
# url = "https://www.google.com/search?sca_esv=c3cb3e39b600b48a&sca_upv=1&hl=en&udm=2&sxsrf=ADLYWIKJsQjm_s2DlTyjLaUmFTYvrndSbQ:1727550662324&q=wolf+pups&stick=H4sIAAAAAAAAAFvEylmen5OmUFBaUAwA7sEfcwwAAAA&source=univ&sa=X&ved=2ahUKEwj4t7zcq-aIAxWmnokEHRc0DJgQrNwCegQIFhAA&biw=1745&bih=828&dpr=1.1"
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

# response =  urllib.request.urlopen.get(url, headers=headers)
with urllib.request.urlopen(url) as response:
    response = response.read() #.decode('utf-8')

# Parse the HTML with BeautifulSoup
soup = BeautifulSoup(response, "html.parser")

# Find all images and add the onclick event
for img in soup.find_all("img"):
    if img.has_attr("onclick"):
        img["onclick"] = img["onclick"] + " alert('hello');"
    else:
        img["onclick"] = "alert('hello');"

# Convert the modified soup back to HTML
modified_html = str(soup)

# Save the modified HTML to a file (optional, for preview)
with open("modified_page.html", "w", encoding="utf-8") as file:
    file.write(modified_html)

# Print the modified HTML (so it can be passed to another utility)
print(modified_html)
