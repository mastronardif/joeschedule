# myscript.py
from sch00 import greet
from sch00 import get_session
from sch00 import get_fn
from sch00 import SCH_xmlRemoveEmptyPics
from sch00 import SCH_xmLRD

def main():
    name = input("Enter your name: ")
    message = greet(name)
    print(message)

    message = get_session()
    print(message)

    result = get_fn("example.xml")
    print(result)

    input_rows = ["<IF_PICTURE>...</IF_PICTURE>", "<IF_PICTURE>...</IF_PICTURE>", "<IF_PICTURE>...</IF_PICTURE>"]
    output_rows = SCH_xmlRemoveEmptyPics(input_rows)
    print(output_rows)

    left_value = "<Tag>...</Tag>"
    right_value = "<Key1, Key2>"
    lines = ["<Parent>", "Content", "</Parent>", "<Parent>", "Content", "</Parent>"]

    result = SCH_xmLRD(left_value, right_value, lines)
    print(result)

if __name__ == "__main__":
    main()
