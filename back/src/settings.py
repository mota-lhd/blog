from pydantic import BaseSettings

class Settings(BaseSettings):
    SERVICE_NAME: str
    PROJECT_ID: str
    CAPTCHA_SERVER_KEY: str
    CAPTCHA_API_URL: str
    DEBUG: bool = False
    REQUEST_TIMEOUT: int = 30

    API_V1_STR: str = "/api"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
