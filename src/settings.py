from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    SERVICE_NAME: str
    CAPTCHA_SERVER_KEY: str
    CAPTCHA_API_URL: str
    SUPABASE_URL: str
    SUPABASE_KEY: str

    DEBUG: bool = False
    REQUEST_TIMEOUT: int = 30

    API_V1_STR: str = "/api"

    class Config:
        case_sensitive = True
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
