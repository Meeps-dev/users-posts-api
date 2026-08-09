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
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy-dev.yml
├── app/
│   ├── main.py          # FastAPI application entry point
│   ├── config.py        # Centralized settings & env configuration
│   ├── database.py      # SQLAlchemy engine & session setup
│   ├── models/          # ORM models (User, Post)
│   ├── schemas/         # Pydantic schemas (User, Post)
│   └── routers/         # API routes (users, posts)
├── alembic/             # Migration environment & revision scripts
├── tests/               # Pytest test suite
├── deploy/
│   └── users-posts-api.service  # Versioned systemd unit
├── scripts/
│   ├── package.sh       # Build the immutable application ZIP
│   ├── deploy.sh        # Install and activate a release on EC2
│   ├── health-check.sh  # Poll an application health endpoint
│   └── rollback.sh      # Restore the previous healthy release
├── .env                 # Local environment variables (git-ignored)
├── .env.example         # Template for environment variables
├── requirements.txt     # Python dependencies
└── README.md
```

---

## 📦 Deployment Assets

The deployment files are separated by responsibility:

- `scripts/package.sh` builds a commit-specific ZIP and SHA-256 checksum.
- `scripts/deploy.sh` installs a release, retrieves the RDS secret, runs
  migrations, installs the systemd unit, and switches the `current` symlink.
- `scripts/health-check.sh` polls any supplied health URL with configurable
  retry settings.
- `scripts/rollback.sh` is called internally by `deploy.sh` to restore the
  previous release, release-local virtual environment, and systemd unit.
- `deploy/users-posts-api.service` is the version-controlled service definition.

Build an artifact locally from a committed revision:

```bash
bash scripts/package.sh \
  --ref "$(git rev-parse HEAD)" \
  --output "dist/users-posts-api.zip"
```

Run a health check:

```bash
HEALTH_CHECK_ATTEMPTS=30 \
HEALTH_CHECK_INTERVAL_SECONDS=5 \
  bash scripts/health-check.sh http://127.0.0.1:8080/health
```

The CD workflow invokes `deploy.sh` through SSM. It supplies `RELEASE_SHA`,
`SOURCE_DIR`, `AWS_REGION`, `RDS_SECRET_ARN`, `DB_HOST`, `DB_PORT`, `DB_NAME`,
`APP_PORT`, and `EXPECTED_PORT`; database credentials are retrieved only on EC2.
`rollback.sh` is an internal script and should not be invoked manually.

Each release has its own `.venv`, so switching the release symlink also switches
its Python dependencies. Alembic migrations must remain backward-compatible:
application rollback does not reverse database migrations that already committed.

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
