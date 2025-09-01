#!/usr/bin/env python3
"""
Agent Efficiency Prediction Model
Predicts agent performance metrics using historical data from GAA system
"""

import json
import sqlite3
import numpy as np
from datetime import datetime, timedelta
from dataclasses import dataclass, asdict
from typing import List, Dict, Tuple, Optional
import pickle
import warnings
warnings.filterwarnings('ignore')

# Simple neural network implementation (no external ML libraries)
class NeuralNetwork:
    """Simple feedforward neural network from scratch"""
    
    def __init__(self, layers: List[int], learning_rate: float = 0.01):
        self.layers = layers
        self.learning_rate = learning_rate
        self.weights = []
        self.biases = []
        
        # Initialize weights and biases
        for i in range(len(layers) - 1):
            w = np.random.randn(layers[i], layers[i+1]) * 0.1
            b = np.zeros((1, layers[i+1]))
            self.weights.append(w)
            self.biases.append(b)
    
    def sigmoid(self, x):
        """Sigmoid activation function"""
        return 1 / (1 + np.exp(-np.clip(x, -500, 500)))
    
    def sigmoid_derivative(self, x):
        """Derivative of sigmoid for backpropagation"""
        return x * (1 - x)
    
    def relu(self, x):
        """ReLU activation function"""
        return np.maximum(0, x)
    
    def relu_derivative(self, x):
        """Derivative of ReLU"""
        return (x > 0).astype(float)
    
    def forward(self, X):
        """Forward propagation"""
        self.activations = [X]
        
        for i in range(len(self.weights)):
            z = np.dot(self.activations[-1], self.weights[i]) + self.biases[i]
            
            # Use ReLU for hidden layers, sigmoid for output
            if i < len(self.weights) - 1:
                a = self.relu(z)
            else:
                a = self.sigmoid(z)
            
            self.activations.append(a)
        
        return self.activations[-1]
    
    def backward(self, X, y, output):
        """Backward propagation"""
        m = X.shape[0]
        self.gradients_w = []
        self.gradients_b = []
        
        # Calculate output layer gradients
        delta = output - y
        
        for i in range(len(self.weights) - 1, -1, -1):
            grad_w = np.dot(self.activations[i].T, delta) / m
            grad_b = np.sum(delta, axis=0, keepdims=True) / m
            
            self.gradients_w.insert(0, grad_w)
            self.gradients_b.insert(0, grad_b)
            
            if i > 0:
                # Calculate delta for previous layer
                delta = np.dot(delta, self.weights[i].T)
                if i < len(self.weights):
                    delta *= self.relu_derivative(self.activations[i])
    
    def update_weights(self):
        """Update weights using gradients"""
        for i in range(len(self.weights)):
            self.weights[i] -= self.learning_rate * self.gradients_w[i]
            self.biases[i] -= self.learning_rate * self.gradients_b[i]
    
    def train(self, X, y, epochs=1000, verbose=True):
        """Train the neural network"""
        losses = []
        
        for epoch in range(epochs):
            # Forward propagation
            output = self.forward(X)
            
            # Calculate loss (MSE)
            loss = np.mean((output - y) ** 2)
            losses.append(loss)
            
            # Backward propagation
            self.backward(X, y, output)
            
            # Update weights
            self.update_weights()
            
            if verbose and epoch % 100 == 0:
                print(f"Epoch {epoch}, Loss: {loss:.6f}")
        
        return losses
    
    def predict(self, X):
        """Make predictions"""
        return self.forward(X)


@dataclass
class AgentMetrics:
    """Container for agent performance metrics"""
    loop_number: int
    timestamp: str
    execution_time: float
    steps_planned: int
    steps_approved: int
    steps_executed: int
    success_rate: float
    api_calls: int
    memory_usage: float
    reflection_quality: float
    artifacts_created: int
    error_count: int


class AgentEfficiencyPredictor:
    """Predicts agent efficiency based on historical performance"""
    
    def __init__(self, db_path: str = "./data/gaa.db"):
        self.db_path = db_path
        self.model = None
        self.scaler_params = {}
        self.feature_names = [
            'hour_of_day', 'day_of_week', 'loop_number_norm',
            'recent_success_rate', 'recent_api_calls_avg',
            'recent_error_rate', 'memory_pressure',
            'complexity_score', 'learning_rate'
        ]
        self.target_names = [
            'predicted_success_rate', 'predicted_execution_time',
            'predicted_api_calls', 'predicted_artifacts'
        ]
    
    def extract_features(self, metrics: List[AgentMetrics]) -> np.ndarray:
        """Extract features from agent metrics"""
        features = []
        
        for i, m in enumerate(metrics):
            dt = datetime.fromisoformat(m.timestamp.replace('Z', '+00:00'))
            
            # Time-based features
            hour_of_day = dt.hour / 24.0
            day_of_week = dt.weekday() / 7.0
            
            # Normalized loop number
            loop_number_norm = m.loop_number / 100.0
            
            # Recent performance (looking back 5 loops)
            lookback = min(5, i)
            if lookback > 0:
                recent = metrics[max(0, i-lookback):i]
                recent_success_rate = np.mean([r.success_rate for r in recent])
                recent_api_calls_avg = np.mean([r.api_calls for r in recent])
                recent_error_rate = np.mean([r.error_count for r in recent]) / 10.0
            else:
                recent_success_rate = 0.5
                recent_api_calls_avg = 30.0
                recent_error_rate = 0.1
            
            # Memory pressure
            memory_pressure = m.memory_usage / 100.0
            
            # Complexity score (based on planned steps)
            complexity_score = min(m.steps_planned / 20.0, 1.0)
            
            # Learning rate (improvement over time)
            if i > 10:
                old_success = np.mean([r.success_rate for r in metrics[max(0, i-20):max(1, i-10)]])
                new_success = np.mean([r.success_rate for r in metrics[max(0, i-10):i]])
                learning_rate = (new_success - old_success + 1.0) / 2.0
            else:
                learning_rate = 0.5
            
            features.append([
                hour_of_day, day_of_week, loop_number_norm,
                recent_success_rate, recent_api_calls_avg / 50.0,
                recent_error_rate, memory_pressure,
                complexity_score, learning_rate
            ])
        
        return np.array(features)
    
    def extract_targets(self, metrics: List[AgentMetrics]) -> np.ndarray:
        """Extract target values from metrics"""
        targets = []
        
        for m in metrics:
            targets.append([
                m.success_rate,
                min(m.execution_time / 300.0, 1.0),  # Normalize to 5 minutes max
                min(m.api_calls / 50.0, 1.0),  # Normalize to 50 calls max
                min(m.artifacts_created / 10.0, 1.0)  # Normalize to 10 artifacts max
            ])
        
        return np.array(targets)
    
    def generate_synthetic_data(self, n_samples: int = 1000) -> List[AgentMetrics]:
        """Generate synthetic training data based on observed patterns"""
        metrics = []
        base_time = datetime.now() - timedelta(days=30)
        
        for i in range(n_samples):
            # Simulate improving performance over time
            loop_number = i + 1
            timestamp = (base_time + timedelta(minutes=i*10)).isoformat()
            
            # Performance improves logarithmically
            base_success = 0.3 + 0.5 * np.log(loop_number + 1) / np.log(n_samples + 1)
            success_rate = np.clip(base_success + np.random.normal(0, 0.1), 0, 1)
            
            # Execution time decreases over time
            execution_time = max(10, 180 - loop_number * 0.1 + np.random.normal(0, 20))
            
            # API calls decrease as agents get more efficient
            api_calls = max(3, int(40 - loop_number * 0.02 + np.random.normal(0, 5)))
            
            # Steps correlate with complexity
            steps_planned = np.random.randint(3, 15)
            steps_approved = int(steps_planned * success_rate * np.random.uniform(0.8, 1.0))
            steps_executed = int(steps_approved * np.random.uniform(0.9, 1.0))
            
            # Memory usage is relatively stable with slight growth
            memory_usage = 20 + loop_number * 0.01 + np.random.normal(0, 5)
            
            # Reflection quality improves over time
            reflection_quality = np.clip(0.4 + loop_number * 0.0005 + np.random.normal(0, 0.1), 0, 1)
            
            # Artifacts created increases with success
            artifacts_created = int(success_rate * np.random.randint(0, 5))
            
            # Errors decrease over time
            error_count = max(0, int(5 - loop_number * 0.004 + np.random.normal(0, 1)))
            
            metrics.append(AgentMetrics(
                loop_number=loop_number,
                timestamp=timestamp,
                execution_time=execution_time,
                steps_planned=steps_planned,
                steps_approved=steps_approved,
                steps_executed=steps_executed,
                success_rate=success_rate,
                api_calls=api_calls,
                memory_usage=memory_usage,
                reflection_quality=reflection_quality,
                artifacts_created=artifacts_created,
                error_count=error_count
            ))
        
        return metrics
    
    def train(self, metrics: Optional[List[AgentMetrics]] = None):
        """Train the prediction model"""
        if metrics is None:
            print("Generating synthetic training data...")
            metrics = self.generate_synthetic_data(1000)
        
        print(f"Training on {len(metrics)} samples...")
        
        # Extract features and targets
        X = self.extract_features(metrics)
        y = self.extract_targets(metrics)
        
        # Create neural network
        self.model = NeuralNetwork(
            layers=[len(self.feature_names), 16, 8, len(self.target_names)],
            learning_rate=0.01
        )
        
        # Train the model
        losses = self.model.train(X, y, epochs=500, verbose=True)
        
        # Calculate final metrics
        predictions = self.model.predict(X)
        mse = np.mean((predictions - y) ** 2)
        mae = np.mean(np.abs(predictions - y))
        
        print(f"\nTraining Complete!")
        print(f"Final MSE: {mse:.6f}")
        print(f"Final MAE: {mae:.6f}")
        
        return losses
    
    def predict_next_loop(self, recent_metrics: List[AgentMetrics]) -> Dict[str, float]:
        """Predict performance for the next loop"""
        if self.model is None:
            raise ValueError("Model not trained yet. Call train() first.")
        
        # Create synthetic next loop metrics for feature extraction
        last_metric = recent_metrics[-1]
        next_metric = AgentMetrics(
            loop_number=last_metric.loop_number + 1,
            timestamp=datetime.now().isoformat(),
            execution_time=0,  # To be predicted
            steps_planned=10,  # Estimate
            steps_approved=0,  # To be predicted
            steps_executed=0,  # To be predicted
            success_rate=0,  # To be predicted
            api_calls=0,  # To be predicted
            memory_usage=last_metric.memory_usage * 1.01,
            reflection_quality=last_metric.reflection_quality,
            artifacts_created=0,  # To be predicted
            error_count=0
        )
        
        # Add to metrics for feature extraction
        metrics_with_next = recent_metrics + [next_metric]
        
        # Extract features for the last item (our prediction target)
        X = self.extract_features(metrics_with_next)
        X_next = X[-1:, :]
        
        # Make prediction
        prediction = self.model.predict(X_next)[0]
        
        return {
            'predicted_success_rate': float(prediction[0]),
            'predicted_execution_time': float(prediction[1] * 300),  # Denormalize
            'predicted_api_calls': int(prediction[2] * 50),  # Denormalize
            'predicted_artifacts': int(prediction[3] * 10),  # Denormalize
            'confidence': float(1.0 - np.std(prediction))  # Simple confidence metric
        }
    
    def analyze_trends(self, metrics: List[AgentMetrics]) -> Dict[str, Any]:
        """Analyze trends in agent performance"""
        if len(metrics) < 10:
            return {"error": "Insufficient data for trend analysis"}
        
        # Calculate moving averages
        window = min(10, len(metrics) // 3)
        
        success_rates = [m.success_rate for m in metrics]
        api_calls = [m.api_calls for m in metrics]
        execution_times = [m.execution_time for m in metrics]
        
        # Calculate trends
        recent_success = np.mean(success_rates[-window:])
        historical_success = np.mean(success_rates[:-window])
        success_trend = "improving" if recent_success > historical_success else "declining"
        
        recent_api = np.mean(api_calls[-window:])
        historical_api = np.mean(api_calls[:-window])
        efficiency_trend = "improving" if recent_api < historical_api else "declining"
        
        # Find patterns
        hourly_performance = {}
        for m in metrics:
            dt = datetime.fromisoformat(m.timestamp.replace('Z', '+00:00'))
            hour = dt.hour
            if hour not in hourly_performance:
                hourly_performance[hour] = []
            hourly_performance[hour].append(m.success_rate)
        
        best_hour = max(hourly_performance.items(), 
                       key=lambda x: np.mean(x[1]) if x[1] else 0)[0]
        
        return {
            'success_trend': success_trend,
            'success_improvement': float(recent_success - historical_success),
            'efficiency_trend': efficiency_trend,
            'api_reduction': float(historical_api - recent_api),
            'best_performance_hour': best_hour,
            'current_success_rate': float(success_rates[-1]),
            'average_success_rate': float(np.mean(success_rates)),
            'peak_success_rate': float(max(success_rates)),
            'total_artifacts_created': sum(m.artifacts_created for m in metrics),
            'average_execution_time': float(np.mean(execution_times))
        }
    
    def save_model(self, filepath: str = "./data/agent_model.pkl"):
        """Save the trained model"""
        if self.model is None:
            raise ValueError("No model to save")
        
        with open(filepath, 'wb') as f:
            pickle.dump({
                'model': self.model,
                'feature_names': self.feature_names,
                'target_names': self.target_names
            }, f)
        print(f"Model saved to {filepath}")
    
    def load_model(self, filepath: str = "./data/agent_model.pkl"):
        """Load a trained model"""
        with open(filepath, 'rb') as f:
            data = pickle.load(f)
            self.model = data['model']
            self.feature_names = data['feature_names']
            self.target_names = data['target_names']
        print(f"Model loaded from {filepath}")


def main():
    """Example usage and testing"""
    print("=" * 60)
    print("AGENT EFFICIENCY PREDICTION MODEL")
    print("=" * 60)
    
    # Initialize predictor
    predictor = AgentEfficiencyPredictor()
    
    # Generate synthetic historical data
    print("\n1. Generating synthetic historical data...")
    historical_metrics = predictor.generate_synthetic_data(500)
    
    # Train the model
    print("\n2. Training prediction model...")
    losses = predictor.train(historical_metrics)
    
    # Analyze trends
    print("\n3. Analyzing performance trends...")
    trends = predictor.analyze_trends(historical_metrics)
    print("\nTrend Analysis:")
    for key, value in trends.items():
        if isinstance(value, float):
            print(f"  {key}: {value:.3f}")
        else:
            print(f"  {key}: {value}")
    
    # Make predictions for next loop
    print("\n4. Predicting next loop performance...")
    recent_metrics = historical_metrics[-20:]  # Last 20 loops
    prediction = predictor.predict_next_loop(recent_metrics)
    
    print("\nNext Loop Predictions:")
    print(f"  Success Rate: {prediction['predicted_success_rate']:.1%}")
    print(f"  Execution Time: {prediction['predicted_execution_time']:.1f} seconds")
    print(f"  API Calls: {prediction['predicted_api_calls']}")
    print(f"  Artifacts Expected: {prediction['predicted_artifacts']}")
    print(f"  Confidence: {prediction['confidence']:.1%}")
    
    # Save the model
    print("\n5. Saving trained model...")
    predictor.save_model()
    
    # Generate recommendations
    print("\n6. Recommendations:")
    if trends['success_trend'] == 'improving':
        print("  ✅ Performance is improving - maintain current strategies")
    else:
        print("  ⚠️ Performance declining - consider adjusting prompts or reducing complexity")
    
    if trends['efficiency_trend'] == 'improving':
        print("  ✅ API efficiency improving - good optimization")
    else:
        print("  ⚠️ API usage increasing - implement caching or batch operations")
    
    print(f"  💡 Best performance observed at hour {trends['best_performance_hour']}:00")
    print(f"  📊 Total artifacts created: {trends['total_artifacts_created']}")
    
    print("\n" + "=" * 60)
    print("Model training complete! Ready for production use.")
    print("=" * 60)


if __name__ == "__main__":
    main()