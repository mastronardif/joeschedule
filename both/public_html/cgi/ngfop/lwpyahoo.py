#!/usr/bin/python

from sch00 import get_form_data
import urllib.request
from html.parser import HTMLParser
import logging

logging.basicConfig(level=logging.DEBUG)

def render_template(template, fn, data, **kwargs):
    from jinja2 import Template
    with open(template) as f:
        tmpl = Template(f.read())
    # print("Content-type: text/html\n")
    # print(data)
    print(tmpl.render(
        FILENAME=fn,
        item_list=data,
        **kwargs 
    ))

# Get parameters from CGI
request_uri, request_body, result = get_form_data()
# query = cgi.FieldStorage()
# jsquery = query.getvalue('jsquery', '')
jsquery    = result["url_params"]["jsquery"][0]
# jswrap = query.getvalue('jswrap', '')
# jswrap    = result["url_params"]["jswrap"][0] 
jswrap = result["url_params"].get("jswrap", [""])[0]
idx = result["url_params"].get("idx", [""])[0]
# html_name = result["url_params"]["htmlname"][0] 
# html_name = result["url_params"].get("htmlname", ["lwpyahoo.jinja.htm"])[0]
html_name = result["url_params"].get("htmlname", ["listmedia.jinja.htm"])[0]


# Construct URL
url = "http://images.search.yahoo.com/search/images?ei=UTF-8&fr=sfp&p="
url += jsquery if jsquery.startswith("http://") else urllib.parse.quote(jsquery)

# print("Content-type: text/html\n")  # CGI header

# print("<html><head><title>list imgs</title></head><body>")
print("")

# print("""
#    <html>
#    <head>
#     <title>List Images</title>
#     <link rel="stylesheet" type="text/css" href="/cgi/ngfop/css/imglist.css"/>
#    </head>
# """)
# Retrieve HTML content from the URL
with urllib.request.urlopen(url) as response:
    html = response.read().decode('utf-8')

# Parse HTML content to extract image URLs
class MyHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.image_urls = []

    def handle_starttag(self, tag, attrs):
        if tag == 'img':
            attrs_dict = dict(attrs)
            if 'src' in attrs_dict and attrs_dict['src'].startswith('http'):
                self.image_urls.append(attrs_dict['src'])

parser = MyHTMLParser()
parser.feed(html)

# Print image URLs
# print(f"<h1>images[{len(parser.image_urls)}]</h1>")
# print("<form method='get'>")
# print("<label for='jsquery'>JS Query:</label>")
# print("<input type='text' id='jsquery' name='jsquery'>&nbsp;")
# print(f"<input type='text' id='jsquery' name='jsquery' value='{jsquery}'>&nbsp;")


# print("<label for='idx'>Idx:</label>")
# print("<input type='text' id='idx' name='idx'><br>")
# print(f"<input type='text' id='idx' name='idx' value='{idx}'>&nbsp;")
# print("<input type='submit' value='Submit'>")
# print("</form>")

# print("<ul class='image-list'>")
if idx:  # Display specific image if idx is provided
    try:
        idx = int(idx) # Convert idx to integer
        if 0 <= idx-1 < len(parser.image_urls):
            image_url = parser.image_urls[idx-1]
            image_urls = [image_url]
            # print(f"<li><img src='{image_url}' alt='Image' /></li>")
            # parser.image_urls = image_url
        else:
            image_urls = [] 
    except ValueError:
        pass  # Ignore if idx is not a valid integer
        image_urls = []
else:  # Display all images if idx is not provided
    image_urls = parser.image_urls
    # for image_url in parser.image_urls:
    #     print(f"<li><img src='{image_url}' alt='Image' /></li>")

# for image_url in parser.image_urls:
#     print(f"<li><img src='{image_url}' alt='Image' /></li>")
# print("</ul>")
# // fm 11/2
json_data = {
    "data": {
        "description": "Yahoo Search pics",
        "row": [
            {"picture": f"{image_file}"} for image_file in image_urls
        ] 
        # + [
        #     {"video": f"{domain}/{domainpath}/{folder}/{video_file}",
        #      "poster": f"{domain}/{domainpath}/{folder}/posters/{video_file}.jpg"
        #      } for video_file in video_files
        # ]
    }
}
# logging.debug(json_data)
# // fm 1/2

fdesc = f"mmmmmmmmmmmmmm"
# render_template(html_name, fdesc, parser.image_urls)
# render_template('template.html', parser.image_urls, jsquery=jsquery, idx=idx)
# render_template(html_name, fdesc= fdesc, image_urls= parser.image_urls, jsquery=jsquery, idx=idx)
# render_template(html_name, fdesc, image_urls, jsquery=jsquery, idx=idx)
render_template(html_name, fdesc, json_data['data']['row'], jsquery=jsquery, idx=idx)

# render_template(html_name, fdesc, ddddJson['data'])