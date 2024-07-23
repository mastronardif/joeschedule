#!/usr/bin/python
import pdfkit
import logging

url = 'https://www.joeschedule.com/cgi-bin/cgi/ngfop/sch3b.py?htmlname=txtthecb.jinja.htm&name=cb632514019.json'
pdfkit.from_url(url, 'out1.pdf')
# pdfkit.from_url('http://google.com', 'out1.pdf')
# pdfkit.from_file('about.htm', 'out2.pdf')
# pdfkit.from_string('Hello!', 'out3.pdf')
