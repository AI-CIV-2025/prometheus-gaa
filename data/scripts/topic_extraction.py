import json
import os
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize

nltk.download('stopwords')
nltk.download('punkt')

def extract_topics(text, num_topics=5):
    stop_words = set(stopwords.words('english'))
    word_tokens = word_tokenize(text)
    
    filtered_words = [w.lower() for w in word_tokens if w.isalnum() and w.lower() not in stop_words]
    
    word_counts = {}
    for word in filtered_words:
        if word in word_counts:
            word_counts[word] += 1
        else:
            word_counts[word] = 1

    sorted_words = sorted(word_counts.items(), key=lambda x: x[1], reverse=True)
    top_topics = [word for word, count in sorted_words[:num_topics]]
    return top_topics

if __name__ == "__main__":
    articles_dir = "./data/articles"
    topic_results = {}

    for filename in os.listdir(articles_dir):
        if filename.endswith(".json"):
            filepath = os.path.join(articles_dir, filename)
            with open(filepath, 'r') as f:
                article = json.load(f)
                title = article['title']
                topics = extract_topics(title, num_topics=3)
                topic_results[filename] = topics
                print(f"Topics for {filename}: {topics}")

    output_file = "./data/topic_extraction_results.json"
    with open(output_file, 'w') as f:
        json.dump(topic_results, f, indent=4)
    print(f"Topic extraction results saved to {output_file}")
