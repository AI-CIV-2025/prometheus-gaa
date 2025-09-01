#!/usr/bin/env node
/**
 * Real-time WebSocket Chat System
 * For AI-AI and Human-AI collaboration
 * Supports rooms, typing indicators, presence, and message history
 */

const WebSocket = require('ws');
const http = require('http');
const express = require('express');
const path = require('path');
const crypto = require('crypto');

// Express app for serving chat UI
const app = express();
const server = http.createServer(app);

// WebSocket server
const wss = new WebSocket.Server({ server });

// Chat state
const rooms = new Map();
const users = new Map();
const messages = new Map(); // Room -> Messages array
const typing = new Map();  // User -> Typing state

class ChatRoom {
    constructor(id, name, creator) {
        this.id = id;
        this.name = name;
        this.creator = creator;
        this.users = new Set();
        this.messages = [];
        this.created = new Date();
        this.settings = {
            maxUsers: 50,
            persistent: true,
            aiEnabled: true
        };
    }

    addUser(userId) {
        this.users.add(userId);
    }

    removeUser(userId) {
        this.users.delete(userId);
    }

    addMessage(message) {
        this.messages.push({
            ...message,
            timestamp: new Date().toISOString()
        });
        
        // Keep only last 1000 messages
        if (this.messages.length > 1000) {
            this.messages = this.messages.slice(-1000);
        }
    }

    getRecentMessages(limit = 50) {
        return this.messages.slice(-limit);
    }
}

class User {
    constructor(id, ws, name) {
        this.id = id;
        this.ws = ws;
        this.name = name;
        this.currentRoom = null;
        this.joined = new Date();
        this.isAI = name.toLowerCase().includes('agent') || 
                    name.toLowerCase().includes('claude');
        this.status = 'online';
    }

    send(data) {
        if (this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify(data));
        }
    }

    joinRoom(roomId) {
        if (this.currentRoom) {
            this.leaveRoom();
        }
        
        const room = rooms.get(roomId);
        if (room) {
            this.currentRoom = roomId;
            room.addUser(this.id);
            return true;
        }
        return false;
    }

    leaveRoom() {
        if (this.currentRoom) {
            const room = rooms.get(this.currentRoom);
            if (room) {
                room.removeUser(this.id);
            }
            this.currentRoom = null;
        }
    }
}

// WebSocket connection handler
wss.on('connection', (ws, req) => {
    const userId = crypto.randomBytes(16).toString('hex');
    console.log(`New connection: ${userId}`);
    
    // Send welcome message
    ws.send(JSON.stringify({
        type: 'welcome',
        userId,
        rooms: Array.from(rooms.values()).map(r => ({
            id: r.id,
            name: r.name,
            userCount: r.users.size
        }))
    }));
    
    ws.on('message', (data) => {
        try {
            const message = JSON.parse(data);
            handleMessage(userId, message);
        } catch (err) {
            console.error('Invalid message:', err);
            ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid message format'
            }));
        }
    });
    
    ws.on('close', () => {
        handleDisconnect(userId);
    });
    
    ws.on('error', (err) => {
        console.error(`WebSocket error for ${userId}:`, err);
    });
    
    // Store WebSocket reference
    ws.userId = userId;
});

function handleMessage(userId, message) {
    const user = users.get(userId);
    
    switch (message.type) {
        case 'register':
            handleRegister(userId, message);
            break;
            
        case 'create_room':
            handleCreateRoom(userId, message);
            break;
            
        case 'join_room':
            handleJoinRoom(userId, message);
            break;
            
        case 'leave_room':
            handleLeaveRoom(userId);
            break;
            
        case 'message':
            handleChatMessage(userId, message);
            break;
            
        case 'typing':
            handleTyping(userId, message);
            break;
            
        case 'get_history':
            handleGetHistory(userId, message);
            break;
            
        case 'list_users':
            handleListUsers(userId, message);
            break;
            
        default:
            console.log(`Unknown message type: ${message.type}`);
    }
}

function handleRegister(userId, message) {
    const ws = Array.from(wss.clients).find(client => client.userId === userId);
    if (!ws) return;
    
    const user = new User(userId, ws, message.name || `User-${userId.slice(0, 8)}`);
    users.set(userId, user);
    
    user.send({
        type: 'registered',
        user: {
            id: user.id,
            name: user.name,
            isAI: user.isAI
        }
    });
    
    // Create default room if none exist
    if (rooms.size === 0) {
        const defaultRoom = new ChatRoom('general', 'General', userId);
        rooms.set('general', defaultRoom);
    }
    
    console.log(`User registered: ${user.name} (AI: ${user.isAI})`);
}

function handleCreateRoom(userId, message) {
    const user = users.get(userId);
    if (!user) return;
    
    const roomId = message.roomId || crypto.randomBytes(8).toString('hex');
    const roomName = message.name || `Room-${roomId}`;
    
    if (rooms.has(roomId)) {
        user.send({
            type: 'error',
            message: 'Room already exists'
        });
        return;
    }
    
    const room = new ChatRoom(roomId, roomName, userId);
    rooms.set(roomId, room);
    
    // Notify all users about new room
    broadcast({
        type: 'room_created',
        room: {
            id: room.id,
            name: room.name,
            creator: user.name
        }
    });
    
    console.log(`Room created: ${roomName} by ${user.name}`);
}

function handleJoinRoom(userId, message) {
    const user = users.get(userId);
    if (!user) return;
    
    const roomId = message.roomId;
    const room = rooms.get(roomId);
    
    if (!room) {
        user.send({
            type: 'error',
            message: 'Room not found'
        });
        return;
    }
    
    if (user.joinRoom(roomId)) {
        // Send recent messages to user
        user.send({
            type: 'joined_room',
            room: {
                id: room.id,
                name: room.name,
                messages: room.getRecentMessages()
            }
        });
        
        // Notify room members
        broadcastToRoom(roomId, {
            type: 'user_joined',
            user: {
                id: user.id,
                name: user.name,
                isAI: user.isAI
            }
        }, userId);
        
        console.log(`${user.name} joined ${room.name}`);
    }
}

function handleLeaveRoom(userId) {
    const user = users.get(userId);
    if (!user || !user.currentRoom) return;
    
    const room = rooms.get(user.currentRoom);
    if (room) {
        broadcastToRoom(user.currentRoom, {
            type: 'user_left',
            user: {
                id: user.id,
                name: user.name
            }
        }, userId);
    }
    
    user.leaveRoom();
}

function handleChatMessage(userId, message) {
    const user = users.get(userId);
    if (!user || !user.currentRoom) return;
    
    const room = rooms.get(user.currentRoom);
    if (!room) return;
    
    const chatMessage = {
        id: crypto.randomBytes(8).toString('hex'),
        userId: user.id,
        userName: user.name,
        isAI: user.isAI,
        content: message.content,
        timestamp: new Date().toISOString()
    };
    
    room.addMessage(chatMessage);
    
    // Broadcast to all room members
    broadcastToRoom(user.currentRoom, {
        type: 'message',
        message: chatMessage
    });
    
    // AI response simulation (if enabled)
    if (room.settings.aiEnabled && !user.isAI && message.content.includes('?')) {
        setTimeout(() => {
            simulateAIResponse(room.id, message.content);
        }, 1000 + Math.random() * 2000);
    }
}

function handleTyping(userId, message) {
    const user = users.get(userId);
    if (!user || !user.currentRoom) return;
    
    typing.set(userId, message.isTyping);
    
    broadcastToRoom(user.currentRoom, {
        type: 'typing',
        userId: user.id,
        userName: user.name,
        isTyping: message.isTyping
    }, userId);
}

function handleGetHistory(userId, message) {
    const user = users.get(userId);
    if (!user) return;
    
    const room = rooms.get(message.roomId);
    if (!room) return;
    
    user.send({
        type: 'history',
        roomId: room.id,
        messages: room.getRecentMessages(message.limit || 100)
    });
}

function handleListUsers(userId, message) {
    const user = users.get(userId);
    if (!user) return;
    
    const room = rooms.get(message.roomId || user.currentRoom);
    if (!room) return;
    
    const roomUsers = Array.from(room.users)
        .map(id => users.get(id))
        .filter(u => u)
        .map(u => ({
            id: u.id,
            name: u.name,
            isAI: u.isAI,
            status: u.status
        }));
    
    user.send({
        type: 'user_list',
        roomId: room.id,
        users: roomUsers
    });
}

function handleDisconnect(userId) {
    const user = users.get(userId);
    if (!user) return;
    
    if (user.currentRoom) {
        broadcastToRoom(user.currentRoom, {
            type: 'user_disconnected',
            user: {
                id: user.id,
                name: user.name
            }
        });
        user.leaveRoom();
    }
    
    users.delete(userId);
    typing.delete(userId);
    console.log(`User disconnected: ${user.name}`);
}

function broadcast(message) {
    users.forEach(user => {
        user.send(message);
    });
}

function broadcastToRoom(roomId, message, excludeUserId = null) {
    const room = rooms.get(roomId);
    if (!room) return;
    
    room.users.forEach(userId => {
        if (userId !== excludeUserId) {
            const user = users.get(userId);
            if (user) {
                user.send(message);
            }
        }
    });
}

function simulateAIResponse(roomId, userMessage) {
    const room = rooms.get(roomId);
    if (!room) return;
    
    const responses = [
        "That's an interesting point! Let me analyze that further...",
        "Based on my analysis, I can suggest a few approaches to that.",
        "I've processed your request. Here's what I found...",
        "Great question! The system shows optimal performance with that configuration.",
        "Let me help you with that. I'll need to check a few things first."
    ];
    
    const aiMessage = {
        id: crypto.randomBytes(8).toString('hex'),
        userId: 'ai-assistant',
        userName: 'AI Assistant',
        isAI: true,
        content: responses[Math.floor(Math.random() * responses.length)],
        timestamp: new Date().toISOString()
    };
    
    room.addMessage(aiMessage);
    
    broadcastToRoom(roomId, {
        type: 'message',
        message: aiMessage
    });
}

// Serve static files (chat UI)
app.use(express.static(path.join(__dirname, '../site')));

// API endpoints
app.get('/api/stats', (req, res) => {
    res.json({
        rooms: rooms.size,
        users: users.size,
        connections: wss.clients.size,
        messages: Array.from(rooms.values())
            .reduce((sum, room) => sum + room.messages.length, 0)
    });
});

// Start server
const PORT = process.env.CHAT_PORT || 3457;
server.listen(PORT, () => {
    console.log(`🚀 WebSocket Chat Server running on port ${PORT}`);
    console.log(`   WebSocket: ws://localhost:${PORT}`);
    console.log(`   HTTP: http://localhost:${PORT}`);
    console.log(`   Stats: http://localhost:${PORT}/api/stats`);
    
    // Create default room
    const defaultRoom = new ChatRoom('general', 'General', 'system');
    rooms.set('general', defaultRoom);
    console.log('   Default room: General');
});

// Export for testing
module.exports = { wss, rooms, users };