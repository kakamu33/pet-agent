from dataclasses import dataclass
from typing import Protocol
from uuid import UUID

from app.api.schemas import ContextSnapshot, MemoryCandidate


@dataclass(frozen=True)
class AgentReply:
    content: str
    pet_mood: str
    memory_candidates: list[MemoryCandidate]


class CompanionAgent(Protocol):
    async def reply(
        self,
        *,
        user_id: UUID,
        user_message: str,
        context: ContextSnapshot,
    ) -> AgentReply:
        """Reply using only the supplied, privacy-scoped context."""

