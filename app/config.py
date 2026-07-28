import os
from dotenv import load_dotenv

# Load environment variables from .env file if available
load_dotenv()


class Settings:
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://postgres:postgrespassword@localhost:5432/users_posts_db",
    )


settings = Settings()
