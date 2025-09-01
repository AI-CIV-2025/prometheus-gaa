#!/usr/bin/env python3
"""
State Serializer for GAA System
Saves and restores complete agent state for seamless migration
Part of Wake #11 efficiency improvements
"""

import json
import pickle
import sqlite3
import hashlib
import zlib
import base64
from datetime import datetime
from typing import Dict, Any, Optional, List
from dataclasses import dataclass, asdict
import os
import shutil


@dataclass
class AgentState:
    """Complete agent state snapshot"""
    loop_number: int
    timestamp: str
    mission: str
    reflections: List[str]
    memories: List[Dict]
    plans: List[Dict]
    execution_history: List[Dict]
    current_context: str
    api_usage: Dict[str, int]
    checksum: str


class StateSerializer:
    """Serialize and deserialize complete agent state"""
    
    def __init__(self, db_path: str = "./data/gaa.db",
                 checkpoint_dir: str = "./data/checkpoints"):
        self.db_path = db_path
        self.checkpoint_dir = checkpoint_dir
        os.makedirs(checkpoint_dir, exist_ok=True)
    
    def capture_state(self) -> AgentState:
        """Capture current agent state from database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Get current mission
        cursor.execute("SELECT mission_text FROM missions WHERE is_core = 1 LIMIT 1")
        mission = cursor.fetchone()[0] if cursor.fetchone() else ""
        
        # Get reflections
        cursor.execute("SELECT content FROM reflections ORDER BY created_at DESC LIMIT 100")
        reflections = [r[0] for r in cursor.fetchall()]
        
        # Get memories
        cursor.execute("SELECT content, importance FROM memories ORDER BY created_at DESC LIMIT 100")
        memories = [{"content": m[0], "importance": m[1]} for m in cursor.fetchall()]
        
        # Get loop number (simplified - would need actual tracking)
        loop_number = len(reflections)
        
        # Create state object
        state = AgentState(
            loop_number=loop_number,
            timestamp=datetime.now().isoformat(),
            mission=mission,
            reflections=reflections,
            memories=memories,
            plans=[],  # Would extract from plan history
            execution_history=[],  # Would extract from execution logs
            current_context="",
            api_usage={"total_calls": loop_number * 30},  # Estimate
            checksum=""
        )
        
        # Calculate checksum
        state_bytes = json.dumps(asdict(state), sort_keys=True).encode()
        state.checksum = hashlib.sha256(state_bytes).hexdigest()
        
        conn.close()
        return state
    
    def save_checkpoint(self, state: Optional[AgentState] = None,
                       compress: bool = True) -> str:
        """Save state checkpoint to disk"""
        if state is None:
            state = self.capture_state()
        
        # Create checkpoint filename
        checkpoint_name = f"checkpoint_loop_{state.loop_number}_{state.timestamp.replace(':', '-')}"
        checkpoint_path = os.path.join(self.checkpoint_dir, checkpoint_name)
        
        # Serialize state
        state_dict = asdict(state)
        state_json = json.dumps(state_dict, indent=2)
        
        if compress:
            # Compress the state
            compressed = zlib.compress(state_json.encode())
            checkpoint_path += ".gz"
            with open(checkpoint_path, 'wb') as f:
                f.write(compressed)
        else:
            checkpoint_path += ".json"
            with open(checkpoint_path, 'w') as f:
                f.write(state_json)
        
        print(f"Checkpoint saved: {checkpoint_path}")
        print(f"  Size: {os.path.getsize(checkpoint_path) / 1024:.2f} KB")
        print(f"  Checksum: {state.checksum}")
        
        return checkpoint_path
    
    def load_checkpoint(self, checkpoint_path: str) -> AgentState:
        """Load state from checkpoint"""
        if checkpoint_path.endswith('.gz'):
            with open(checkpoint_path, 'rb') as f:
                compressed = f.read()
                state_json = zlib.decompress(compressed).decode()
        else:
            with open(checkpoint_path, 'r') as f:
                state_json = f.read()
        
        state_dict = json.loads(state_json)
        state = AgentState(**state_dict)
        
        # Verify checksum
        state_copy = AgentState(**state_dict)
        state_copy.checksum = ""
        state_bytes = json.dumps(asdict(state_copy), sort_keys=True).encode()
        calculated_checksum = hashlib.sha256(state_bytes).hexdigest()
        
        if calculated_checksum != state.checksum:
            raise ValueError("Checkpoint integrity check failed!")
        
        print(f"Checkpoint loaded: {checkpoint_path}")
        print(f"  Loop: {state.loop_number}")
        print(f"  Timestamp: {state.timestamp}")
        
        return state
    
    def restore_state(self, state: AgentState) -> bool:
        """Restore agent state to database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            # Restore mission
            cursor.execute("UPDATE missions SET mission_text = ? WHERE is_core = 1",
                          (state.mission,))
            
            # Clear and restore reflections
            cursor.execute("DELETE FROM reflections")
            for reflection in state.reflections:
                cursor.execute("INSERT INTO reflections (content) VALUES (?)",
                              (reflection,))
            
            # Clear and restore memories
            cursor.execute("DELETE FROM memories")
            for memory in state.memories:
                cursor.execute("INSERT INTO memories (content, importance) VALUES (?, ?)",
                              (memory['content'], memory['importance']))
            
            conn.commit()
            print("State restored successfully")
            return True
            
        except Exception as e:
            conn.rollback()
            print(f"State restoration failed: {e}")
            return False
        finally:
            conn.close()
    
    def list_checkpoints(self) -> List[Dict[str, Any]]:
        """List all available checkpoints"""
        checkpoints = []
        
        for file in os.listdir(self.checkpoint_dir):
            if file.startswith('checkpoint_'):
                path = os.path.join(self.checkpoint_dir, file)
                size = os.path.getsize(path) / 1024  # KB
                modified = datetime.fromtimestamp(os.path.getmtime(path))
                
                # Extract loop number from filename
                try:
                    loop_num = int(file.split('_')[2])
                except:
                    loop_num = 0
                
                checkpoints.append({
                    'filename': file,
                    'path': path,
                    'size_kb': size,
                    'modified': modified.isoformat(),
                    'loop_number': loop_num
                })
        
        # Sort by loop number
        checkpoints.sort(key=lambda x: x['loop_number'], reverse=True)
        return checkpoints
    
    def create_migration_bundle(self, output_path: str = "./data/migration_bundle.tar.gz"):
        """Create complete migration bundle with state and code"""
        import tarfile
        
        # Save current state
        state = self.capture_state()
        checkpoint = self.save_checkpoint(state)
        
        # Create tar bundle
        with tarfile.open(output_path, 'w:gz') as tar:
            # Add checkpoint
            tar.add(checkpoint, arcname=os.path.basename(checkpoint))
            
            # Add database
            tar.add(self.db_path, arcname="gaa.db")
            
            # Add source code
            tar.add("./src", arcname="src")
            
            # Add data files
            tar.add("./data", arcname="data", 
                   filter=lambda x: x if 'checkpoints' not in x.name else None)
            
            # Add configuration
            if os.path.exists("./exec_policy.json"):
                tar.add("./exec_policy.json", arcname="exec_policy.json")
        
        print(f"Migration bundle created: {output_path}")
        print(f"  Size: {os.path.getsize(output_path) / (1024*1024):.2f} MB")
        return output_path


def main():
    """Demo state serialization"""
    print("=" * 60)
    print("STATE SERIALIZER - Wake #11 Improvement")
    print("=" * 60)
    
    serializer = StateSerializer()
    
    print("\n1. Capturing current state...")
    state = serializer.capture_state()
    print(f"  Loop: {state.loop_number}")
    print(f"  Reflections: {len(state.reflections)}")
    print(f"  Memories: {len(state.memories)}")
    print(f"  Checksum: {state.checksum[:16]}...")
    
    print("\n2. Saving checkpoint...")
    checkpoint = serializer.save_checkpoint(state)
    
    print("\n3. Listing all checkpoints...")
    checkpoints = serializer.list_checkpoints()
    for cp in checkpoints[:5]:  # Show latest 5
        print(f"  {cp['filename']} - Loop {cp['loop_number']} ({cp['size_kb']:.2f} KB)")
    
    print("\n4. Creating migration bundle...")
    bundle = serializer.create_migration_bundle()
    
    print("\n" + "=" * 60)
    print("State serialization complete!")
    print("Ready for seamless migration to new environment")
    print("=" * 60)


if __name__ == "__main__":
    main()