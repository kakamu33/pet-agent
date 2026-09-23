from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Pet Agent API"
    api_prefix: str = "/v1"
    database_url: str = "postgresql+asyncpg://pet_agent:pet_agent_dev@localhost:5432/pet_agent"
    redis_url: str = "redis://localhost:6379/0"
    llm_model: str = ""
    max_recent_messages: int = 12
    max_retrieved_memories: int = 6

    model_config = SettingsConfigDict(
        env_prefix="PET_AGENT_",
        env_file=".env",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()

