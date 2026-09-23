from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.agents.companion import RuleBasedCompanionAgent
from app.agents.memory_extractor import HeuristicMemoryExtractor
from app.api.schemas import ChatMessageRequest, ChatMessageResponse
from app.core.config import Settings
from app.domain.models import Conversation, MessageRole
from app.memory.service import MemoryService


class ChatService:
    def __init__(self, session: AsyncSession, settings: Settings) -> None:
        self._session = session
        self._memory = MemoryService(session, settings)
        self._agent = RuleBasedCompanionAgent()
        self._memory_extractor = HeuristicMemoryExtractor()

    async def respond(self, user_id: UUID, request: ChatMessageRequest) -> ChatMessageResponse:
        conversation = await self._resolve_conversation(user_id, request.conversation_id)
        user_message = await self._memory.append_message(
            conversation.id, MessageRole.USER, request.content
        )
        context = await self._memory.build_context(user_id, conversation.id)
        reply = await self._agent.reply(
            user_id=user_id,
            user_message=request.content,
            context=context,
        )
        assistant_message = await self._memory.append_message(
            conversation.id, MessageRole.ASSISTANT, reply.content
        )
        memory_candidates = [
            *self._memory_extractor.extract(request.content),
            *reply.memory_candidates,
        ]
        await self._memory.save_memory_candidates(user_id, user_message.id, memory_candidates)
        await self._session.commit()
        return ChatMessageResponse(
            conversation_id=conversation.id,
            message_id=assistant_message.id,
            content=reply.content,
            pet_mood=reply.pet_mood,
        )

    async def _resolve_conversation(
        self, user_id: UUID, conversation_id: UUID | None
    ) -> Conversation:
        if conversation_id is None:
            return await self._memory.create_conversation(user_id)
        conversation = await self._session.get(Conversation, conversation_id)
        if conversation is None or conversation.user_id != user_id:
            raise ValueError("Conversation does not belong to the current user")
        return conversation

