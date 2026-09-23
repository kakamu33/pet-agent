from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field


class ChatMessageRequest(BaseModel):
    conversation_id: UUID | None = None
    content: str = Field(min_length=1, max_length=8_000)
    client_timestamp: datetime | None = None


class ChatMessageResponse(BaseModel):
    conversation_id: UUID
    message_id: UUID
    content: str
    pet_mood: Literal["idle", "encouraging", "thinking", "celebrating", "resting"]


class PetStateResponse(BaseModel):
    mood: Literal["idle", "encouraging", "thinking", "celebrating", "resting"]
    activity: Literal["waiting_for_task", "studying", "resting", "celebrating"]
    message: str
    level: int = Field(ge=1)
    experience: int = Field(ge=0)
    has_pending_task: bool


class MemoryCandidate(BaseModel):
    category: Literal["profile", "preference", "learning", "constraint", "relationship"]
    content: str = Field(min_length=1, max_length=1_000)
    confidence: float = Field(ge=0, le=1)
    importance: int = Field(ge=1, le=5)


class ContextSnapshot(BaseModel):
    user_id: UUID
    profile_summary: str
    active_goal_summary: str
    pet_state_summary: str
    recent_messages: list[dict[str, str]]
    retrieved_memories: list[MemoryCandidate]

