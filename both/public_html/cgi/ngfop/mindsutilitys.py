from bs4 import BeautifulSoup
import random
import string

def extract_form_data(file_path):
    """
    Extracts the HTML content between <form> tags from the specified file.

    Args:
    file_path (str): The path to the HTML file.

    Returns:
    str: The HTML content between the <form> tags, or an empty string if no <form> tag is found.
    """
    try:
        # Open and read the HTML file
        with open(file_path, 'r', encoding='utf-8') as file:
            html_content = file.read()
        #logging.debug(f"ZZZZZZZZZZ html_content {html_content}")
        # Parse the HTML content using BeautifulSoup
        soup = BeautifulSoup(html_content, 'html.parser')
        
        # Find the first <form> tag
        form_tag = soup.find('form')
        
        # Return the HTML content inside the <form> tag
        if form_tag:
            return str(form_tag)  # Convert BeautifulSoup tag to string
        else:
            return ""
    
    except FileNotFoundError:
        print(f"Error: The file {file_path} was not found.")
        return ""
    except Exception as e:
        print(f"An error occurred: {e}")
        return ""

def generate_unique_prefix(inputs):
    """Generate a unique three-character prefix that does not conflict with existing names or ids."""
    # Collect existing names and ids from input tags
    existing_names = {input_tag.get('name') for input_tag in inputs if input_tag.has_attr('name')}
    existing_ids = {input_tag.get('id') for input_tag in inputs if input_tag.has_attr('id')}
    
    # Combine names and ids to avoid conflicts
    all_existing = existing_names.union(existing_ids)
    
    def generate_prefix():
        """Generate a random three-character prefix."""
        return ''.join(random.choices(string.ascii_lowercase + string.digits, k=3))
    
    prefix = generate_prefix()
    while prefix in all_existing:
        prefix = generate_prefix()
    
    return prefix

def set_form_inputs(form_html):
    soup = BeautifulSoup(form_html, 'html.parser')
    start_number = 50

    # Generate a unique three-character prefix
    inputs_and_textareas = soup.find_all(['input', 'textarea'])
    unique_prefix = generate_unique_prefix(inputs_and_textareas)
    
    for tag in inputs_and_textareas:
        if tag.has_attr('name'):
            # If 'name' attribute already exists, do not change it
            continue
        if tag.has_attr('id'):
            # Set 'name' to the value of 'id' concatenated with the unique prefix and incrementing number
            tag['name'] = f"{tag['id']}-{unique_prefix}-200{start_number}"
        else:
            # Assign a unique 'name' with the incrementing number
            tag['name'] = f"{unique_prefix}-200{start_number}"
        start_number += 1
    
    return str(soup)
