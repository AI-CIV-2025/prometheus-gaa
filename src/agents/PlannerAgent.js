import ModelManager from '../ModelManager.js';
import activityLogger from '../ActivityLogger.js';

class PlannerAgent {
    async generatePlan(context, loopId = null) {
        console.log("🤔 Planner Agent: Generating plan...");
        activityLogger.log(loopId, 'PlannerAgent', 'Generating plan', null, 'info');
        try {
            const plan = await ModelManager.callAPI('PLANNER', context);
            console.log("✅ Planner Agent: Plan generated.");
            activityLogger.log(loopId, 'PlannerAgent', 'Plan generated', plan, 'info');
            return plan;
        } catch (e) {
            console.error("❌ Planner Agent: Failed to generate plan.", e);
            activityLogger.log(loopId, 'PlannerAgent', 'Plan generation failed', { error: e.message }, 'error');
            return { spec_md: "Failed to generate a plan.", steps: [] };
        }
    }
}

export default new PlannerAgent();
