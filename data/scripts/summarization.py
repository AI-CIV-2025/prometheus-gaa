import json
import os
from transformers import pipeline

def summarize_text(text):
    summarizer = pipeline("summarization", model="facebook/bart-large-cnn")
    summary = summarizer(text, max_length=130, min_length=30, do_sample=False)[0]['summary_text']
    return summary

if __name__ == "__main__":
    articles_dir = "./data/articles"
    summary_results = {}

    for filename in os.listdir(articles_dir):
        if filename.endswith(".json"):
            filepath = os.path.join(articles_dir, filename)
            with open(filepath, 'r') as f:
                article = json.load(f)
                title = article['title']
                link = article['link']
                try:
                    import requests
                    response = requests.get(link, timeout=5)
                    response.raise_for_status()
                    html_content = response.text

                    from bs4 import BeautifulSoup
                    soup = BeautifulSoup(html_content, 'html.parser')
                    paragraphs = soup.find_all('p')
                    article_text = ' '.join([p.get_text() for p in paragraphs])
                    summary = summarize_text(article_text)
                except Exception as e:
                    summary = f"Failed to summarize: {str(e)}"

                summary_results[filename] = summary
                print(f"Summary for {filename}: {summary[:50]}...")

    output_file = "./data/summary_results.json"
    with open(output_file, 'w') as f:
        json.dump(summary_results, f, indent=4)
    print(f"Summarization results saved to {output_file}")
