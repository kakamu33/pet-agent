from datetime import datetime, timezone
from uuid import UUID

from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.schemas import ContextSnapshot, MemoryCandidate
from app.core.config import Settings
from app.domain.models import ChatMessage, Conversation, MessageRole, UserMemory


class MemoryService:
    """Builds bounded agent context and persists only deliberate long-term memories."""

    def __init__(self, session: AsyncSession, settings: Settings) -> None:
        self._session = session
        self._settings = settings

    async def create_conversation(self, user_id: UUID) -> Conversation:
        conversation = Conversation(user_id=user_id)
        self._session.add(conversation)
        await self._session.flush()
        return conversation

    async def append_message(
        self, conversation_id: UUID, role: MessageRole, content: str
    ) -> ChatMessage:
        message = ChatMessage(conversation_id=conversation_id, role=role.value, content=content)
        self._session.add(message)
        await self._session.flush()
        return message

    async def build_context(self, user_id: UUID, conversation_id: UUID) -> ContextSnapshot:
        recent_messages = await self._recent_messages(conversation_id)
        memories = await self._relevant_memories(user_id)
        return ContextSnapshot(
            user_id=user_id,
            profile_summary="新用户：尚未收集稳定的学习偏好。",
            active_goal_summary="当前尚未设置学习目标。",
            pet_state_summary="宠物正等待用户开始今天的学习任务。",
            recent_messages=recent_messages,
            retrieved_memories=memories,
        )

    async def save_memory_candidates(
        self,
        user_id: UUID,
        source_message_id: UUID,
        candidates: list[MemoryCandidate],
    ) -> None:
        for candidate in candidates:
            if candidate.confidence < 0.75 or candidate.importance < 3:
                continue
            memory = UserMemory(
                user_id=user_id,
                category=candidate.category,
                content=candidate.content,
                normalized_key=self._normalized_key(candidate.content),
                importance=candidate.importance,
                confidence=round(candidate.confidence * 100),
                source_message_id=source_message_id,
            )
            self._session.add(memory)

    async def _recent_messages(self, conversation_id: UUID) -> list[dict[str, str]]:
        statement = (
            select(ChatMessage)
            .where(ChatMessage.conversation_id == conversation_id)
            .order_by(desc(ChatMessage.created_at))
            .limit(self._settings.max_recent_messages)
        )
        result = await self._session.scalars(statement)
        messages = list(reversed(result.all()))
        return [{"role": message.role, "content": message.content} for message in messages]

    async def _relevant_memories(self, user_id: UUID) -> list[MemoryCandidate]:
        now = datetime.now(timezone.utc)
        statement = (
            select(UserMemory)
            .where(
                UserMemory.user_id == user_id,
                UserMemory.is_active.is_(True),
                (UserMemory.expires_at.is_(None)) | (UserMemory.expires_at > now),
            )
            .order_by(desc(UserMemory.importance), desc(UserMemory.updated_at))
            .limit(self._settings.max_retrieved_memories)
        )
        result = await self._session.scalars(statement)
        memories = result.all()
        return [
            MemoryCandidate(
                category=memory.category,
                content=memory.content,
                confidence=memory.confidence / 100,
                importance=memory.importance,
            )
            for memory in memories
        ]

    @staticmethod
    def _normalized_key(content: str) -> str:
        return " ".join(content.lower().split())[:160]

