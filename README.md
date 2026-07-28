# Users & Posts API

A **FastAPI backend project** demonstrating user and post management with PostgreSQL, SQLAlchemy ORM, Alembic migrations, environment-based configuration, and automated testing.

---

## 🚀 Features

- Create and read users
- Create posts linked to users
- Relational integrity (one-to-many relationship)
- Automatic database migrations with Alembic
- Centralized environment configuration via `python-dotenv` and `.env`
- OpenAPI / Swagger UI documentation at `/docs`
- Automated test suite using `pytest` and FastAPI `TestClient`

---

## 🛠️ Tech Stack

- **Python 3.12**
- **FastAPI** – Modern ASGI web framework
- **PostgreSQL** – Relational database
- **SQLAlchemy** – Database ORM
- **Alembic** – Database migrations
- **Pydantic** – Data validation
- **python-dotenv** – Environment variable management
- **pytest** – Test runner
- **Uvicorn** – ASGI web server

---

## 📁 Project Structure

```text
users-posts-api/
│
├── app/
│   ├── main.py          # FastAPI application entry point
│   ├── config.py        # Centralized settings & env configuration
│   ├── database.py      # SQLAlchemy engine & session setup
│   ├── models/          # ORM models (User, Post)
│   ├── schemas/         # Pydantic schemas (User, Post)
│   └── routers/         # API routes (users, posts)
│
├── alembic/             # Migration environment & revision scripts
├── tests/               # Pytest test suite
├── .env                 # Local environment variables (git-ignored)
├── .env.example         # Template for environment variables
├── requirements.txt     # Python dependencies
└── README.md
```

---

## ⚡ Getting Started

### 1. Clone the repository & navigate to directory

```bash
git clone <your-repo-url>
cd users-posts-api
```

### 2. Create and activate virtual environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Update `DATABASE_URL` in `.env` with your local PostgreSQL database credentials.

### 5. Setup PostgreSQL Database

Ensure PostgreSQL is running locally and create the database if not already created:

```sql
CREATE DATABASE users_posts_db;
```

### 6. Run Database Migrations

```bash
alembic upgrade head
```

### 7. Start the FastAPI Server

```bash
uvicorn app.main:app --reload
```

Open interactive Swagger docs in browser: `http://127.0.0.1:8000/docs`

---

## 🧪 Running Tests

Execute pytest:

```bash
pytest
```

Tests cover:
- User creation and retrieval
- Post creation for existing user
- Handling of non-existent user post creation (404)
- User post list retrieval

---

## 🔗 API Endpoints

### Users
- `POST /users/` – Create a new user
- `GET /users/` – List all users

### Posts
- `POST /posts/users/{user_id}` – Create a post for a user
- `GET /posts/users/{user_id}` – List all posts for a user

### System
- `GET /` – Root API status
- `GET /health` – Health check endpoint
