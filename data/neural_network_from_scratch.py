#!/usr/bin/env python3
"""
Complete Neural Network Implementation from Scratch
No external ML libraries - pure NumPy implementation
Includes forward/backward propagation, various optimizers, and regularization
"""

import numpy as np
import json
from typing import List, Tuple, Dict, Optional, Callable
from dataclasses import dataclass
import matplotlib.pyplot as plt
from datetime import datetime


@dataclass
class LayerConfig:
    """Configuration for a neural network layer"""
    units: int
    activation: str
    dropout_rate: float = 0.0
    use_batch_norm: bool = False


class Activation:
    """Collection of activation functions and their derivatives"""
    
    @staticmethod
    def sigmoid(x):
        return 1 / (1 + np.exp(-np.clip(x, -500, 500)))
    
    @staticmethod
    def sigmoid_derivative(x):
        s = Activation.sigmoid(x)
        return s * (1 - s)
    
    @staticmethod
    def tanh(x):
        return np.tanh(x)
    
    @staticmethod
    def tanh_derivative(x):
        return 1 - np.tanh(x) ** 2
    
    @staticmethod
    def relu(x):
        return np.maximum(0, x)
    
    @staticmethod
    def relu_derivative(x):
        return (x > 0).astype(float)
    
    @staticmethod
    def leaky_relu(x, alpha=0.01):
        return np.where(x > 0, x, alpha * x)
    
    @staticmethod
    def leaky_relu_derivative(x, alpha=0.01):
        return np.where(x > 0, 1, alpha)
    
    @staticmethod
    def softmax(x):
        exp_x = np.exp(x - np.max(x, axis=1, keepdims=True))
        return exp_x / np.sum(exp_x, axis=1, keepdims=True)
    
    @staticmethod
    def softmax_derivative(x):
        # For softmax with cross-entropy, derivative simplifies
        return x


class Optimizer:
    """Base class for optimizers"""
    
    def __init__(self, learning_rate: float = 0.01):
        self.learning_rate = learning_rate
    
    def update(self, weights: np.ndarray, gradients: np.ndarray) -> np.ndarray:
        raise NotImplementedError


class SGD(Optimizer):
    """Stochastic Gradient Descent optimizer"""
    
    def update(self, weights: np.ndarray, gradients: np.ndarray) -> np.ndarray:
        return weights - self.learning_rate * gradients


class Momentum(Optimizer):
    """SGD with Momentum optimizer"""
    
    def __init__(self, learning_rate: float = 0.01, momentum: float = 0.9):
        super().__init__(learning_rate)
        self.momentum = momentum
        self.velocity = None
    
    def update(self, weights: np.ndarray, gradients: np.ndarray) -> np.ndarray:
        if self.velocity is None:
            self.velocity = np.zeros_like(weights)
        
        self.velocity = self.momentum * self.velocity - self.learning_rate * gradients
        return weights + self.velocity


class Adam(Optimizer):
    """Adam optimizer"""
    
    def __init__(self, learning_rate: float = 0.001, beta1: float = 0.9, 
                 beta2: float = 0.999, epsilon: float = 1e-8):
        super().__init__(learning_rate)
        self.beta1 = beta1
        self.beta2 = beta2
        self.epsilon = epsilon
        self.m = None
        self.v = None
        self.t = 0
    
    def update(self, weights: np.ndarray, gradients: np.ndarray) -> np.ndarray:
        if self.m is None:
            self.m = np.zeros_like(weights)
            self.v = np.zeros_like(weights)
        
        self.t += 1
        
        # Update biased first moment estimate
        self.m = self.beta1 * self.m + (1 - self.beta1) * gradients
        
        # Update biased second raw moment estimate
        self.v = self.beta2 * self.v + (1 - self.beta2) * (gradients ** 2)
        
        # Compute bias-corrected first moment estimate
        m_hat = self.m / (1 - self.beta1 ** self.t)
        
        # Compute bias-corrected second raw moment estimate
        v_hat = self.v / (1 - self.beta2 ** self.t)
        
        # Update weights
        return weights - self.learning_rate * m_hat / (np.sqrt(v_hat) + self.epsilon)


class Layer:
    """Single neural network layer"""
    
    def __init__(self, input_dim: int, output_dim: int, activation: str = 'relu',
                 weight_init: str = 'he', use_bias: bool = True):
        self.input_dim = input_dim
        self.output_dim = output_dim
        self.activation_name = activation
        self.use_bias = use_bias
        
        # Initialize weights
        if weight_init == 'he':
            # He initialization for ReLU
            self.weights = np.random.randn(input_dim, output_dim) * np.sqrt(2.0 / input_dim)
        elif weight_init == 'xavier':
            # Xavier initialization
            self.weights = np.random.randn(input_dim, output_dim) * np.sqrt(1.0 / input_dim)
        else:
            # Random initialization
            self.weights = np.random.randn(input_dim, output_dim) * 0.01
        
        # Initialize bias
        self.bias = np.zeros((1, output_dim)) if use_bias else None
        
        # Set activation function
        self.set_activation(activation)
        
        # Cache for backpropagation
        self.cache = {}
        
        # Optimizer for this layer
        self.weight_optimizer = None
        self.bias_optimizer = None
    
    def set_activation(self, activation: str):
        """Set activation function and its derivative"""
        activations = {
            'sigmoid': (Activation.sigmoid, Activation.sigmoid_derivative),
            'tanh': (Activation.tanh, Activation.tanh_derivative),
            'relu': (Activation.relu, Activation.relu_derivative),
            'leaky_relu': (Activation.leaky_relu, Activation.leaky_relu_derivative),
            'softmax': (Activation.softmax, Activation.softmax_derivative),
            'linear': (lambda x: x, lambda x: np.ones_like(x))
        }
        
        if activation not in activations:
            raise ValueError(f"Unknown activation: {activation}")
        
        self.activation, self.activation_derivative = activations[activation]
    
    def forward(self, X: np.ndarray, training: bool = True) -> np.ndarray:
        """Forward propagation"""
        self.cache['input'] = X
        
        # Linear transformation
        z = np.dot(X, self.weights)
        if self.use_bias:
            z += self.bias
        
        self.cache['z'] = z
        
        # Apply activation
        output = self.activation(z)
        self.cache['output'] = output
        
        return output
    
    def backward(self, grad_output: np.ndarray) -> np.ndarray:
        """Backward propagation"""
        m = self.cache['input'].shape[0]
        
        # Gradient of activation
        if self.activation_name == 'softmax':
            # For softmax with cross-entropy, gradient is simplified
            grad_z = grad_output
        else:
            grad_z = grad_output * self.activation_derivative(self.cache['z'])
        
        # Gradient of weights
        self.grad_weights = np.dot(self.cache['input'].T, grad_z) / m
        
        # Gradient of bias
        if self.use_bias:
            self.grad_bias = np.sum(grad_z, axis=0, keepdims=True) / m
        
        # Gradient of input
        grad_input = np.dot(grad_z, self.weights.T)
        
        return grad_input
    
    def update_weights(self, optimizer: Optimizer):
        """Update weights using optimizer"""
        if self.weight_optimizer is None:
            self.weight_optimizer = optimizer.__class__(optimizer.learning_rate)
        if self.bias_optimizer is None and self.use_bias:
            self.bias_optimizer = optimizer.__class__(optimizer.learning_rate)
        
        self.weights = self.weight_optimizer.update(self.weights, self.grad_weights)
        if self.use_bias:
            self.bias = self.bias_optimizer.update(self.bias, self.grad_bias)


class NeuralNetwork:
    """Complete neural network implementation"""
    
    def __init__(self, input_dim: int, layer_configs: List[LayerConfig],
                 optimizer: str = 'adam', learning_rate: float = 0.001):
        self.input_dim = input_dim
        self.layers = []
        self.optimizer_name = optimizer
        self.learning_rate = learning_rate
        
        # Build layers
        prev_dim = input_dim
        for config in layer_configs:
            layer = Layer(prev_dim, config.units, config.activation)
            self.layers.append(layer)
            prev_dim = config.units
        
        # Set optimizer
        self.set_optimizer(optimizer, learning_rate)
        
        # Training history
        self.history = {
            'loss': [],
            'accuracy': [],
            'val_loss': [],
            'val_accuracy': []
        }
    
    def set_optimizer(self, optimizer: str, learning_rate: float):
        """Set the optimizer for all layers"""
        optimizers = {
            'sgd': SGD,
            'momentum': Momentum,
            'adam': Adam
        }
        
        if optimizer not in optimizers:
            raise ValueError(f"Unknown optimizer: {optimizer}")
        
        self.optimizer = optimizers[optimizer](learning_rate)
    
    def forward(self, X: np.ndarray, training: bool = True) -> np.ndarray:
        """Forward propagation through all layers"""
        output = X
        for layer in self.layers:
            output = layer.forward(output, training)
        return output
    
    def backward(self, X: np.ndarray, y: np.ndarray, output: np.ndarray):
        """Backward propagation through all layers"""
        # Calculate initial gradient (assuming cross-entropy loss)
        m = X.shape[0]
        grad = output - y  # For softmax with cross-entropy
        
        # Backpropagate through layers
        for layer in reversed(self.layers):
            grad = layer.backward(grad)
    
    def update_weights(self):
        """Update weights for all layers"""
        for layer in self.layers:
            layer.update_weights(self.optimizer)
    
    def compute_loss(self, y_true: np.ndarray, y_pred: np.ndarray, 
                     loss_type: str = 'cross_entropy') -> float:
        """Compute loss"""
        m = y_true.shape[0]
        epsilon = 1e-10  # Small value to avoid log(0)
        
        if loss_type == 'cross_entropy':
            # Cross-entropy loss for classification
            y_pred_clipped = np.clip(y_pred, epsilon, 1 - epsilon)
            loss = -np.sum(y_true * np.log(y_pred_clipped)) / m
        elif loss_type == 'mse':
            # Mean squared error for regression
            loss = np.mean((y_true - y_pred) ** 2)
        else:
            raise ValueError(f"Unknown loss type: {loss_type}")
        
        # Add L2 regularization
        l2_lambda = 0.01
        l2_loss = 0
        for layer in self.layers:
            l2_loss += np.sum(layer.weights ** 2)
        loss += l2_lambda * l2_loss / (2 * m)
        
        return loss
    
    def predict(self, X: np.ndarray) -> np.ndarray:
        """Make predictions"""
        return self.forward(X, training=False)
    
    def predict_classes(self, X: np.ndarray) -> np.ndarray:
        """Predict class labels"""
        predictions = self.predict(X)
        return np.argmax(predictions, axis=1)
    
    def evaluate(self, X: np.ndarray, y: np.ndarray) -> Tuple[float, float]:
        """Evaluate model performance"""
        predictions = self.predict(X)
        loss = self.compute_loss(y, predictions)
        
        # Calculate accuracy for classification
        y_pred_classes = np.argmax(predictions, axis=1)
        y_true_classes = np.argmax(y, axis=1)
        accuracy = np.mean(y_pred_classes == y_true_classes)
        
        return loss, accuracy
    
    def train(self, X_train: np.ndarray, y_train: np.ndarray,
              X_val: Optional[np.ndarray] = None, y_val: Optional[np.ndarray] = None,
              epochs: int = 100, batch_size: int = 32, verbose: bool = True):
        """Train the neural network"""
        n_samples = X_train.shape[0]
        n_batches = n_samples // batch_size
        
        for epoch in range(epochs):
            # Shuffle data
            indices = np.random.permutation(n_samples)
            X_shuffled = X_train[indices]
            y_shuffled = y_train[indices]
            
            epoch_loss = 0
            epoch_accuracy = 0
            
            # Mini-batch training
            for i in range(n_batches):
                start_idx = i * batch_size
                end_idx = min((i + 1) * batch_size, n_samples)
                
                X_batch = X_shuffled[start_idx:end_idx]
                y_batch = y_shuffled[start_idx:end_idx]
                
                # Forward pass
                output = self.forward(X_batch)
                
                # Calculate loss
                batch_loss = self.compute_loss(y_batch, output)
                epoch_loss += batch_loss
                
                # Calculate accuracy
                y_pred_classes = np.argmax(output, axis=1)
                y_true_classes = np.argmax(y_batch, axis=1)
                batch_accuracy = np.mean(y_pred_classes == y_true_classes)
                epoch_accuracy += batch_accuracy
                
                # Backward pass
                self.backward(X_batch, y_batch, output)
                
                # Update weights
                self.update_weights()
            
            # Average metrics
            epoch_loss /= n_batches
            epoch_accuracy /= n_batches
            
            self.history['loss'].append(epoch_loss)
            self.history['accuracy'].append(epoch_accuracy)
            
            # Validation
            if X_val is not None and y_val is not None:
                val_loss, val_accuracy = self.evaluate(X_val, y_val)
                self.history['val_loss'].append(val_loss)
                self.history['val_accuracy'].append(val_accuracy)
            
            # Print progress
            if verbose and (epoch + 1) % 10 == 0:
                print(f"Epoch {epoch + 1}/{epochs}")
                print(f"  Loss: {epoch_loss:.4f}, Accuracy: {epoch_accuracy:.4f}")
                if X_val is not None:
                    print(f"  Val Loss: {val_loss:.4f}, Val Accuracy: {val_accuracy:.4f}")
    
    def plot_history(self):
        """Plot training history"""
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))
        
        # Plot loss
        ax1.plot(self.history['loss'], label='Training Loss')
        if self.history['val_loss']:
            ax1.plot(self.history['val_loss'], label='Validation Loss')
        ax1.set_xlabel('Epoch')
        ax1.set_ylabel('Loss')
        ax1.set_title('Model Loss')
        ax1.legend()
        ax1.grid(True)
        
        # Plot accuracy
        ax2.plot(self.history['accuracy'], label='Training Accuracy')
        if self.history['val_accuracy']:
            ax2.plot(self.history['val_accuracy'], label='Validation Accuracy')
        ax2.set_xlabel('Epoch')
        ax2.set_ylabel('Accuracy')
        ax2.set_title('Model Accuracy')
        ax2.legend()
        ax2.grid(True)
        
        plt.tight_layout()
        plt.savefig('./data/neural_network_training.png')
        plt.close()
        
        print("Training history plot saved to ./data/neural_network_training.png")
    
    def save_model(self, filepath: str):
        """Save model weights and configuration"""
        model_data = {
            'input_dim': self.input_dim,
            'layers': [],
            'optimizer': self.optimizer_name,
            'learning_rate': self.learning_rate,
            'history': self.history
        }
        
        for layer in self.layers:
            layer_data = {
                'weights': layer.weights.tolist(),
                'bias': layer.bias.tolist() if layer.bias is not None else None,
                'input_dim': layer.input_dim,
                'output_dim': layer.output_dim,
                'activation': layer.activation_name
            }
            model_data['layers'].append(layer_data)
        
        with open(filepath, 'w') as f:
            json.dump(model_data, f, indent=2)
        
        print(f"Model saved to {filepath}")
    
    def load_model(self, filepath: str):
        """Load model weights and configuration"""
        with open(filepath, 'r') as f:
            model_data = json.load(f)
        
        self.input_dim = model_data['input_dim']
        self.optimizer_name = model_data['optimizer']
        self.learning_rate = model_data['learning_rate']
        self.history = model_data['history']
        
        self.layers = []
        for layer_data in model_data['layers']:
            layer = Layer(
                layer_data['input_dim'],
                layer_data['output_dim'],
                layer_data['activation']
            )
            layer.weights = np.array(layer_data['weights'])
            if layer_data['bias'] is not None:
                layer.bias = np.array(layer_data['bias'])
            self.layers.append(layer)
        
        print(f"Model loaded from {filepath}")


def create_sample_dataset(n_samples: int = 1000, n_features: int = 20, 
                          n_classes: int = 3) -> Tuple[np.ndarray, np.ndarray]:
    """Create a sample dataset for testing"""
    np.random.seed(42)
    
    # Generate random features
    X = np.random.randn(n_samples, n_features)
    
    # Generate labels based on a simple rule
    y = np.zeros((n_samples, n_classes))
    for i in range(n_samples):
        # Simple classification rule based on feature sum
        feature_sum = np.sum(X[i])
        if feature_sum < -1:
            class_idx = 0
        elif feature_sum < 1:
            class_idx = 1
        else:
            class_idx = 2
        y[i, class_idx] = 1
    
    # Add some noise to make it more challenging
    noise_indices = np.random.choice(n_samples, size=n_samples // 10, replace=False)
    for idx in noise_indices:
        y[idx] = np.roll(y[idx], 1)
    
    return X, y


def main():
    """Example usage of the neural network"""
    print("=" * 60)
    print("NEURAL NETWORK FROM SCRATCH")
    print("=" * 60)
    
    # Create sample dataset
    print("\n1. Creating sample dataset...")
    X, y = create_sample_dataset(n_samples=1000, n_features=20, n_classes=3)
    
    # Split into train and validation sets
    split_idx = int(0.8 * len(X))
    X_train, X_val = X[:split_idx], X[split_idx:]
    y_train, y_val = y[:split_idx], y[split_idx:]
    
    print(f"  Training samples: {X_train.shape[0]}")
    print(f"  Validation samples: {X_val.shape[0]}")
    print(f"  Features: {X_train.shape[1]}")
    print(f"  Classes: {y_train.shape[1]}")
    
    # Define network architecture
    print("\n2. Building neural network...")
    layer_configs = [
        LayerConfig(units=64, activation='relu'),
        LayerConfig(units=32, activation='relu'),
        LayerConfig(units=16, activation='relu'),
        LayerConfig(units=3, activation='softmax')
    ]
    
    # Create neural network
    nn = NeuralNetwork(
        input_dim=X_train.shape[1],
        layer_configs=layer_configs,
        optimizer='adam',
        learning_rate=0.001
    )
    
    print("  Network architecture:")
    print(f"    Input layer: {X_train.shape[1]} neurons")
    for i, config in enumerate(layer_configs):
        print(f"    Hidden layer {i+1}: {config.units} neurons ({config.activation})")
    
    # Train the network
    print("\n3. Training neural network...")
    nn.train(
        X_train, y_train,
        X_val, y_val,
        epochs=100,
        batch_size=32,
        verbose=True
    )
    
    # Evaluate final performance
    print("\n4. Final evaluation...")
    train_loss, train_acc = nn.evaluate(X_train, y_train)
    val_loss, val_acc = nn.evaluate(X_val, y_val)
    
    print(f"  Training - Loss: {train_loss:.4f}, Accuracy: {train_acc:.4f}")
    print(f"  Validation - Loss: {val_loss:.4f}, Accuracy: {val_acc:.4f}")
    
    # Make predictions on a few samples
    print("\n5. Sample predictions...")
    sample_indices = np.random.choice(len(X_val), 5, replace=False)
    for idx in sample_indices:
        sample = X_val[idx:idx+1]
        true_class = np.argmax(y_val[idx])
        pred = nn.predict(sample)
        pred_class = np.argmax(pred)
        confidence = np.max(pred)
        print(f"  Sample {idx}: True={true_class}, Predicted={pred_class}, Confidence={confidence:.2%}")
    
    # Save the model
    print("\n6. Saving model...")
    nn.save_model('./data/neural_network_model.json')
    
    # Plot training history
    print("\n7. Plotting training history...")
    nn.plot_history()
    
    print("\n" + "=" * 60)
    print("Neural network training complete!")
    print("Model saved to ./data/neural_network_model.json")
    print("Training plot saved to ./data/neural_network_training.png")
    print("=" * 60)


if __name__ == "__main__":
    main()