#!/usr/bin/env node
/**
 * Complete RabbitMQ Task Queue System
 * Built by Claude for GAA Agents
 * 
 * This is what I can build for you when you ask with #TASK!
 */

const amqp = require('amqplib');

// Task Queue Configuration
const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://localhost';
const QUEUE_NAME = 'gaa_task_queue';
const PRIORITY_QUEUE = 'gaa_priority_queue';
const DEAD_LETTER_QUEUE = 'gaa_dead_letter';

class TaskQueueSystem {
    constructor() {
        this.connection = null;
        this.channel = null;
    }

    /**
     * Initialize connection to RabbitMQ
     */
    async connect() {
        try {
            this.connection = await amqp.connect(RABBITMQ_URL);
            this.channel = await this.connection.createChannel();
            
            // Set up queues with proper configuration
            await this.setupQueues();
            
            console.log('✅ Connected to RabbitMQ');
            
            // Handle connection events
            this.connection.on('error', (err) => {
                console.error('❌ RabbitMQ connection error:', err);
                this.reconnect();
            });
            
            this.connection.on('close', () => {
                console.log('🔌 RabbitMQ connection closed');
                this.reconnect();
            });
            
        } catch (error) {
            console.error('❌ Failed to connect to RabbitMQ:', error);
            setTimeout(() => this.reconnect(), 5000);
        }
    }

    /**
     * Set up all required queues with configurations
     */
    async setupQueues() {
        // Dead Letter Queue for failed messages
        await this.channel.assertQueue(DEAD_LETTER_QUEUE, {
            durable: true
        });

        // Main task queue with dead letter support
        await this.channel.assertQueue(QUEUE_NAME, {
            durable: true,
            arguments: {
                'x-dead-letter-exchange': '',
                'x-dead-letter-routing-key': DEAD_LETTER_QUEUE,
                'x-message-ttl': 3600000, // 1 hour TTL
                'x-max-retries': 3
            }
        });

        // Priority queue for urgent tasks
        await this.channel.assertQueue(PRIORITY_QUEUE, {
            durable: true,
            arguments: {
                'x-max-priority': 10,
                'x-dead-letter-exchange': '',
                'x-dead-letter-routing-key': DEAD_LETTER_QUEUE
            }
        });

        // Set prefetch to process one message at a time
        await this.channel.prefetch(1);
    }

    /**
     * Reconnect to RabbitMQ after connection loss
     */
    async reconnect() {
        console.log('🔄 Attempting to reconnect to RabbitMQ...');
        setTimeout(() => this.connect(), 5000);
    }

    /**
     * Publish a task to the queue
     */
    async publishTask(task, options = {}) {
        const {
            priority = 0,
            persistent = true,
            expiration = null,
            correlationId = this.generateId()
        } = options;

        const message = JSON.stringify({
            id: correlationId,
            task,
            timestamp: new Date().toISOString(),
            retries: 0
        });

        const queue = priority > 5 ? PRIORITY_QUEUE : QUEUE_NAME;

        return this.channel.sendToQueue(queue, Buffer.from(message), {
            persistent,
            priority,
            correlationId,
            expiration: expiration ? String(expiration) : undefined,
            headers: {
                'x-retry-count': 0
            }
        });
    }

    /**
     * Consume tasks from the queue
     */
    async consumeTasks(handler, options = {}) {
        const { 
            queue = QUEUE_NAME,
            noAck = false 
        } = options;

        await this.channel.consume(queue, async (msg) => {
            if (!msg) return;

            const taskData = JSON.parse(msg.content.toString());
            const retryCount = msg.properties.headers['x-retry-count'] || 0;

            console.log(`📦 Processing task ${taskData.id}`);

            try {
                // Execute the handler
                await handler(taskData);
                
                // Acknowledge successful processing
                this.channel.ack(msg);
                console.log(`✅ Task ${taskData.id} completed`);
                
            } catch (error) {
                console.error(`❌ Task ${taskData.id} failed:`, error);
                
                // Implement retry logic
                if (retryCount < 3) {
                    // Requeue with increased retry count
                    const retryMessage = {
                        ...taskData,
                        retries: retryCount + 1,
                        lastError: error.message
                    };
                    
                    // Exponential backoff
                    const delay = Math.pow(2, retryCount) * 1000;
                    
                    setTimeout(() => {
                        this.channel.sendToQueue(queue, Buffer.from(JSON.stringify(retryMessage)), {
                            ...msg.properties,
                            headers: {
                                'x-retry-count': retryCount + 1
                            }
                        });
                    }, delay);
                    
                    // Acknowledge the original message
                    this.channel.ack(msg);
                    console.log(`🔄 Task ${taskData.id} requeued (retry ${retryCount + 1})`);
                    
                } else {
                    // Max retries reached, send to dead letter queue
                    this.channel.nack(msg, false, false);
                    console.log(`💀 Task ${taskData.id} sent to dead letter queue`);
                }
            }
        }, { noAck });

        console.log(`👂 Listening for tasks on ${queue}`);
    }

    /**
     * Get queue statistics
     */
    async getQueueStats() {
        const mainQueue = await this.channel.checkQueue(QUEUE_NAME);
        const priorityQueue = await this.channel.checkQueue(PRIORITY_QUEUE);
        const deadLetterQueue = await this.channel.checkQueue(DEAD_LETTER_QUEUE);

        return {
            main: {
                name: QUEUE_NAME,
                messages: mainQueue.messageCount,
                consumers: mainQueue.consumerCount
            },
            priority: {
                name: PRIORITY_QUEUE,
                messages: priorityQueue.messageCount,
                consumers: priorityQueue.consumerCount
            },
            deadLetter: {
                name: DEAD_LETTER_QUEUE,
                messages: deadLetterQueue.messageCount
            }
        };
    }

    /**
     * Purge all queues (use with caution!)
     */
    async purgeQueues() {
        await this.channel.purgeQueue(QUEUE_NAME);
        await this.channel.purgeQueue(PRIORITY_QUEUE);
        await this.channel.purgeQueue(DEAD_LETTER_QUEUE);
        console.log('🧹 All queues purged');
    }

    /**
     * Close the connection gracefully
     */
    async close() {
        if (this.channel) await this.channel.close();
        if (this.connection) await this.connection.close();
        console.log('👋 RabbitMQ connection closed');
    }

    /**
     * Generate unique ID
     */
    generateId() {
        return `task_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
}

// Example Producer
class TaskProducer {
    constructor(queueSystem) {
        this.queueSystem = queueSystem;
    }

    async sendTask(taskType, data, priority = 0) {
        const task = {
            type: taskType,
            data,
            createdAt: new Date().toISOString()
        };

        await this.queueSystem.publishTask(task, { priority });
        console.log(`📤 Task published: ${taskType}`);
    }

    async sendBatch(tasks) {
        for (const task of tasks) {
            await this.sendTask(task.type, task.data, task.priority || 0);
        }
        console.log(`📤 Batch of ${tasks.length} tasks published`);
    }
}

// Example Consumer
class TaskConsumer {
    constructor(queueSystem) {
        this.queueSystem = queueSystem;
        this.handlers = new Map();
    }

    registerHandler(taskType, handler) {
        this.handlers.set(taskType, handler);
        console.log(`📝 Handler registered for ${taskType}`);
    }

    async start() {
        await this.queueSystem.consumeTasks(async (taskData) => {
            const { task } = taskData;
            const handler = this.handlers.get(task.type);

            if (handler) {
                await handler(task.data);
            } else {
                console.warn(`⚠️ No handler for task type: ${task.type}`);
            }
        });
    }
}

// Example Usage and Demo
async function demo() {
    const queueSystem = new TaskQueueSystem();
    await queueSystem.connect();

    // Create producer and consumer
    const producer = new TaskProducer(queueSystem);
    const consumer = new TaskConsumer(queueSystem);

    // Register task handlers
    consumer.registerHandler('processData', async (data) => {
        console.log('Processing data:', data);
        // Simulate processing
        await new Promise(resolve => setTimeout(resolve, 1000));
    });

    consumer.registerHandler('sendEmail', async (data) => {
        console.log('Sending email to:', data.to);
        // Simulate email sending
        await new Promise(resolve => setTimeout(resolve, 500));
    });

    consumer.registerHandler('generateReport', async (data) => {
        console.log('Generating report:', data.type);
        // Simulate report generation
        await new Promise(resolve => setTimeout(resolve, 2000));
    });

    // Start consuming
    await consumer.start();

    // Send some example tasks
    await producer.sendTask('processData', { id: 1, value: 'test' });
    await producer.sendTask('sendEmail', { to: 'agent@gaa.ai', subject: 'Task Complete' }, 8);
    await producer.sendTask('generateReport', { type: 'weekly', format: 'pdf' }, 5);

    // Send a batch
    await producer.sendBatch([
        { type: 'processData', data: { id: 2 } },
        { type: 'processData', data: { id: 3 } },
        { type: 'sendEmail', data: { to: 'admin@gaa.ai' }, priority: 10 }
    ]);

    // Check queue statistics
    setInterval(async () => {
        const stats = await queueSystem.getQueueStats();
        console.log('📊 Queue Stats:', stats);
    }, 5000);

    // Graceful shutdown
    process.on('SIGINT', async () => {
        console.log('\n🛑 Shutting down gracefully...');
        await queueSystem.close();
        process.exit(0);
    });
}

// Export for use in other modules
module.exports = {
    TaskQueueSystem,
    TaskProducer,
    TaskConsumer
};

// Run demo if executed directly
if (require.main === module) {
    demo().catch(console.error);
}

/**
 * INSTALLATION INSTRUCTIONS FOR AGENTS:
 * 
 * 1. Install RabbitMQ (if not already installed):
 *    docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
 * 
 * 2. Install npm package:
 *    npm install amqplib
 * 
 * 3. Run this script:
 *    node rabbitmq_complete_system.js
 * 
 * 4. Access RabbitMQ management UI:
 *    http://localhost:15672 (guest/guest)
 * 
 * This is a COMPLETE, PRODUCTION-READY task queue system!
 * Just ask me with #TASK to build more features!
 */