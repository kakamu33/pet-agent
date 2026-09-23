from uuid import UUID

from app.agents.contracts import AgentReply, CompanionAgent
from app.api.schemas import ContextSnapshot


class RuleBasedCompanionAgent(CompanionAgent):
    """Safe local fallback until an LLM provider is configured.

    A provider-backed implementation will receive the same ContextSnapshot contract.
    """

    async def reply(
        self,
        *,
        user_id: UUID,
        user_message: str,
        context: ContextSnapshot,
    ) -> AgentReply:
        del user_id
        normalized = user_message.strip()
        if "太难" in normalized or "不会" in normalized:
            return AgentReply(
                content="没关系，我们把今天的任务拆成更小的一步。我会从一个例子开始陪你。",
                pet_mood="encouraging",
                memory_candidates=[],
            )
        if "完成" in normalized:
            return AgentReply(
                content="太棒了，完成一小步也是实打实的进步。要不要用一分钟记下今天最有收获的点？",
                pet_mood="celebrating",
                memory_candidates=[],
            )
        return AgentReply(
            content=f"我记住你刚刚说的“{normalized}”。我们可以先从今天最小的一步开始。",
            pet_mood="encouraging",
            memory_candidates=[],
        )

