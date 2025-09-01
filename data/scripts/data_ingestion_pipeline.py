#!/usr/bin/env python3
"""
Real-time Data Ingestion and Processing Pipeline
Handles streaming IoT data with Kafka, real-time processing, and storage
"""

import json
import asyncio
import logging
import time
from typing import Dict, List, Any, Optional, Callable
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from collections import defaultdict, deque
import statistics
import hashlib
from enum import Enum
from abc import ABC, abstractmethod
import redis
import psycopg2
from psycopg2.extras import execute_values
from kafka import KafkaProducer, KafkaConsumer
from kafka.errors import KafkaError
import numpy as np


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ProcessingStrategy(Enum):
    """Data processing strategies"""
    STREAM = "stream"
    BATCH = "batch"
    HYBRID = "hybrid"


class AggregationType(Enum):
    """Aggregation types for time-series data"""
    AVG = "average"
    MIN = "minimum"
    MAX = "maximum"
    SUM = "sum"
    COUNT = "count"
    STDDEV = "std_deviation"
    PERCENTILE = "percentile"


@dataclass
class ProcessedData:
    """Processed data structure"""
    device_id: str
    sensor_type: str
    timestamp: str
    raw_value: float
    processed_value: float
    aggregation_window: str
    aggregation_type: str
    anomaly_score: float
    metadata: Dict[str, Any]


class DataProcessor(ABC):
    """Abstract base class for data processors"""
    
    @abstractmethod
    async def process(self, data: Dict[str, Any]) -> ProcessedData:
        pass


class AnomalyDetector:
    """Real-time anomaly detection using statistical methods"""
    
    def __init__(self, window_size: int = 100, z_threshold: float = 3.0):
        self.window_size = window_size
        self.z_threshold = z_threshold
        self.device_histories = defaultdict(lambda: deque(maxlen=window_size))
        
    def detect(self, device_id: str, sensor_type: str, value: float) -> float:
        """
        Detect anomalies using Z-score method
        Returns anomaly score (0-1, where 1 is highly anomalous)
        """
        key = f"{device_id}_{sensor_type}"
        history = self.device_histories[key]
        
        if len(history) < 10:  # Not enough data
            history.append(value)
            return 0.0
        
        mean = statistics.mean(history)
        stdev = statistics.stdev(history)
        
        if stdev == 0:
            z_score = 0
        else:
            z_score = abs((value - mean) / stdev)
        
        history.append(value)
        
        # Normalize to 0-1 scale
        anomaly_score = min(z_score / self.z_threshold, 1.0)
        return anomaly_score


class StreamProcessor(DataProcessor):
    """Real-time stream processing"""
    
    def __init__(self):
        self.anomaly_detector = AnomalyDetector()
        self.processing_rules = self.load_processing_rules()
        
    def load_processing_rules(self) -> Dict[str, Any]:
        """Load data processing rules"""
        return {
            'temperature': {
                'unit_conversion': lambda x: x,  # Already in Celsius
                'validation_range': (-50, 100),
                'smoothing_factor': 0.8
            },
            'humidity': {
                'unit_conversion': lambda x: x,  # Already in percentage
                'validation_range': (0, 100),
                'smoothing_factor': 0.9
            },
            'pressure': {
                'unit_conversion': lambda x: x,  # Already in hPa
                'validation_range': (900, 1100),
                'smoothing_factor': 0.95
            },
            'vibration': {
                'unit_conversion': lambda x: x,  # Already in mm/s
                'validation_range': (0, 50),
                'smoothing_factor': 0.7
            }
        }
    
    async def process(self, data: Dict[str, Any]) -> ProcessedData:
        """Process incoming sensor data"""
        sensor_type = data.get('sensor_type', 'unknown')
        rules = self.processing_rules.get(sensor_type, {})
        
        # Apply unit conversion
        converter = rules.get('unit_conversion', lambda x: x)
        processed_value = converter(data['value'])
        
        # Validate range
        min_val, max_val = rules.get('validation_range', (float('-inf'), float('inf')))
        if not min_val <= processed_value <= max_val:
            logger.warning(f"Value {processed_value} out of range for {sensor_type}")
            processed_value = max(min_val, min(max_val, processed_value))
        
        # Detect anomalies
        anomaly_score = self.anomaly_detector.detect(
            data['device_id'],
            sensor_type,
            processed_value
        )
        
        return ProcessedData(
            device_id=data['device_id'],
            sensor_type=sensor_type,
            timestamp=data['timestamp'],
            raw_value=data['value'],
            processed_value=processed_value,
            aggregation_window='1s',
            aggregation_type='instant',
            anomaly_score=anomaly_score,
            metadata=data.get('metadata', {})
        )


class TimeSeriesAggregator:
    """Aggregates time-series data over different windows"""
    
    def __init__(self):
        self.windows = {
            '1m': timedelta(minutes=1),
            '5m': timedelta(minutes=5),
            '15m': timedelta(minutes=15),
            '1h': timedelta(hours=1),
            '24h': timedelta(hours=24)
        }
        self.buffers = defaultdict(lambda: defaultdict(list))
        
    def add_data(self, device_id: str, sensor_type: str, value: float, timestamp: str):
        """Add data point to aggregation buffers"""
        key = f"{device_id}_{sensor_type}"
        ts = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
        
        for window_name, window_delta in self.windows.items():
            window_key = self.get_window_key(ts, window_delta)
            self.buffers[window_name][f"{key}_{window_key}"].append(value)
    
    def get_window_key(self, timestamp: datetime, delta: timedelta) -> str:
        """Get window key for timestamp"""
        window_start = timestamp - (timestamp - datetime.min) % delta
        return window_start.isoformat()
    
    def compute_aggregates(self, window: str, key: str) -> Dict[str, float]:
        """Compute aggregates for a window"""
        values = self.buffers[window].get(key, [])
        if not values:
            return {}
        
        return {
            'avg': statistics.mean(values),
            'min': min(values),
            'max': max(values),
            'count': len(values),
            'sum': sum(values),
            'stddev': statistics.stdev(values) if len(values) > 1 else 0,
            'p50': statistics.median(values),
            'p95': np.percentile(values, 95) if values else 0,
            'p99': np.percentile(values, 99) if values else 0
        }


class KafkaIngestionPipeline:
    """Kafka-based data ingestion pipeline"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.producer = None
        self.consumer = None
        self.processor = StreamProcessor()
        self.aggregator = TimeSeriesAggregator()
        self.storage = DataStorage(config.get('storage', {}))
        self.cache = CacheManager(config.get('cache', {}))
        
    def initialize(self):
        """Initialize Kafka connections"""
        try:
            self.producer = KafkaProducer(
                bootstrap_servers=self.config['kafka']['brokers'],
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                compression_type='gzip',
                batch_size=16384,
                linger_ms=10
            )
            
            self.consumer = KafkaConsumer(
                self.config['kafka']['input_topic'],
                bootstrap_servers=self.config['kafka']['brokers'],
                auto_offset_reset='latest',
                enable_auto_commit=True,
                group_id=self.config['kafka'].get('consumer_group', 'iot-processor'),
                value_deserializer=lambda m: json.loads(m.decode('utf-8'))
            )
            
            logger.info("Kafka pipeline initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Kafka: {e}")
            raise
    
    async def process_message(self, message: Dict[str, Any]) -> ProcessedData:
        """Process a single message"""
        # Process through stream processor
        processed = await self.processor.process(message)
        
        # Add to aggregation buffers
        self.aggregator.add_data(
            processed.device_id,
            processed.sensor_type,
            processed.processed_value,
            processed.timestamp
        )
        
        # Store in cache for real-time access
        await self.cache.store(processed)
        
        # Store in persistent storage
        await self.storage.store(processed)
        
        return processed
    
    async def run(self):
        """Main processing loop"""
        self.initialize()
        message_count = 0
        start_time = time.time()
        
        try:
            for message in self.consumer:
                try:
                    data = message.value
                    processed = await self.process_message(data)
                    
                    # Send processed data to output topic
                    self.producer.send(
                        self.config['kafka']['output_topic'],
                        value=asdict(processed)
                    )
                    
                    message_count += 1
                    
                    # Log statistics periodically
                    if message_count % 1000 == 0:
                        elapsed = time.time() - start_time
                        rate = message_count / elapsed
                        logger.info(f"Processed {message_count} messages | Rate: {rate:.1f} msg/s")
                        
                        # Trigger aggregate computation
                        await self.compute_and_store_aggregates()
                        
                except Exception as e:
                    logger.error(f"Error processing message: {e}")
                    
        except KeyboardInterrupt:
            logger.info("Shutting down pipeline...")
        finally:
            self.cleanup()
    
    async def compute_and_store_aggregates(self):
        """Compute and store time-window aggregates"""
        for window in self.aggregator.windows.keys():
            for key in list(self.aggregator.buffers[window].keys()):
                aggregates = self.aggregator.compute_aggregates(window, key)
                if aggregates:
                    await self.storage.store_aggregates(window, key, aggregates)
    
    def cleanup(self):
        """Clean up resources"""
        if self.producer:
            self.producer.close()
        if self.consumer:
            self.consumer.close()
        self.storage.close()
        logger.info("Pipeline cleanup complete")


class DataStorage:
    """Handles persistent storage to TimescaleDB"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.connection = None
        self.batch_buffer = []
        self.batch_size = config.get('batch_size', 1000)
        
    def connect(self):
        """Connect to TimescaleDB"""
        try:
            self.connection = psycopg2.connect(
                host=self.config.get('host', 'localhost'),
                port=self.config.get('port', 5432),
                database=self.config.get('database', 'iot_data'),
                user=self.config.get('user', 'iot_user'),
                password=self.config.get('password', 'iot_pass')
            )
            logger.info("Connected to TimescaleDB")
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            raise
    
    async def store(self, data: ProcessedData):
        """Store processed data"""
        self.batch_buffer.append(data)
        
        if len(self.batch_buffer) >= self.batch_size:
            await self.flush_batch()
    
    async def flush_batch(self):
        """Flush batch to database"""
        if not self.batch_buffer:
            return
        
        if not self.connection:
            self.connect()
        
        try:
            with self.connection.cursor() as cursor:
                values = [
                    (
                        d.device_id,
                        d.sensor_type,
                        d.timestamp,
                        d.raw_value,
                        d.processed_value,
                        d.anomaly_score,
                        json.dumps(d.metadata)
                    )
                    for d in self.batch_buffer
                ]
                
                execute_values(
                    cursor,
                    """
                    INSERT INTO sensor_data 
                    (device_id, sensor_type, timestamp, raw_value, processed_value, anomaly_score, metadata)
                    VALUES %s
                    ON CONFLICT (device_id, sensor_type, timestamp) DO UPDATE
                    SET processed_value = EXCLUDED.processed_value,
                        anomaly_score = EXCLUDED.anomaly_score
                    """,
                    values
                )
                
                self.connection.commit()
                logger.debug(f"Flushed {len(self.batch_buffer)} records to database")
                self.batch_buffer.clear()
                
        except Exception as e:
            logger.error(f"Failed to flush batch: {e}")
            self.connection.rollback()
    
    async def store_aggregates(self, window: str, key: str, aggregates: Dict[str, float]):
        """Store aggregated data"""
        if not self.connection:
            self.connect()
        
        try:
            with self.connection.cursor() as cursor:
                device_id, sensor_type, window_start = key.rsplit('_', 2)
                
                cursor.execute(
                    """
                    INSERT INTO sensor_aggregates
                    (device_id, sensor_type, window, window_start, avg_value, min_value, 
                     max_value, count, sum_value, stddev, p50, p95, p99)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (device_id, sensor_type, window, window_start) DO UPDATE
                    SET avg_value = EXCLUDED.avg_value,
                        min_value = EXCLUDED.min_value,
                        max_value = EXCLUDED.max_value,
                        count = EXCLUDED.count,
                        sum_value = EXCLUDED.sum_value,
                        stddev = EXCLUDED.stddev,
                        p50 = EXCLUDED.p50,
                        p95 = EXCLUDED.p95,
                        p99 = EXCLUDED.p99
                    """,
                    (
                        device_id, sensor_type, window, window_start,
                        aggregates.get('avg'), aggregates.get('min'),
                        aggregates.get('max'), aggregates.get('count'),
                        aggregates.get('sum'), aggregates.get('stddev'),
                        aggregates.get('p50'), aggregates.get('p95'),
                        aggregates.get('p99')
                    )
                )
                
                self.connection.commit()
                
        except Exception as e:
            logger.error(f"Failed to store aggregates: {e}")
            self.connection.rollback()
    
    def close(self):
        """Close database connection"""
        if self.connection:
            self.connection.close()
            logger.info("Database connection closed")


class CacheManager:
    """Manages Redis cache for hot data"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.redis_client = None
        self.ttl = config.get('ttl', 3600)  # 1 hour default
        
    def connect(self):
        """Connect to Redis"""
        try:
            self.redis_client = redis.Redis(
                host=self.config.get('host', 'localhost'),
                port=self.config.get('port', 6379),
                decode_responses=True
            )
            self.redis_client.ping()
            logger.info("Connected to Redis cache")
        except Exception as e:
            logger.error(f"Failed to connect to Redis: {e}")
            self.redis_client = None
    
    async def store(self, data: ProcessedData):
        """Store data in cache"""
        if not self.redis_client:
            self.connect()
        
        if not self.redis_client:
            return
        
        try:
            # Store latest value
            key = f"latest:{data.device_id}:{data.sensor_type}"
            value = {
                'value': data.processed_value,
                'timestamp': data.timestamp,
                'anomaly_score': data.anomaly_score
            }
            self.redis_client.setex(key, self.ttl, json.dumps(value))
            
            # Update device list
            self.redis_client.sadd('active_devices', data.device_id)
            
            # Store in time-series sorted set
            ts_key = f"ts:{data.device_id}:{data.sensor_type}"
            score = datetime.fromisoformat(data.timestamp.replace('Z', '+00:00')).timestamp()
            self.redis_client.zadd(ts_key, {json.dumps(value): score})
            
            # Trim old data (keep last 1000 points)
            self.redis_client.zremrangebyrank(ts_key, 0, -1001)
            
        except Exception as e:
            logger.error(f"Failed to store in cache: {e}")


# Configuration loader
def load_config() -> Dict[str, Any]:
    """Load pipeline configuration"""
    return {
        'kafka': {
            'brokers': ['localhost:9092'],
            'input_topic': 'iot-raw-data',
            'output_topic': 'iot-processed-data',
            'consumer_group': 'iot-processor-group'
        },
        'storage': {
            'host': 'localhost',
            'port': 5432,
            'database': 'iot_data',
            'user': 'iot_user',
            'password': 'iot_pass',
            'batch_size': 1000
        },
        'cache': {
            'host': 'localhost',
            'port': 6379,
            'ttl': 3600
        }
    }


async def main():
    """Main entry point"""
    config = load_config()
    pipeline = KafkaIngestionPipeline(config)
    
    logger.info("Starting IoT Data Ingestion Pipeline...")
    await pipeline.run()


if __name__ == "__main__":
    asyncio.run(main())