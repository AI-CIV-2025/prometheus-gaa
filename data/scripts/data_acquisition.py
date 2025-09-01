import requests
from bs4 import BeautifulSoup
import json
import os

def fetch_articles(query, num_articles=5):
    search_url = f"https://www.google.com/search?q={query}&tbm=nws"
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
    response = requests.get(search_url, headers=headers)
    response.raise_for_status()

    soup = BeautifulSoup(response.content, 'html.parser')
    articles = []
    for i, g in enumerate(soup.find_all('div', class_='Gx5Zad fP1Qef etPBip')):
        if i >= num_articles:
            break
        link = g.find('a', class_='VDXfz')['href']
        title = g.find('div', class_='mCBkyc y355M JQe2Ld nDgy9d').text
        source = g.find('div', class_='CEMjEf NUnG9d').text
        articles.append({'title': title, 'link': link, 'source': source})
    return articles

if __name__ == "__main__":
    articles = fetch_articles("AI developments", num_articles=5)
    
    # Ensure the directory exists
    output_dir = "./data/articles"
    os.makedirs(output_dir, exist_ok=True)

    for i, article in enumerate(articles):
        filename = os.path.join(output_dir, f"article_{i+1}.json")
        with open(filename, 'w') as f:
            json.dump(article, f, indent=4)
        print(f"Saved article to {filename}")
