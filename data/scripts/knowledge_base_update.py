import json
import os

def update_knowledge_base(articles_dir, sentiment_file, topic_file, summary_file):
    knowledge_base = {}

    with open(sentiment_file, 'r') as f:
        sentiment_data = json.load(f)
    with open(topic_file, 'r') as f:
        topic_data = json.load(f)
    with open(summary_file, 'r') as f:
        summary_data = json.load(f)

    for filename in os.listdir(articles_dir):
        if filename.endswith(".json"):
            filepath = os.path.join(articles_dir, filename)
            with open(filepath, 'r') as f:
                article = json.load(f)
                article_name = filename
                knowledge_base[article_name] = {
                    'title': article['title'],
                    'link': article['link'],
                    'source': article['source'],
                    'sentiment': sentiment_data.get(article_name, {}),
                    'topics': topic_data.get(article_name, []),
                    'summary': summary_data.get(article_name, "No summary available")
                }

    output_file = "./data/knowledge_base.json"
    with open(output_file, 'w') as f:
        json.dump(knowledge_base, f, indent=4)
    print(f"Knowledge base updated and saved to {output_file}")

if __name__ == "__main__":
    articles_dir = "./data/articles"
    sentiment_file = "./data/sentiment_analysis_results.json"
    topic_file = "./data/topic_extraction_results.json"
    summary_file = "./data/summary_results.json"

    update_knowledge_base(articles_dir, sentiment_file, topic_file, summary_file)
