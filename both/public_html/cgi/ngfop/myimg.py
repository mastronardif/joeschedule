import requests
from bs4 import BeautifulSoup

def google_search(query):
    search_url = f"https://www.google.com/search?q={query}"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'}
    response = requests.get(search_url, headers=headers)
    
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        links = soup.find_all('a')
        
        results = []
        for link in links:
            href = link.get('href')
            if href and "/url?q=" in href:
                url = href.split("/url?q=")[1].split("&")[0]
                results.append(url)
        
        return results
    else:
        print(f"Error {response.status_code}: Unable to fetch search results.")
        return []

if __name__ == "__main__":
    query = "cat"
    search_results = google_search(query)
    
    if search_results:
        for idx, result in enumerate(search_results[:3]):
            print(f"{idx + 1}. {result}")
    else:
        print("No search results.")
