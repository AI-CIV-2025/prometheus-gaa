#!/usr/bin/env python3
"""
IoT Sensor Data Simulator - Enterprise Grade
Generates realistic sensor data for testing the IoT Analytics Dashboard
Supports multiple sensor types, realistic patterns, and anomaly injection
"""

import json
import random
import time
import uuid
import math
import asyncio
import argparse
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, asdict
from enum import Enum
import numpy as np
from collections import deque
import hashlib


class SensorType(Enum):
    """Supported IoT sensor types"""
    TEMPERATURE = "temperature"
    HUMIDITY = "humidity"
    PRESSURE = "pressure"
    VIBRATION = "vibration"
    LIGHT = "light"
    CO2 = "co2"
    MOTION = "motion"
    POWER = "power"
    FLOW_RATE = "flow_rate"
    SOUND_LEVEL = "sound_level"


class DeviceStatus(Enum):
    """Device operational status"""
    ONLINE = "online"
    OFFLINE = "offline"
    MAINTENANCE = "maintenance"
    ERROR = "error"
    DEGRADED = "degraded"


@dataclass
class Location:
    """Geographic location for device"""
    latitude: float
    longitude: float
    altitude: float
    building: str
    floor: int
    room: str
    zone: str


@dataclass
class SensorReading:
    """Individual sensor reading"""
    sensor_id: str
    device_id: str
    timestamp: str
    sensor_type: str
    value: float
    unit: str
    quality: float  # 0-1 quality score
    metadata: Dict[str, Any]


@dataclass
class DeviceProfile:
    """IoT device configuration"""
    device_id: str
    device_type: str
    manufacturer: str
    model: str
    firmware_version: str
    location: Location
    sensors: List[SensorType]
    status: DeviceStatus
    battery_level: Optional[float]
    signal_strength: Optional[float]
    last_maintenance: Optional[str]
    installation_date: str


class PatternGenerator:
    """Generates realistic data patterns"""
    
    def __init__(self):
        self.time_offset = 0
        self.anomaly_probability = 0.01
        self.drift_rate = 0.0001
        
    def sine_wave(self, amplitude: float, frequency: float, offset: float, noise: float = 0.1) -> float:
        """Generate sine wave pattern with noise"""
        value = offset + amplitude * math.sin(2 * math.pi * frequency * self.time_offset)
        value += random.gauss(0, noise * amplitude)
        return value
    
    def seasonal_pattern(self, base: float, daily_amp: float, weekly_amp: float) -> float:
        """Generate seasonal pattern (daily + weekly cycles)"""
        hour_of_day = (self.time_offset % 86400) / 3600
        day_of_week = (self.time_offset % 604800) / 86400
        
        daily = daily_amp * math.sin(2 * math.pi * hour_of_day / 24)
        weekly = weekly_amp * math.sin(2 * math.pi * day_of_week / 7)
        
        return base + daily + weekly + random.gauss(0, 0.5)
    
    def random_walk(self, current: float, min_val: float, max_val: float, step: float = 0.1) -> float:
        """Generate random walk pattern"""
        change = random.gauss(0, step)
        new_val = current + change
        
        # Apply boundaries with elastic collision
        if new_val > max_val:
            new_val = max_val - (new_val - max_val) * 0.5
        elif new_val < min_val:
            new_val = min_val + (min_val - new_val) * 0.5
            
        return new_val
    
    def inject_anomaly(self, value: float, severity: str = "medium") -> Tuple[float, bool]:
        """Randomly inject anomalies"""
        if random.random() < self.anomaly_probability:
            if severity == "low":
                value *= random.uniform(1.2, 1.5)
            elif severity == "medium":
                value *= random.uniform(1.5, 2.0)
            elif severity == "high":
                value *= random.uniform(2.0, 3.0)
            elif severity == "critical":
                value *= random.uniform(3.0, 5.0)
            return value, True
        return value, False


class SensorSimulator:
    """Simulates different sensor types with realistic patterns"""
    
    def __init__(self, device_profile: DeviceProfile):
        self.device = device_profile
        self.pattern_gen = PatternGenerator()
        self.sensor_states = {}
        self.initialize_states()
        
    def initialize_states(self):
        """Initialize sensor states with realistic starting values"""
        for sensor_type in self.device.sensors:
            if sensor_type == SensorType.TEMPERATURE:
                self.sensor_states[sensor_type] = {
                    'value': 22.0,
                    'min': -10.0,
                    'max': 50.0,
                    'unit': '°C'
                }
            elif sensor_type == SensorType.HUMIDITY:
                self.sensor_states[sensor_type] = {
                    'value': 45.0,
                    'min': 0.0,
                    'max': 100.0,
                    'unit': '%'
                }
            elif sensor_type == SensorType.PRESSURE:
                self.sensor_states[sensor_type] = {
                    'value': 1013.25,
                    'min': 950.0,
                    'max': 1050.0,
                    'unit': 'hPa'
                }
            elif sensor_type == SensorType.VIBRATION:
                self.sensor_states[sensor_type] = {
                    'value': 0.5,
                    'min': 0.0,
                    'max': 10.0,
                    'unit': 'mm/s'
                }
            elif sensor_type == SensorType.LIGHT:
                self.sensor_states[sensor_type] = {
                    'value': 500.0,
                    'min': 0.0,
                    'max': 100000.0,
                    'unit': 'lux'
                }
            elif sensor_type == SensorType.CO2:
                self.sensor_states[sensor_type] = {
                    'value': 400.0,
                    'min': 300.0,
                    'max': 5000.0,
                    'unit': 'ppm'
                }
            elif sensor_type == SensorType.MOTION:
                self.sensor_states[sensor_type] = {
                    'value': 0.0,
                    'min': 0.0,
                    'max': 1.0,
                    'unit': 'boolean'
                }
            elif sensor_type == SensorType.POWER:
                self.sensor_states[sensor_type] = {
                    'value': 1500.0,
                    'min': 0.0,
                    'max': 10000.0,
                    'unit': 'W'
                }
            elif sensor_type == SensorType.FLOW_RATE:
                self.sensor_states[sensor_type] = {
                    'value': 50.0,
                    'min': 0.0,
                    'max': 200.0,
                    'unit': 'L/min'
                }
            elif sensor_type == SensorType.SOUND_LEVEL:
                self.sensor_states[sensor_type] = {
                    'value': 45.0,
                    'min': 20.0,
                    'max': 120.0,
                    'unit': 'dB'
                }
    
    def generate_reading(self, sensor_type: SensorType) -> SensorReading:
        """Generate a single sensor reading"""
        state = self.sensor_states[sensor_type]
        self.pattern_gen.time_offset += 1
        
        # Generate value based on sensor type
        if sensor_type == SensorType.TEMPERATURE:
            value = self.pattern_gen.seasonal_pattern(22.0, 3.0, 1.0)
        elif sensor_type == SensorType.HUMIDITY:
            value = self.pattern_gen.sine_wave(15.0, 0.00001, 45.0, 0.2)
        elif sensor_type == SensorType.PRESSURE:
            value = self.pattern_gen.random_walk(state['value'], state['min'], state['max'], 0.5)
        elif sensor_type == SensorType.VIBRATION:
            base = self.pattern_gen.sine_wave(0.3, 0.0001, 0.5, 0.1)
            value = abs(base) + random.gauss(0, 0.1)
        elif sensor_type == SensorType.LIGHT:
            hour = datetime.now().hour
            if 6 <= hour <= 18:
                value = self.pattern_gen.sine_wave(30000, 0.00001, 35000, 0.3)
            else:
                value = random.uniform(10, 500)
        elif sensor_type == SensorType.CO2:
            value = self.pattern_gen.seasonal_pattern(400, 50, 20)
        elif sensor_type == SensorType.MOTION:
            value = 1.0 if random.random() < 0.1 else 0.0
        elif sensor_type == SensorType.POWER:
            value = self.pattern_gen.seasonal_pattern(1500, 300, 100)
        elif sensor_type == SensorType.FLOW_RATE:
            value = self.pattern_gen.random_walk(state['value'], state['min'], state['max'], 2.0)
        elif sensor_type == SensorType.SOUND_LEVEL:
            value = self.pattern_gen.sine_wave(10, 0.00005, 45, 0.2)
        else:
            value = state['value']
        
        # Apply boundaries
        value = max(state['min'], min(state['max'], value))
        
        # Inject anomalies
        value, is_anomaly = self.pattern_gen.inject_anomaly(value)
        
        # Update state
        state['value'] = value
        
        # Calculate quality score
        quality = 0.95 + random.uniform(-0.05, 0.05)
        if is_anomaly:
            quality *= 0.7
        
        # Build metadata
        metadata = {
            'location': asdict(self.device.location),
            'device_status': self.device.status.value,
            'is_anomaly': is_anomaly,
            'battery_level': self.device.battery_level,
            'signal_strength': self.device.signal_strength,
            'processing_time_ms': random.uniform(0.1, 2.0)
        }
        
        return SensorReading(
            sensor_id=f"{self.device.device_id}_{sensor_type.value}",
            device_id=self.device.device_id,
            timestamp=datetime.utcnow().isoformat() + 'Z',
            sensor_type=sensor_type.value,
            value=round(value, 3),
            unit=state['unit'],
            quality=round(quality, 3),
            metadata=metadata
        )
    
    def generate_batch(self) -> List[SensorReading]:
        """Generate readings for all sensors"""
        readings = []
        for sensor_type in self.device.sensors:
            if self.device.status == DeviceStatus.ONLINE:
                readings.append(self.generate_reading(sensor_type))
            elif self.device.status == DeviceStatus.DEGRADED and random.random() > 0.3:
                readings.append(self.generate_reading(sensor_type))
        return readings


class IoTFleetSimulator:
    """Simulates an entire fleet of IoT devices"""
    
    def __init__(self, num_devices: int = 100):
        self.devices = self.generate_device_fleet(num_devices)
        self.simulators = [SensorSimulator(device) for device in self.devices]
        self.message_queue = deque(maxlen=10000)
        
    def generate_device_fleet(self, num_devices: int) -> List[DeviceProfile]:
        """Generate a diverse fleet of IoT devices"""
        devices = []
        
        # Device type distributions
        device_configs = [
            {
                'type': 'Environmental Monitor',
                'sensors': [SensorType.TEMPERATURE, SensorType.HUMIDITY, SensorType.CO2, SensorType.PRESSURE],
                'proportion': 0.3
            },
            {
                'type': 'Industrial Sensor',
                'sensors': [SensorType.VIBRATION, SensorType.TEMPERATURE, SensorType.SOUND_LEVEL],
                'proportion': 0.2
            },
            {
                'type': 'Smart Building',
                'sensors': [SensorType.TEMPERATURE, SensorType.HUMIDITY, SensorType.LIGHT, SensorType.MOTION, SensorType.CO2],
                'proportion': 0.25
            },
            {
                'type': 'Power Monitor',
                'sensors': [SensorType.POWER, SensorType.TEMPERATURE],
                'proportion': 0.15
            },
            {
                'type': 'Flow Monitor',
                'sensors': [SensorType.FLOW_RATE, SensorType.PRESSURE, SensorType.TEMPERATURE],
                'proportion': 0.1
            }
        ]
        
        for i in range(num_devices):
            # Select device type based on distribution
            rand = random.random()
            cumulative = 0
            selected_config = device_configs[0]
            
            for config in device_configs:
                cumulative += config['proportion']
                if rand <= cumulative:
                    selected_config = config
                    break
            
            # Generate device location
            location = Location(
                latitude=round(37.7749 + random.uniform(-0.1, 0.1), 6),
                longitude=round(-122.4194 + random.uniform(-0.1, 0.1), 6),
                altitude=round(random.uniform(0, 500), 1),
                building=f"Building-{random.choice(['A', 'B', 'C', 'D', 'E'])}",
                floor=random.randint(1, 10),
                room=f"Room-{random.randint(100, 999)}",
                zone=random.choice(['North', 'South', 'East', 'West', 'Central'])
            )
            
            # Determine device status
            status_probs = {
                DeviceStatus.ONLINE: 0.85,
                DeviceStatus.OFFLINE: 0.05,
                DeviceStatus.MAINTENANCE: 0.05,
                DeviceStatus.ERROR: 0.03,
                DeviceStatus.DEGRADED: 0.02
            }
            
            status = random.choices(
                list(status_probs.keys()),
                weights=list(status_probs.values())
            )[0]
            
            device = DeviceProfile(
                device_id=f"IOT-{uuid.uuid4().hex[:12].upper()}",
                device_type=selected_config['type'],
                manufacturer=random.choice(['Bosch', 'Siemens', 'Honeywell', 'Schneider', 'ABB']),
                model=f"Model-{random.choice(['X200', 'Pro', 'Edge', 'Nano', 'Ultra'])}",
                firmware_version=f"{random.randint(1,3)}.{random.randint(0,9)}.{random.randint(0,99)}",
                location=location,
                sensors=selected_config['sensors'],
                status=status,
                battery_level=random.uniform(10, 100) if random.random() > 0.3 else None,
                signal_strength=random.uniform(-90, -30) if random.random() > 0.2 else None,
                last_maintenance=(datetime.now() - timedelta(days=random.randint(1, 365))).isoformat(),
                installation_date=(datetime.now() - timedelta(days=random.randint(30, 1095))).isoformat()
            )
            
            devices.append(device)
            
        return devices
    
    async def simulate_async(self, duration_seconds: int = 60, interval_ms: int = 1000):
        """Run simulation asynchronously"""
        start_time = time.time()
        readings_count = 0
        
        while time.time() - start_time < duration_seconds:
            tasks = []
            for simulator in self.simulators:
                if simulator.device.status != DeviceStatus.OFFLINE:
                    tasks.append(asyncio.create_task(self.generate_device_data(simulator)))
            
            results = await asyncio.gather(*tasks)
            
            for batch in results:
                for reading in batch:
                    self.message_queue.append(reading)
                    readings_count += len(batch)
            
            # Print statistics
            elapsed = time.time() - start_time
            rate = readings_count / elapsed if elapsed > 0 else 0
            print(f"\\rGenerated {readings_count} readings | Rate: {rate:.1f} readings/sec | Queue: {len(self.message_queue)}", end="")
            
            await asyncio.sleep(interval_ms / 1000)
        
        print(f"\\nSimulation complete. Total readings: {readings_count}")
    
    async def generate_device_data(self, simulator: SensorSimulator) -> List[SensorReading]:
        """Generate data for a single device"""
        return simulator.generate_batch()
    
    def export_to_json(self, output_file: str = "sensor_data.json"):
        """Export generated data to JSON file"""
        data = {
            'metadata': {
                'generated_at': datetime.utcnow().isoformat(),
                'num_devices': len(self.devices),
                'num_readings': len(self.message_queue)
            },
            'devices': [asdict(device) for device in self.devices],
            'readings': [asdict(reading) for reading in self.message_queue]
        }
        
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=2, default=str)
        
        print(f"Data exported to {output_file}")
    
    def export_to_kafka_format(self) -> List[Dict]:
        """Format data for Kafka ingestion"""
        messages = []
        for reading in self.message_queue:
            message = {
                'key': reading.device_id,
                'value': asdict(reading),
                'timestamp': reading.timestamp,
                'headers': {
                    'sensor_type': reading.sensor_type,
                    'device_id': reading.device_id
                }
            }
            messages.append(message)
        return messages


async def main():
    """Main simulation entry point"""
    parser = argparse.ArgumentParser(description='IoT Sensor Data Simulator')
    parser.add_argument('--devices', type=int, default=100, help='Number of devices to simulate')
    parser.add_argument('--duration', type=int, default=60, help='Simulation duration in seconds')
    parser.add_argument('--interval', type=int, default=1000, help='Data generation interval in milliseconds')
    parser.add_argument('--output', type=str, default='sensor_data.json', help='Output file path')
    parser.add_argument('--anomaly-rate', type=float, default=0.01, help='Anomaly injection rate (0-1)')
    
    args = parser.parse_args()
    
    print(f"🚀 Starting IoT Sensor Simulator")
    print(f"   Devices: {args.devices}")
    print(f"   Duration: {args.duration} seconds")
    print(f"   Interval: {args.interval}ms")
    print(f"   Anomaly Rate: {args.anomaly_rate * 100}%\\n")
    
    # Create and run simulator
    simulator = IoTFleetSimulator(num_devices=args.devices)
    simulator.simulators[0].pattern_gen.anomaly_probability = args.anomaly_rate
    
    # Run async simulation
    await simulator.simulate_async(
        duration_seconds=args.duration,
        interval_ms=args.interval
    )
    
    # Export data
    simulator.export_to_json(args.output)
    
    # Print sample data
    print("\\n📊 Sample Generated Data:")
    for reading in list(simulator.message_queue)[:3]:
        print(f"   {reading.sensor_type}: {reading.value} {reading.unit} @ {reading.timestamp}")


if __name__ == "__main__":
    asyncio.run(main())