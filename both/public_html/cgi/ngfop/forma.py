#!/usr/bin/env python
from sch00 import SCH_getSession
from sch00 import get_fn
import json

fn = get_fn("cb632514019.json")

with open(fn, 'r') as file:
    data = json.load(file) #file.read()
#json = data|from_json

def render_template():
    from jinja2 import Template
    with open('froma.jinja') as f:
        tmpl = Template(f.read())
    print("Content-type: text/html\n")
    print(tmpl.render(
        variable='forma data',
        item_list= data['data'] ##data #[1, 2, 3, 4, 5, 6, 7]
    ))


if __name__ == "__main__":
    render_template()
"""
print("<hr/><hr/>Debug<br/>'")
print(data)
message = SCH_getSession()
print(message)
print("<br/>")

result = get_fn("example.xml")
print(result)
"""