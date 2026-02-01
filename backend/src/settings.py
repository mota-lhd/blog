from pydantic_settings import BaseSettings


class Settings(BaseSettings):
  database_url: str
  turnstile_secret: str
  turnstile_api_url: str
  service_name: str

  debug: bool = False
  request_timeout: int = 30

  class Config:
    env_file = ".env"
    case_sensitive = False
    env_file_encoding = "utf-8"


settings = Settings()
