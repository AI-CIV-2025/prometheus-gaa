import json
from collections import Counter

def generate_trend_report(knowledge_base_file):
    with open(knowledge_base_file, 'r') as f:
        knowledge_base = json.load(f)

    all_topics = []
    all_sentiments = []

    for article_data in knowledge_base.values():
        all_topics.extend(article_data.get('topics', []))
        sentiment = article_data.get('sentiment', {})
        if sentiment:
            all_sentiments.append(sentiment['polarity'])

    topic_counts = Counter(all_topics)
    most_common_topics = topic_counts.most_common(5)

    average_sentiment = sum(all_sentiments) / len(all_sentiments) if all_sentiments else 0

    report = {
        'most_common_topics': most_common_topics,
        'average_sentiment': average_sentiment
    }

    output_file = "./data/trend_report.json"
    with open(output_file, 'w') as f:
        json.dump(report, f, indent=4)
    print(f"Trend report generated and saved to {output_file}")

if __name__ == "__main__":
    knowledge_base_file = "./data/knowledge_base.json"
    generate_trend_report(knowledge_base_file)
