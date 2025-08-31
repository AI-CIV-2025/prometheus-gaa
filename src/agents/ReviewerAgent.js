import ModelManager from '../ModelManager.js';

class ReviewerAgent {
    async reviewPlan(plan) {
        console.log("🧐 Reviewer Agent: Reviewing plan...");
        try {
            const context = JSON.stringify(plan, null, 2);
            const review = await ModelManager.callAPI('REVIEWER', context);
            console.log("✅ Reviewer Agent: Review complete.");
            return review;
        } catch (e) {
            console.error("❌ Reviewer Agent: Failed to review plan.", e);
            return { approved_steps: [], rejected: plan.steps, summary_md: "Failed to review the plan." };
        }
    }
}

export default new ReviewerAgent();
