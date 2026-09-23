from uuid import UUID

from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.schemas import ChatMessageRequest, ChatMessageResponse, PetStateResponse
from app.core.config import Settings, get_settings
from app.infrastructure.database import get_db_session
from app.services.chat_service import ChatService

api_router = APIRouter()


@api_router.get("/pet/state", response_model=PetStateResponse)
async def get_pet_state() -> PetStateResponse:
    return PetStateResponse(
        mood="encouraging",
        activity="waiting_for_task",
        message="今天的学习任务准备好啦。",
        level=1,
        experience=0,
        has_pending_task=True,
    )


@api_router.post("/chat/messages", response_model=ChatMessageResponse)
async def create_chat_message(
    request: ChatMessageRequest,
    x_user_id: UUID = Header(alias="X-User-Id"),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> ChatMessageResponse:
    try:
        return await ChatService(session, settings).respond(x_user_id, request)
    except ValueError as error:
        await session.rollback()
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(error)) from error

