#!/usr/bin/env python3
"""
Memory Resource Manager for GAA System
Monitors and optimizes memory usage, provides caching, and prevents OOM
"""

import os
import sys
import json
import time
import psutil
import sqlite3
import hashlib
import gc
import tracemalloc
from typing import Dict, Any, Optional, List, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from collections import OrderedDict, defaultdict
import pickle


@dataclass
class MemorySnapshot:
    """Memory usage snapshot"""
    timestamp: str
    total_mb: float
    available_mb: float
    percent_used: float
    process_mb: float
    cache_size_mb: float
    gc_count: int
    largest_objects: List[Tuple[str, float]]


class LRUCache:
    """Least Recently Used cache with size limit"""
    
    def __init__(self, max_size_mb: float = 100):
        self.max_size_mb = max_size_mb
        self.cache = OrderedDict()
        self.size_tracker = {}
        self.current_size_mb = 0
        self.hits = 0
        self.misses = 0
    
    def _get_size_mb(self, obj: Any) -> float:
        """Estimate object size in MB"""
        try:
            return sys.getsizeof(pickle.dumps(obj)) / (1024 * 1024)
        except:
            return 0.1  # Default small size
    
    def get(self, key: str) -> Optional[Any]:
        """Get item from cache"""
        if key in self.cache:
            self.hits += 1
            # Move to end (most recently used)
            self.cache.move_to_end(key)
            return self.cache[key]
        self.misses += 1
        return None
    
    def put(self, key: str, value: Any):
        """Put item in cache"""
        size_mb = self._get_size_mb(value)
        
        # Remove items if cache would exceed limit
        while self.current_size_mb + size_mb > self.max_size_mb and self.cache:
            self._evict_oldest()
        
        # Add new item
        self.cache[key] = value
        self.size_tracker[key] = size_mb
        self.current_size_mb += size_mb
        
        # Move to end (most recently used)
        self.cache.move_to_end(key)
    
    def _evict_oldest(self):
        """Remove least recently used item"""
        if self.cache:
            key, _ = self.cache.popitem(last=False)
            size = self.size_tracker.pop(key, 0)
            self.current_size_mb -= size
    
    def clear(self):
        """Clear entire cache"""
        self.cache.clear()
        self.size_tracker.clear()
        self.current_size_mb = 0
        gc.collect()
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics"""
        total_requests = self.hits + self.misses
        hit_rate = self.hits / total_requests if total_requests > 0 else 0
        
        return {
            'size_mb': self.current_size_mb,
            'max_size_mb': self.max_size_mb,
            'items': len(self.cache),
            'hits': self.hits,
            'misses': self.misses,
            'hit_rate': hit_rate
        }


class MemoryManager:
    """Comprehensive memory management for agents"""
    
    def __init__(self, db_path: str = "./data/gaa.db", 
                 warning_threshold: float = 80.0,
                 critical_threshold: float = 90.0):
        self.db_path = db_path
        self.warning_threshold = warning_threshold
        self.critical_threshold = critical_threshold
        
        # Initialize caches
        self.result_cache = LRUCache(max_size_mb=50)
        self.reflection_cache = LRUCache(max_size_mb=30)
        self.plan_cache = LRUCache(max_size_mb=20)
        
        # Memory tracking
        self.snapshots = []
        self.memory_leaks = {}
        
        # Start memory tracing
        tracemalloc.start()
        
        # Initialize database
        self._init_database()
    
    def _init_database(self):
        """Initialize memory tracking database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS memory_snapshots (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                total_mb REAL,
                available_mb REAL,
                percent_used REAL,
                process_mb REAL,
                cache_size_mb REAL,
                gc_count INTEGER
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS memory_optimizations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                action TEXT,
                memory_saved_mb REAL,
                details TEXT
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def take_snapshot(self) -> MemorySnapshot:
        """Take current memory snapshot"""
        # System memory
        mem = psutil.virtual_memory()
        total_mb = mem.total / (1024 * 1024)
        available_mb = mem.available / (1024 * 1024)
        percent_used = mem.percent
        
        # Process memory
        process = psutil.Process()
        process_mb = process.memory_info().rss / (1024 * 1024)
        
        # Cache size
        cache_size_mb = (
            self.result_cache.current_size_mb +
            self.reflection_cache.current_size_mb +
            self.plan_cache.current_size_mb
        )
        
        # GC stats
        gc_stats = gc.get_stats()
        gc_count = sum(s.get('collections', 0) for s in gc_stats)
        
        # Find largest objects
        snapshot = tracemalloc.take_snapshot()
        top_stats = snapshot.statistics('lineno')[:5]
        largest_objects = [
            (str(stat.traceback), stat.size / (1024 * 1024))
            for stat in top_stats
        ]
        
        return MemorySnapshot(
            timestamp=datetime.now().isoformat(),
            total_mb=total_mb,
            available_mb=available_mb,
            percent_used=percent_used,
            process_mb=process_mb,
            cache_size_mb=cache_size_mb,
            gc_count=gc_count,
            largest_objects=largest_objects
        )
    
    def monitor(self) -> Dict[str, Any]:
        """Monitor memory and take action if needed"""
        snapshot = self.take_snapshot()
        self.snapshots.append(snapshot)
        
        # Keep only recent snapshots
        if len(self.snapshots) > 100:
            self.snapshots = self.snapshots[-100:]
        
        # Save to database
        self._save_snapshot(snapshot)
        
        status = "normal"
        actions_taken = []
        
        # Check thresholds
        if snapshot.percent_used > self.critical_threshold:
            status = "critical"
            actions_taken.extend(self._handle_critical_memory())
        elif snapshot.percent_used > self.warning_threshold:
            status = "warning"
            actions_taken.extend(self._handle_warning_memory())
        
        # Detect memory leaks
        self._detect_memory_leaks()
        
        return {
            'status': status,
            'memory_used_percent': snapshot.percent_used,
            'process_mb': snapshot.process_mb,
            'cache_mb': snapshot.cache_size_mb,
            'actions_taken': actions_taken,
            'recommendations': self._get_recommendations()
        }
    
    def _handle_warning_memory(self) -> List[str]:
        """Handle warning level memory usage"""
        actions = []
        
        # Clear old cache entries
        before_mb = self.result_cache.current_size_mb
        self._trim_cache(self.result_cache, 0.7)  # Keep 70%
        after_mb = self.result_cache.current_size_mb
        saved_mb = before_mb - after_mb
        
        if saved_mb > 0:
            actions.append(f"Trimmed result cache, saved {saved_mb:.2f} MB")
            self._log_optimization("cache_trim", saved_mb, "Warning threshold triggered")
        
        # Force garbage collection
        gc.collect()
        actions.append("Forced garbage collection")
        
        return actions
    
    def _handle_critical_memory(self) -> List[str]:
        """Handle critical level memory usage"""
        actions = []
        
        # Clear all caches
        total_cleared = (
            self.result_cache.current_size_mb +
            self.reflection_cache.current_size_mb +
            self.plan_cache.current_size_mb
        )
        
        self.result_cache.clear()
        self.reflection_cache.clear()
        self.plan_cache.clear()
        
        actions.append(f"Cleared all caches, freed {total_cleared:.2f} MB")
        self._log_optimization("cache_clear", total_cleared, "Critical threshold triggered")
        
        # Aggressive garbage collection
        gc.collect(2)  # Full collection
        actions.append("Performed full garbage collection")
        
        # Compress old data in database
        self._compress_old_data()
        actions.append("Compressed old database records")
        
        return actions
    
    def _trim_cache(self, cache: LRUCache, keep_ratio: float):
        """Trim cache to percentage of current size"""
        target_size = cache.current_size_mb * keep_ratio
        while cache.current_size_mb > target_size and cache.cache:
            cache._evict_oldest()
    
    def _detect_memory_leaks(self):
        """Detect potential memory leaks"""
        if len(self.snapshots) < 10:
            return
        
        # Check if memory is consistently increasing
        recent = self.snapshots[-10:]
        memory_trend = [s.process_mb for s in recent]
        
        # Simple leak detection: consistent increase
        increases = sum(1 for i in range(1, len(memory_trend)) 
                       if memory_trend[i] > memory_trend[i-1])
        
        if increases > 7:  # More than 70% increases
            avg_increase = (memory_trend[-1] - memory_trend[0]) / len(memory_trend)
            self.memory_leaks['suspected'] = {
                'avg_increase_mb': avg_increase,
                'detected_at': datetime.now().isoformat()
            }
    
    def _compress_old_data(self):
        """Compress old data in database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Delete old snapshots (keep last 1000)
        cursor.execute('''
            DELETE FROM memory_snapshots 
            WHERE id NOT IN (
                SELECT id FROM memory_snapshots 
                ORDER BY timestamp DESC LIMIT 1000
            )
        ''')
        
        # Vacuum to reclaim space
        conn.execute("VACUUM")
        
        conn.commit()
        conn.close()
    
    def _save_snapshot(self, snapshot: MemorySnapshot):
        """Save snapshot to database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO memory_snapshots 
            (timestamp, total_mb, available_mb, percent_used, process_mb, cache_size_mb, gc_count)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            snapshot.timestamp,
            snapshot.total_mb,
            snapshot.available_mb,
            snapshot.percent_used,
            snapshot.process_mb,
            snapshot.cache_size_mb,
            snapshot.gc_count
        ))
        
        conn.commit()
        conn.close()
    
    def _log_optimization(self, action: str, saved_mb: float, details: str):
        """Log memory optimization action"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO memory_optimizations 
            (timestamp, action, memory_saved_mb, details)
            VALUES (?, ?, ?, ?)
        ''', (datetime.now().isoformat(), action, saved_mb, details))
        
        conn.commit()
        conn.close()
    
    def _get_recommendations(self) -> List[str]:
        """Get memory optimization recommendations"""
        recommendations = []
        
        if self.snapshots:
            latest = self.snapshots[-1]
            
            if latest.percent_used > 70:
                recommendations.append("Consider increasing system memory")
            
            if latest.cache_size_mb > 50:
                recommendations.append("Cache size is large, consider reducing cache limits")
            
            if 'suspected' in self.memory_leaks:
                recommendations.append("Memory leak suspected, restart may be needed")
            
            # Check cache efficiency
            result_stats = self.result_cache.get_stats()
            if result_stats['hit_rate'] < 0.3:
                recommendations.append("Low cache hit rate, consider adjusting caching strategy")
        
        return recommendations
    
    def optimize_for_task(self, task_type: str) -> Dict[str, Any]:
        """Optimize memory for specific task type"""
        optimizations = {
            'planning': {
                'result_cache': 30,
                'reflection_cache': 20,
                'plan_cache': 50
            },
            'execution': {
                'result_cache': 60,
                'reflection_cache': 10,
                'plan_cache': 30
            },
            'reflection': {
                'result_cache': 20,
                'reflection_cache': 60,
                'plan_cache': 20
            }
        }
        
        if task_type in optimizations:
            config = optimizations[task_type]
            self.result_cache.max_size_mb = config['result_cache']
            self.reflection_cache.max_size_mb = config['reflection_cache']
            self.plan_cache.max_size_mb = config['plan_cache']
            
            return {
                'optimized_for': task_type,
                'cache_limits': config
            }
        
        return {'error': f'Unknown task type: {task_type}'}
    
    def get_report(self) -> Dict[str, Any]:
        """Generate comprehensive memory report"""
        current = self.take_snapshot()
        
        # Calculate trends if we have history
        trends = {}
        if len(self.snapshots) > 10:
            old = self.snapshots[-10]
            trends = {
                'memory_change_mb': current.process_mb - old.process_mb,
                'percent_change': current.percent_used - old.percent_used
            }
        
        return {
            'current': asdict(current),
            'trends': trends,
            'caches': {
                'result': self.result_cache.get_stats(),
                'reflection': self.reflection_cache.get_stats(),
                'plan': self.plan_cache.get_stats()
            },
            'memory_leaks': self.memory_leaks,
            'recommendations': self._get_recommendations()
        }


def main():
    """Test and demonstrate memory manager"""
    print("=" * 60)
    print("MEMORY RESOURCE MANAGER")
    print("=" * 60)
    
    # Initialize manager
    manager = MemoryManager()
    
    print("\n1. Taking initial snapshot...")
    initial = manager.take_snapshot()
    print(f"  Process Memory: {initial.process_mb:.2f} MB")
    print(f"  System Memory: {initial.percent_used:.1f}% used")
    
    print("\n2. Simulating memory usage...")
    # Simulate some memory usage
    data = []
    for i in range(100):
        # Create some data
        chunk = list(range(10000))
        data.append(chunk)
        
        # Cache some results
        manager.result_cache.put(f"result_{i}", chunk)
    
    print("\n3. Monitoring memory...")
    status = manager.monitor()
    print(f"  Status: {status['status']}")
    print(f"  Memory Used: {status['memory_used_percent']:.1f}%")
    print(f"  Process: {status['process_mb']:.2f} MB")
    print(f"  Cache: {status['cache_mb']:.2f} MB")
    
    if status['actions_taken']:
        print("  Actions taken:")
        for action in status['actions_taken']:
            print(f"    - {action}")
    
    print("\n4. Optimizing for planning task...")
    optimization = manager.optimize_for_task('planning')
    print(f"  Cache limits adjusted: {optimization}")
    
    print("\n5. Generating report...")
    report = manager.get_report()
    
    print("\n  Cache Statistics:")
    for cache_name, stats in report['caches'].items():
        print(f"    {cache_name}: {stats['hits']} hits, {stats['misses']} misses, "
              f"{stats['hit_rate']:.1%} hit rate")
    
    if report['recommendations']:
        print("\n  Recommendations:")
        for rec in report['recommendations']:
            print(f"    - {rec}")
    
    print("\n" + "=" * 60)
    print("Memory manager initialized and monitoring!")
    print("=" * 60)


if __name__ == "__main__":
    main()