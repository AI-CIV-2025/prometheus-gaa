import { getDB } from './database.js';
import EventEmitter from 'events';

class ActivityLogger extends EventEmitter {
    constructor() {
        super();
        this.db = null;
        this.buffer = [];
        this.flushInterval = null;
    }

    init() {
        this.db = getDB();
        // Flush buffer every 2 seconds to batch writes
        this.flushInterval = setInterval(() => this.flush(), 2000);
    }

    async log(loopId, agent, action, details = null, level = 'info') {
        const entry = {
            timestamp: new Date().toISOString(),
            loopId: loopId || null,
            agent: agent || 'system',
            action: action,
            details: typeof details === 'object' ? JSON.stringify(details) : details,
            level: level
        };

        // Add to buffer
        this.buffer.push(entry);
        
        // Emit for real-time listeners (SSE)
        this.emit('activity', entry);
        
        // Auto-flush if buffer gets large
        if (this.buffer.length > 50) {
            this.flush();
        }
        
        // Console log for debugging
        const levelEmoji = {
            'info': '📝',
            'success': '✅',
            'warning': '⚠️',
            'error': '❌',
            'debug': '🔍'
        };
        
        const emoji = levelEmoji[level] || '📝';
        console.log(`${emoji} [${agent}] ${action}${details ? ': ' + (typeof details === 'object' ? JSON.stringify(details) : details) : ''}`);
    }

    flush() {
        if (!this.db || this.buffer.length === 0) return;
        
        try {
            const stmt = this.db.prepare(`
                INSERT INTO activity_logs (timestamp, loop_id, agent, action, details, level)
                VALUES (?, ?, ?, ?, ?, ?)
            `);
            
            const insertMany = this.db.transaction((entries) => {
                for (const entry of entries) {
                    stmt.run(
                        entry.timestamp,
                        entry.loopId,
                        entry.agent,
                        entry.action,
                        entry.details,
                        entry.level
                    );
                }
            });
            
            insertMany(this.buffer);
            this.buffer = [];
        } catch (error) {
            console.error('Failed to flush activity logs:', error);
        }
    }

    // Get recent activities for dashboard
    getRecent(limit = 100) {
        if (!this.db) return [];
        
        try {
            return this.db.prepare(`
                SELECT * FROM activity_logs 
                ORDER BY timestamp DESC 
                LIMIT ?
            `).all(limit);
        } catch (error) {
            console.error('Failed to get recent activities:', error);
            return [];
        }
    }

    // Get activities for a specific loop
    getByLoop(loopId) {
        if (!this.db) return [];
        
        try {
            return this.db.prepare(`
                SELECT * FROM activity_logs 
                WHERE loop_id = ?
                ORDER BY timestamp ASC
            `).all(loopId);
        } catch (error) {
            console.error('Failed to get loop activities:', error);
            return [];
        }
    }

    // Cleanup
    close() {
        if (this.flushInterval) {
            clearInterval(this.flushInterval);
        }
        this.flush();
        this.removeAllListeners();
    }
}

// Singleton instance
const activityLogger = new ActivityLogger();

export default activityLogger;