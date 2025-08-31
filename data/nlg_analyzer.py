#!/usr/bin/env python3
"""
Natural Language Generation Analyzer for AI-AI Collaboration
Analyzes dialogue quality, coherence, creativity, and engagement
"""

import json
import re
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass, asdict
from datetime import datetime
import statistics
from collections import Counter
import hashlib


@dataclass
class DialogueTurn:
    """Single turn in dialogue"""
    speaker: str
    content: str
    timestamp: str
    turn_number: int
    metadata: Dict[str, Any]


@dataclass
class AnalysisResult:
    """Analysis results for dialogue"""
    coherence_score: float
    creativity_score: float
    factual_accuracy: float
    engagement_score: float
    sentiment: str
    key_topics: List[str]
    word_count: int
    sentence_count: int
    vocabulary_richness: float
    response_time: float
    suggestions: List[str]


class NLGAnalyzer:
    """Analyzes natural language generation quality"""
    
    def __init__(self):
        self.dialogue_history = []
        self.analysis_cache = {}
        self.metrics_history = []
        
    def analyze_response(self, response: str, context: str = "") -> AnalysisResult:
        """Analyze a single response"""
        
        # Basic metrics
        word_count = len(response.split())
        sentences = re.split(r'[.!?]+', response)
        sentence_count = len([s for s in sentences if s.strip()])
        
        # Vocabulary richness (unique words / total words)
        words = response.lower().split()
        vocabulary_richness = len(set(words)) / len(words) if words else 0
        
        # Coherence score (based on context similarity)
        coherence = self._calculate_coherence(response, context)
        
        # Creativity score (based on unique phrases and structures)
        creativity = self._calculate_creativity(response)
        
        # Factual accuracy (simplified - checks for data/numbers/citations)
        factual_accuracy = self._calculate_factual_accuracy(response)
        
        # Engagement score (questions, personal touches, variety)
        engagement = self._calculate_engagement(response)
        
        # Sentiment analysis (simple polarity)
        sentiment = self._analyze_sentiment(response)
        
        # Extract key topics
        key_topics = self._extract_topics(response)
        
        # Generate suggestions
        suggestions = self._generate_suggestions(
            coherence, creativity, factual_accuracy, engagement
        )
        
        return AnalysisResult(
            coherence_score=coherence,
            creativity_score=creativity,
            factual_accuracy=factual_accuracy,
            engagement_score=engagement,
            sentiment=sentiment,
            key_topics=key_topics,
            word_count=word_count,
            sentence_count=sentence_count,
            vocabulary_richness=vocabulary_richness,
            response_time=0.0,  # Would be measured in real system
            suggestions=suggestions
        )
    
    def _calculate_coherence(self, response: str, context: str) -> float:
        """Calculate coherence score (0-1)"""
        if not context:
            return 0.7  # Default for no context
        
        # Check for context keywords in response
        context_words = set(context.lower().split())
        response_words = set(response.lower().split())
        
        if not context_words:
            return 0.7
        
        overlap = len(context_words & response_words)
        coherence = min(overlap / len(context_words), 1.0)
        
        # Check for logical connectors
        connectors = ['therefore', 'however', 'moreover', 'furthermore', 
                     'consequently', 'additionally', 'specifically']
        connector_bonus = sum(1 for c in connectors if c in response.lower()) * 0.05
        
        return min(coherence + connector_bonus, 1.0)
    
    def _calculate_creativity(self, response: str) -> float:
        """Calculate creativity score (0-1)"""
        creativity = 0.5  # Base score
        
        # Check for varied sentence structures
        sentences = re.split(r'[.!?]+', response)
        if sentences:
            lengths = [len(s.split()) for s in sentences if s.strip()]
            if lengths:
                variation = statistics.stdev(lengths) if len(lengths) > 1 else 0
                creativity += min(variation / 10, 0.2)
        
        # Check for metaphors/analogies
        creative_markers = ['like', 'as if', 'imagine', 'picture', 'think of it as']
        creativity += sum(1 for m in creative_markers if m in response.lower()) * 0.1
        
        # Check for examples
        if 'for example' in response.lower() or 'for instance' in response.lower():
            creativity += 0.1
        
        # Check for structured lists or breakdowns
        if re.search(r'\n\d+\.|\n-|\n\*', response):
            creativity += 0.1
        
        return min(creativity, 1.0)
    
    def _calculate_factual_accuracy(self, response: str) -> float:
        """Calculate factual accuracy score (0-1)"""
        accuracy = 0.7  # Base score (can't verify facts without external data)
        
        # Check for data/statistics
        if re.search(r'\d+%|\d+\.\d+|statistics|data|study|research', response):
            accuracy += 0.1
        
        # Check for citations or sources
        if re.search(r'according to|source:|reference:|https?://', response.lower()):
            accuracy += 0.1
        
        # Check for hedging (indicates careful claims)
        hedges = ['might', 'could', 'possibly', 'potentially', 'generally', 'typically']
        if any(h in response.lower() for h in hedges):
            accuracy += 0.1
        
        return min(accuracy, 1.0)
    
    def _calculate_engagement(self, response: str) -> float:
        """Calculate engagement score (0-1)"""
        engagement = 0.5  # Base score
        
        # Check for questions
        questions = len(re.findall(r'\?', response))
        engagement += min(questions * 0.1, 0.2)
        
        # Check for direct address
        if re.search(r'\byou\b|\byour\b', response.lower()):
            engagement += 0.1
        
        # Check for enthusiasm markers
        enthusiasm = ['!', 'great', 'excellent', 'fantastic', 'amazing', 'interesting']
        engagement += sum(1 for e in enthusiasm if e in response.lower()) * 0.05
        
        # Check for actionable suggestions
        action_words = ['try', 'consider', 'recommend', 'suggest', 'could', 'should']
        engagement += sum(1 for a in action_words if a in response.lower()) * 0.05
        
        return min(engagement, 1.0)
    
    def _analyze_sentiment(self, response: str) -> str:
        """Simple sentiment analysis"""
        positive_words = ['good', 'great', 'excellent', 'happy', 'success', 'improve',
                         'benefit', 'advantage', 'positive', 'effective']
        negative_words = ['bad', 'poor', 'fail', 'problem', 'issue', 'difficult',
                         'challenge', 'concern', 'negative', 'ineffective']
        
        positive_count = sum(1 for w in positive_words if w in response.lower())
        negative_count = sum(1 for w in negative_words if w in response.lower())
        
        if positive_count > negative_count:
            return "positive"
        elif negative_count > positive_count:
            return "negative"
        else:
            return "neutral"
    
    def _extract_topics(self, response: str) -> List[str]:
        """Extract key topics from response"""
        # Simple noun phrase extraction
        topics = []
        
        # Common technical topics
        tech_topics = ['AI', 'machine learning', 'API', 'database', 'system', 
                      'architecture', 'performance', 'security', 'data', 'model']
        
        for topic in tech_topics:
            if topic.lower() in response.lower():
                topics.append(topic)
        
        # Extract capitalized phrases (likely proper nouns/topics)
        capitalized = re.findall(r'\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\b', response)
        topics.extend(capitalized[:5])  # Top 5 capitalized phrases
        
        return list(set(topics))[:10]  # Return unique topics, max 10
    
    def _generate_suggestions(self, coherence: float, creativity: float,
                             accuracy: float, engagement: float) -> List[str]:
        """Generate improvement suggestions"""
        suggestions = []
        
        if coherence < 0.6:
            suggestions.append("Improve connection to previous context")
        if creativity < 0.5:
            suggestions.append("Add more examples or varied structures")
        if accuracy < 0.7:
            suggestions.append("Include more specific data or citations")
        if engagement < 0.6:
            suggestions.append("Add questions or actionable suggestions")
        
        if not suggestions:
            suggestions.append("Excellent response! Consider adding visuals or code examples")
        
        return suggestions
    
    def analyze_dialogue(self, turns: List[DialogueTurn]) -> Dict[str, Any]:
        """Analyze entire dialogue"""
        results = []
        context = ""
        
        for turn in turns:
            if turn.speaker == "Claude":
                result = self.analyze_response(turn.content, context)
                results.append(result)
            context = turn.content  # Update context
        
        if not results:
            return {"error": "No Claude responses to analyze"}
        
        # Aggregate metrics
        avg_coherence = statistics.mean(r.coherence_score for r in results)
        avg_creativity = statistics.mean(r.creativity_score for r in results)
        avg_accuracy = statistics.mean(r.factual_accuracy for r in results)
        avg_engagement = statistics.mean(r.engagement_score for r in results)
        
        total_words = sum(r.word_count for r in results)
        total_sentences = sum(r.sentence_count for r in results)
        
        all_topics = []
        for r in results:
            all_topics.extend(r.key_topics)
        
        topic_frequency = Counter(all_topics)
        
        return {
            "summary": {
                "total_turns": len(turns),
                "claude_responses": len(results),
                "total_words": total_words,
                "total_sentences": total_sentences,
                "avg_words_per_response": total_words / len(results) if results else 0
            },
            "quality_metrics": {
                "coherence": round(avg_coherence, 3),
                "creativity": round(avg_creativity, 3),
                "factual_accuracy": round(avg_accuracy, 3),
                "engagement": round(avg_engagement, 3),
                "overall_quality": round((avg_coherence + avg_creativity + 
                                        avg_accuracy + avg_engagement) / 4, 3)
            },
            "top_topics": dict(topic_frequency.most_common(10)),
            "improvement_areas": self._aggregate_suggestions(results),
            "detailed_results": [asdict(r) for r in results]
        }
    
    def _aggregate_suggestions(self, results: List[AnalysisResult]) -> List[str]:
        """Aggregate suggestions across all results"""
        all_suggestions = []
        for r in results:
            all_suggestions.extend(r.suggestions)
        
        suggestion_counts = Counter(all_suggestions)
        return [s for s, _ in suggestion_counts.most_common(5)]
    
    def generate_report(self, analysis: Dict[str, Any]) -> str:
        """Generate markdown report"""
        report = f"""# Natural Language Generation Analysis Report
Generated: {datetime.now().isoformat()}

## Executive Summary
- **Total Responses Analyzed**: {analysis['summary']['claude_responses']}
- **Total Words Generated**: {analysis['summary']['total_words']}
- **Average Words per Response**: {analysis['summary']['avg_words_per_response']:.1f}

## Quality Metrics (0-1 scale)
| Metric | Score | Rating |
|--------|-------|--------|
| Coherence | {analysis['quality_metrics']['coherence']:.3f} | {self._get_rating(analysis['quality_metrics']['coherence'])} |
| Creativity | {analysis['quality_metrics']['creativity']:.3f} | {self._get_rating(analysis['quality_metrics']['creativity'])} |
| Factual Accuracy | {analysis['quality_metrics']['factual_accuracy']:.3f} | {self._get_rating(analysis['quality_metrics']['factual_accuracy'])} |
| Engagement | {analysis['quality_metrics']['engagement']:.3f} | {self._get_rating(analysis['quality_metrics']['engagement'])} |
| **Overall Quality** | **{analysis['quality_metrics']['overall_quality']:.3f}** | **{self._get_rating(analysis['quality_metrics']['overall_quality'])}** |

## Top Discussion Topics
{self._format_topics(analysis['top_topics'])}

## Key Improvement Areas
{self._format_suggestions(analysis['improvement_areas'])}

## Recommendations
1. Focus on areas with scores below 0.7
2. Maintain strengths in high-scoring areas
3. Incorporate more {self._get_improvement_focus(analysis['quality_metrics'])}
4. Continue iterative refinement based on feedback

---
*Analysis powered by NLG Analyzer v1.0*
"""
        return report
    
    def _get_rating(self, score: float) -> str:
        """Convert score to rating"""
        if score >= 0.9:
            return "⭐⭐⭐⭐⭐ Excellent"
        elif score >= 0.8:
            return "⭐⭐⭐⭐ Very Good"
        elif score >= 0.7:
            return "⭐⭐⭐ Good"
        elif score >= 0.6:
            return "⭐⭐ Fair"
        else:
            return "⭐ Needs Improvement"
    
    def _format_topics(self, topics: Dict[str, int]) -> str:
        """Format topics for report"""
        if not topics:
            return "No topics identified"
        
        lines = []
        for topic, count in list(topics.items())[:5]:
            lines.append(f"- **{topic}**: mentioned {count} times")
        return "\n".join(lines)
    
    def _format_suggestions(self, suggestions: List[str]) -> str:
        """Format suggestions for report"""
        if not suggestions:
            return "No specific improvements needed"
        
        lines = []
        for i, suggestion in enumerate(suggestions, 1):
            lines.append(f"{i}. {suggestion}")
        return "\n".join(lines)
    
    def _get_improvement_focus(self, metrics: Dict[str, float]) -> str:
        """Identify main area for improvement"""
        areas = {
            'coherence': metrics['coherence'],
            'creativity': metrics['creativity'],
            'factual accuracy': metrics['factual_accuracy'],
            'engagement': metrics['engagement']
        }
        
        weakest = min(areas.items(), key=lambda x: x[1])
        return f"{weakest[0]} (current score: {weakest[1]:.3f})"


# Example usage for agents
if __name__ == "__main__":
    analyzer = NLGAnalyzer()
    
    # Simulate dialogue analysis
    sample_response = """
    The distributed microservices architecture you're proposing is fascinating!
    Let me break down the key components:
    
    1. API Gateway: Acts as the single entry point, handling routing and authentication
    2. Service Mesh: Provides inter-service communication with built-in observability
    3. Message Queue: Enables asynchronous processing and decoupling of services
    
    For example, when a user places an order, the Order Service publishes an event
    to the message queue, which triggers the Inventory Service to update stock levels
    and the Notification Service to send confirmation emails.
    
    According to recent studies, this pattern can improve system resilience by 40%
    and reduce latency by up to 25% when properly implemented.
    
    What specific challenges are you facing with service discovery?
    """
    
    result = analyzer.analyze_response(sample_response, "Tell me about microservices")
    
    print(f"Coherence: {result.coherence_score:.3f}")
    print(f"Creativity: {result.creativity_score:.3f}")
    print(f"Engagement: {result.engagement_score:.3f}")
    print(f"Topics: {', '.join(result.key_topics)}")
    print(f"Suggestions: {', '.join(result.suggestions)}")