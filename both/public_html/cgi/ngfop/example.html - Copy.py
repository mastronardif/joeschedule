from jinja2 import Template
with open('example.html.jinja') as f:
    tmpl = Template(f.read())
print(tmpl.render(
    variable = 'Value with <unsafe> data',
    item_list = [1, 2, 3, 4, 5, 6]
))