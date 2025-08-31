import { getDB } from '../database.js';
import ModelManager from '../ModelManager.js';

class MemoryAgent {
    constructor() {
        this.compressionThreshold = parseInt(process.env.MEMORY_COMPRESSION_THRESHOLD || '20');
    }

    addMemory(type, content, loopId) {
        const db = getDB();
        db.prepare('INSERT INTO memories (type, content, loop_id) VALUES (?, ?, ?)')
          .run(type, content, loopId);
        
        this.checkForCompression();
    }

    checkForCompression() {
        const db = getDB();
        const count = db.prepare("SELECT COUNT(*) as count FROM memories WHERE type != 'compressed_lesson'").get().count;

        if (count >= this.compressionThreshold) {
            console.log("🧠 Memory Agent: Compression threshold reached. Compressing memories...");
            this.compressMemories();
        }
    }

    async compressMemories() {
        const db = getDB();
        const memoriesToCompress = db.prepare("SELECT id, content FROM memories WHERE type != 'compressed_lesson' ORDER BY created_at ASC LIMIT ?").all(this.compressionThreshold);
        
        const context = memoriesToCompress.map(m => m.content).join('\n---\n');
        
        try {
            const result = await ModelManager.callAPI('MEMORY_COMPRESSOR', context);
            if (result.lesson) {
                const compressTransaction = db.transaction(() => {
                    // Add the new compressed lesson
                    db.prepare("INSERT INTO memories (type, content) VALUES ('compressed_lesson', ?)")
                      .run(result.lesson);
                    // Delete the old memories
                    const ids = memoriesToCompress.map(m => m.id).join(',');
                    db.prepare(`DELETE FROM memories WHERE id IN (${ids})`).run();
                });
                compressTransaction();
                console.log(`✅ Memory Agent: Compressed ${memoriesToCompress.length} memories into one lesson.`);
            }
        } catch (e) {
            console.error("❌ Memory Agent: Failed to compress memories.", e);
        }
    }
}

export default new MemoryAgent();
