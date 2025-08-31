# sentiment_analyzer.py
import nltk
from nltk.sentiment import SentimentIntensityAnalyzer

nltk.download('vader_lexicon', download_dir='./data/sentiment_analysis')

class SentimentAnalyzer:
    def __init__(self):
        self.sid = SentimentIntensityAnalyzer()

    def analyze_sentiment(self, text):
        scores = self.sid.polarity_scores(text)
        return scores

if __name__ == '__main__':
    analyzer = SentimentAnalyzer()
    text = "This is a great product! I love it."
    sentiment = analyzer.analyze_sentiment(text)
    print(sentiment)
