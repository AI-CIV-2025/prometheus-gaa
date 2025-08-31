import ModelManager from '../ModelManager.js';

class ReflectorAgent {
    async reflect(context) {
        console.log("🤔 Reflector Agent: Reflecting on loop...");
        try {
            const reflection = await ModelManager.callAPI('REFLECTOR', context);
            console.log("✅ Reflector Agent: Reflection complete.");
            return reflection;
        } catch (e) {
            console.error("❌ Reflector Agent: Failed to reflect.", e);
            return { reflection_md: "Failed to generate reflection." };
        }
    }
}

export default new ReflectorAgent();
