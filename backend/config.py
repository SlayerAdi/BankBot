# config.py
"""Application configuration loaded from .env file."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_HOST: str = "0.0.0.0"
    APP_PORT: int = 8000
    FRONTEND_URL: str = "http://localhost:3000"
    DEBUG: bool = True

    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = "password"
    DB_NAME: str = "infybot_db"

    SECRET_KEY: str = "infybot_secret_123456789"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_HOURS: int = 24

    RASA_URL: str = "http://localhost:5005"

    # Optional: absolute path to the rasa executable.
    # Leave blank to auto-detect from PATH via shutil.which("rasa").
    # Example (Windows): C:\Users\you\AppData\Local\Programs\Python\Python310\Scripts\rasa.exe
    # Example (Linux/macOS): /usr/local/bin/rasa
    RASA_EXE: str = ""

    RATE_LIMIT: str = "200/minute"

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore"
    )


settings = Settings()