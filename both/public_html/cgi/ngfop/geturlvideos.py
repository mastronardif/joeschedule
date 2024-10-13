import requests
from bs4 import BeautifulSoup

# Fetch the HTML from the webpage
url = "https://www.google.com/search?q=squirels"
headers = {'User-Agent': 'Mozilla/5.0'}
response = requests.get(url, headers=headers)

# Check if the page was fetched successfully
if response.status_code == 200:
    soup = BeautifulSoup(response.text, 'html.parser')

    # Find all video tags and add an onclick event to them
    for video in soup.find_all('video'):
        video['onclick'] = "alert('hello');"

    # Write the modified HTML to a file called 'fuck.html'
    with open('fuck.html', 'w', encoding='utf-8') as file:
        file.write(str(soup))

    print("Modified HTML saved to fuck.html")

else:
    print(f"Failed to fetch the webpage. Status code: {response.status_code}")
