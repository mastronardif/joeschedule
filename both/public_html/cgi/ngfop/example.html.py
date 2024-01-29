#!/usr/bin/env python

def render_template():
    from jinja2 import Template
    with open('example.html.jinja') as f:
        tmpl = Template(f.read())
    print("Content-type: text/html\n")
    print(tmpl.render(
        variable='Value with <unsafe> data',
        item_list=[1, 2, 3, 4, 5, 6]
    ))

if __name__ == "__main__":
    render_template()
