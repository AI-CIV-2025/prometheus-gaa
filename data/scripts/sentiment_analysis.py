import json
import os
from textblob import TextBlob

def analyze_sentiment(text):
    analysis = TextBlob(text)
    polarity = analysis.sentiment.polarity
    subjectivity = analysis.sentiment.subjectivity
    return polarity, subjectivity

if __name__ == "__main__":
    articles_dir = "./data/articles"
    sentiment_results = {}

    for filename in os.listdir(articles_dir):
        if filename.endswith(".json"):
            filepath = os.path.join(articles_dir, filename)
            with open(filepath, 'r') as f:
                article = json.load(f)
                title = article['title']
                polarity, subjectivity = analyze_sentiment(title)
                sentiment_results[filename] = {'polarity': polarity, 'subjectivity': subjectivity}
                print(f"Sentiment analysis for {filename}: Polarity={polarity}, Subjectivity={subjectivity}")

    output_file = "./data/sentiment_analysis_results.json"
    with open(output_file, 'w') as f:
        json.dump(sentiment_results, f, indent=4)
    print(f"Sentiment analysis results saved to {output_file}")
