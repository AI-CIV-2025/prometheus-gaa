import yaml from 'js-yaml';
import { PROMPTS } from './prompts.js';
import { getDB } from './database.js';

class ModelManager {
    constructor() {
        this.apiKey = process.env.GOOGLE_API_KEY;
        this.models = [
            // Primary models - highest quality, lowest quotas (RPD: requests per day)
            { name: process.env.MODEL_PRO || 'gemini-2.5-pro', priority: 1, rpm: 5, dailyQuota: 100, usedToday: 0 },
            { name: process.env.MODEL_FLASH || 'gemini-2.5-flash', priority: 2, rpm: 10, dailyQuota: 250, usedToday: 0 },
            // Fallback models - 2.5 Flash-Lite is BETTER than 2.0 Flash for coding!
            { name: 'gemini-2.5-flash-lite', priority: 3, rpm: 15, dailyQuota: 1000, usedToday: 0 }, // Better & 5X quota!
            { name: 'gemini-2.0-flash', priority: 4, rpm: 15, dailyQuota: 200, usedToday: 0 } // Backup only
        ];
        this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
        this.modelExhaustion = {}; // Track when each model was exhausted
        this.lastResetCheck = new Date();
        this.requestTimestamps = {}; // Track request times for RPM limiting
    }

    async sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    // Check if we've passed PST midnight for quota reset
    checkQuotaReset() {
        const now = new Date();
        // Convert to PST (UTC-8, ignoring DST for simplicity)
        const pstOffset = -8 * 60 * 60 * 1000;
        const pstNow = new Date(now.getTime() + pstOffset);
        const pstMidnight = new Date(pstNow);
        pstMidnight.setUTCHours(8, 0, 0, 0); // Midnight PST is 8:00 UTC
        
        // Check if we've crossed midnight PST since last check
        if (this.lastResetCheck < pstMidnight && now >= pstMidnight) {
            console.log('🌙 PST midnight passed - resetting all model quotas');
            // Reset all models
            this.models.forEach(model => {
                model.usedToday = 0;
                delete this.modelExhaustion[model.name];
            });
            this.lastResetCheck = now;
            
            // Clear database state
            try {
                const db = getDB();
                db.prepare("DELETE FROM system_state WHERE key LIKE 'model_quota_%'").run();
            } catch (e) {
                console.error('Error clearing quota state:', e);
            }
        }
    }

    // Check if model is within RPM limits
    isWithinRPM(modelName, rpm) {
        const now = Date.now();
        const oneMinuteAgo = now - 60000;
        
        if (!this.requestTimestamps[modelName]) {
            this.requestTimestamps[modelName] = [];
        }
        
        // Clean up old timestamps
        this.requestTimestamps[modelName] = this.requestTimestamps[modelName]
            .filter(ts => ts > oneMinuteAgo);
        
        // Check if we can make another request
        return this.requestTimestamps[modelName].length < rpm;
    }

    // Record a request timestamp
    recordRequest(modelName) {
        if (!this.requestTimestamps[modelName]) {
            this.requestTimestamps[modelName] = [];
        }
        this.requestTimestamps[modelName].push(Date.now());
    }

    // Get available models based on quota and RPM
    getAvailableModels() {
        this.checkQuotaReset();
        
        return this.models
            .filter(model => {
                // Check if model is exhausted
                if (this.modelExhaustion[model.name]) {
                    return false;
                }
                // Check if under daily quota
                if (model.usedToday >= model.dailyQuota) {
                    console.log(`📊 ${model.name}: Daily quota reached (${model.usedToday}/${model.dailyQuota})`);
                    return false;
                }
                // Check RPM limits
                if (!this.isWithinRPM(model.name, model.rpm)) {
                    console.log(`⏱️ ${model.name}: RPM limit reached (${model.rpm}/min), will retry soon`);
                    return false;
                }
                return true;
            })
            .sort((a, b) => a.priority - b.priority);
    }

    // Mark model usage
    markUsage(modelName, success = true) {
        const model = this.models.find(m => m.name === modelName);
        if (model && success) {
            model.usedToday++;
            console.log(`📊 ${modelName}: ${model.usedToday}/${model.dailyQuota} used today`);
            
            // Persist usage to database
            try {
                const db = getDB();
                db.prepare(`
                    INSERT OR REPLACE INTO system_state (key, value) 
                    VALUES (?, ?)
                `).run(`model_quota_${modelName}`, JSON.stringify({
                    usedToday: model.usedToday,
                    date: new Date().toISOString()
                }));
            } catch (e) {
                console.error('Error persisting usage:', e);
            }
        }
    }

    // Mark model as exhausted
    markExhausted(modelName) {
        this.modelExhaustion[modelName] = new Date();
        console.log(`❌ ${modelName} marked as exhausted for today`);
        
        // Persist exhaustion to database
        try {
            const db = getDB();
            db.prepare(`
                INSERT OR REPLACE INTO system_state (key, value) 
                VALUES (?, ?)
            `).run(`model_exhausted_${modelName}`, new Date().toISOString());
        } catch (e) {
            console.error('Error persisting exhaustion:', e);
        }
    }

    // Extract YAML from various formats with better error handling
    extractYAML(text) {
        // Priority 1: Find a YAML code block (most reliable)
        const yamlBlockMatch = text.match(/```(?:yaml|yml)\s*([\s\S]*?)\s*```/);
        if (yamlBlockMatch) {
            return this.fixCommonYAMLIssues(yamlBlockMatch[1].trim());
        }

        // Priority 2: Find any code block if it looks like YAML
        const genericBlockMatch = text.match(/```\s*([\s\S]*?)\s*```/);
        if (genericBlockMatch && (genericBlockMatch[1].includes(':') || genericBlockMatch[1].includes('{'))) {
            return this.fixCommonYAMLIssues(genericBlockMatch[1].trim());
        }
        
        // Priority 3: Try to extract clean YAML without code fence markers
        // Remove any leading/trailing backticks that aren't part of a proper fence
        const cleanedText = text.replace(/^`+|`+$/g, '').trim();
        
        // Priority 4: Look for YAML-like content (has colons and newlines)
        if (cleanedText.includes(':') && cleanedText.includes('\n')) {
            // Extract from first line that looks like YAML to end
            const lines = cleanedText.split('\n');
            let startIdx = -1;
            for (let i = 0; i < lines.length; i++) {
                if (lines[i].match(/^\w+:/)) {
                    startIdx = i;
                    break;
                }
            }
            if (startIdx >= 0) {
                return this.fixCommonYAMLIssues(lines.slice(startIdx).join('\n').trim());
            }
        }
        
        // Fallback: Return the cleaned text, hoping it's valid
        return this.fixCommonYAMLIssues(cleanedText);
    }
    
    // Fix common YAML parsing issues
    fixCommonYAMLIssues(yaml) {
        if (!yaml) return yaml;
        
        const lines = yaml.split('\n');
        const fixed = lines.map((line, idx) => {
            // Fix unclosed quotes
            const quotes = (line.match(/"/g) || []).length;
            if (quotes % 2 === 1 && !line.trim().endsWith('"')) {
                console.log(`Fixed unclosed quote on line ${idx + 1}`);
                return line + '"';
            }
            
            // Fix lines that end with colon but no value
            if (line.trim().endsWith(':') && idx < lines.length - 1) {
                const nextLine = lines[idx + 1];
                if (nextLine && !nextLine.startsWith(' ') && !nextLine.startsWith('-')) {
                    console.log(`Fixed missing value after colon on line ${idx + 1}`);
                    return line + ' ""';
                }
            }
            
            return line;
        }).join('\n');
        
        // Ensure required structure based on content
        if (fixed.includes('steps:') && !fixed.includes('spec_md:')) {
            console.log('Added missing spec_md field');
            return 'spec_md: |\n  Generated plan\n' + fixed;
        }
        
        return fixed;
    }

    async callAPI(promptKey, context) {
        const fullPrompt = `${PROMPTS[promptKey]}\n\n---\n\nCONTEXT:\n${context}`;
        
        // Load any persisted quota state on startup
        if (this.models[0].usedToday === 0) {
            try {
                const db = getDB();
                const states = db.prepare("SELECT key, value FROM system_state WHERE key LIKE 'model_%'").all();
                states.forEach(state => {
                    const key = state.key;
                    if (key.startsWith('model_quota_')) {
                        const modelName = key.replace('model_quota_', '');
                        const model = this.models.find(m => m.name === modelName);
                        if (model) {
                            const data = JSON.parse(state.value);
                            // Only restore if from today
                            const storedDate = new Date(data.date);
                            const today = new Date();
                            if (storedDate.toDateString() === today.toDateString()) {
                                model.usedToday = data.usedToday;
                            }
                        }
                    } else if (key.startsWith('model_exhausted_')) {
                        const modelName = key.replace('model_exhausted_', '');
                        const exhaustedTime = new Date(state.value);
                        const today = new Date();
                        if (exhaustedTime.toDateString() === today.toDateString()) {
                            this.modelExhaustion[modelName] = exhaustedTime;
                        }
                    }
                });
            } catch (e) {
                console.error('Error loading quota state:', e);
            }
        }
        
        // Get available models
        let availableModels = this.getAvailableModels();
        
        // If no models available due to RPM limits, wait a bit
        if (availableModels.length === 0) {
            // Check if it's just RPM limits or if we're truly exhausted
            const anyUnderDailyQuota = this.models.some(m => 
                !this.modelExhaustion[m.name] && m.usedToday < m.dailyQuota
            );
            
            if (anyUnderDailyQuota) {
                // Just RPM limited, wait 10 seconds and retry
                console.log('⏸️ All models at RPM limits, waiting 10s...');
                await this.sleep(10000);
                availableModels = this.getAvailableModels();
            }
            
            if (availableModels.length === 0) {
                throw new Error('All models exhausted for today! Wait until PST midnight for reset.');
            }
        }
        
        console.log(`🎯 Available models: ${availableModels.map(m => `${m.name} (${m.dailyQuota - m.usedToday} left)`).join(', ')}`);
        
        let lastError = null;

        for (const modelObj of availableModels) {
            const model = modelObj.name;
            console.log(`🚀 Attempting with model: ${model} (Priority ${modelObj.priority}, ${modelObj.dailyQuota - modelObj.usedToday}/${modelObj.dailyQuota} left today)`);
            
            // Record the request for RPM tracking
            this.recordRequest(model);
            
            // Fewer retries for lower priority models to move through them faster
            const maxAttempts = modelObj.priority <= 2 ? 3 : 2;
            
            for (let attempt = 1; attempt <= maxAttempts; attempt++) {
                try {
                    const url = `${this.baseUrl}/${model}:generateContent?key=${this.apiKey}`;
                    
                    const requestBody = {
                        contents: [{
                            parts: [{
                                text: fullPrompt
                            }]
                        }],
                        generationConfig: {
                            temperature: 0.7,
                            maxOutputTokens: 8192  // Maximum for better reasoning depth
                        }
                    };

                    const response = await fetch(url, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(requestBody)
                    });

                    if (!response.ok) {
                        const error = await response.text();
                        
                        // Handle quota exhaustion
                        if (response.status === 429) {
                            console.log(`🚫 ${model} quota exhausted`);
                            this.markExhausted(model);
                            break; // Try next model immediately
                        }
                        
                        // If it's a 503 (overloaded), retry with backoff
                        if (response.status === 503) {
                            const waitTime = Math.min(Math.pow(2, attempt) * 1000, 8000); // Cap at 8s
                            console.log(`⏳ ${model} overloaded (attempt ${attempt}/${maxAttempts}). Waiting ${waitTime/1000}s...`);
                            
                            if (attempt < maxAttempts) {
                                await this.sleep(waitTime);
                                continue; // Retry with same model
                            } else {
                                // After max attempts, try next model
                                lastError = `${model} overloaded after ${maxAttempts} attempts`;
                                break;
                            }
                        }
                        
                        throw new Error(`API request failed: ${response.status} - ${error}`);
                    }

                    const data = await response.json();
                    
                    // Extract text from response
                    const text = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
                    
                    // Debug log for troubleshooting
                    if (!text) {
                        console.log(`Empty response from ${model}`);
                        throw new Error(`Empty response from ${model}`);
                    }
                    
                    // Extract and parse YAML
                    try {
                        const yamlContent = this.extractYAML(text);
                        const parsed = yaml.load(yamlContent);
                        
                        if (parsed && typeof parsed === 'object') {
                            console.log(`✅ Success with model: ${model} (YAML parsed)`);
                            this.markUsage(model, true);
                            return parsed;
                        } else {
                            throw new Error('Parsed YAML is not an object');
                        }
                    } catch (yamlError) {
                        console.log(`YAML parse error with ${model}: ${yamlError.message}`);
                        
                        // If YAML fails, try JSON as fallback (for backward compatibility)
                        try {
                            const jsonMatch = text.match(/\{[\s\S]*\}/);
                            if (jsonMatch) {
                                const parsed = JSON.parse(jsonMatch[0]);
                                console.log(`✅ Success with model: ${model} (JSON fallback)`);
                                this.markUsage(model, true);
                                return parsed;
                            }
                        } catch (jsonError) {
                            // Log the raw response for debugging
                            console.log('Raw response (first 500 chars):', text.substring(0, 500));
                        }
                        
                        throw new Error(`Failed to parse response from ${model}`);
                    }
                    
                } catch (error) {
                    lastError = error;
                    
                    // If not a 503 or 429 error, try next model immediately
                    if (!error.message.includes('503') && 
                        !error.message.includes('429') && 
                        !error.message.includes('overloaded')) {
                        console.error(`API call to ${promptKey} with ${model} failed:`, error.message);
                        break; // Try next model
                    }
                }
            }
        }
        
        // If we get here, all available models failed
        const exhaustedCount = Object.keys(this.modelExhaustion).length;
        if (exhaustedCount === this.models.length) {
            console.error(`🔴 ALL MODELS EXHAUSTED! Wait until PST midnight for quota reset.`);
            throw new Error('All models exhausted for today. Quotas reset at PST midnight.');
        }
        
        console.error(`All available models failed for ${promptKey}. Last error:`, lastError?.message || lastError);
        throw lastError || new Error("All available models failed");
    }
}

export default new ModelManager();