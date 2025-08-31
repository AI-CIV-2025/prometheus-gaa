#!/usr/bin/env python3

import redis
import argparse
import time
import os

class RedisClusterManager:
    def __init__(self, host='localhost', port=6379):
        self.host = host
        self.port = port
        self.redis_client = redis.Redis(host=self.host, port=self.port)
    
    def check_connection(self):
        try:
            self.redis_client.ping()
            print("Successfully connected to Redis server at {}:{}".format(self.host, self.port))
            return True
        except redis.exceptions.ConnectionError as e:
            print("Connection Error: {}".format(e))
            return False
    
    def get_server_info(self):
        try:
            info = self.redis_client.info()
            print("Redis Server Information:")
            for key, value in info.items():
                print("{}: {}".format(key, value))
            return info
        except Exception as e:
            print("Error retrieving server info: {}".format(e))
            return None
    
    def set_key_value(self, key, value):
        try:
            self.redis_client.set(key, value)
            print("Successfully set key '{}' to value '{}'".format(key, value))
            return True
        except Exception as e:
            print("Error setting key-value pair: {}".format(e))
            return False
    
    def get_key_value(self, key):
        try:
            value = self.redis_client.get(key)
            if value:
                print("Value for key '{}': {}".format(key, value.decode('utf-8')))
                return value.decode('utf-8')
            else:
                print("Key '{}' not found".format(key))
                return None
        except Exception as e:
            print("Error getting value for key '{}': {}".format(key, e))
            return None
    
    def delete_key(self, key):
        try:
            result = self.redis_client.delete(key)
            if result > 0:
                print("Successfully deleted key '{}'".format(key))
                return True
            else:
                print("Key '{}' not found".format(key))
                return False
        except Exception as e:
            print("Error deleting key '{}': {}".format(key, e))
            return False
    
    def list_keys(self, pattern='*'):
        try:
            keys = self.redis_client.keys(pattern=pattern)
            if keys:
                print("Keys matching pattern '{}':".format(pattern))
                for key in keys:
                    print(key.decode('utf-8'))
                return [key.decode('utf-8') for key in keys]
            else:
                print("No keys found matching pattern '{}'".format(pattern))
                return []
        except Exception as e:
            print("Error listing keys: {}".format(e))
            return None
    
    def flush_database(self):
        try:
            self.redis_client.flushdb()
            print("Successfully flushed the current database")
            return True
        except Exception as e:
            print("Error flushing the database: {}".format(e))
            return False
    
    def close_connection(self):
        try:
            self.redis_client.close()
            print("Connection to Redis server closed")
            return True
        except Exception as e:
            print("Error closing connection: {}".format(e))
            return False

def main():
    parser = argparse.ArgumentParser(description="Redis Cluster Manager")
    parser.add_argument('--host', default='localhost', help='Redis host')
    parser.add_argument('--port', type=int, default=6379, help='Redis port')
    parser.add_argument('--key', help='Key for set/get/delete operations')
    parser.add_argument('--value', help='Value for set operation')
    parser.add_argument('--list_pattern', default='*', help='Pattern for listing keys')
    parser.add_argument('--operation', choices=['check', 'info', 'set', 'get', 'delete', 'list', 'flush'], help='Operation to perform')

    args = parser.parse_args()

    manager = RedisClusterManager(host=args.host, port=args.port)

    if manager.check_connection():
        if args.operation == 'info':
            manager.get_server_info()
        elif args.operation == 'set':
            if args.key and args.value:
                manager.set_key_value(args.key, args.value)
            else:
                print("Key and value are required for set operation")
        elif args.operation == 'get':
            if args.key:
                manager.get_key_value(args.key)
            else:
                print("Key is required for get operation")
        elif args.operation == 'delete':
            if args.key:
                manager.delete_key(args.key)
            else:
                print("Key is required for delete operation")
        elif args.operation == 'list':
            manager.list_keys(args.list_pattern)
        elif args.operation == 'flush':
            manager.flush_database()
        
        manager.close_connection()

if __name__ == "__main__":
    main()
