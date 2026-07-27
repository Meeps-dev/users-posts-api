# Users & Posts API

A **FastAPI backend project** demonstrating user and post management with PostgreSQL, SQLAlchemy ORM, Alembic migrations, and automated testing.

This project is part of a series of backend projects showcasing real-world API design and database relationships.

---

## 🚀 Features

- Create, read users
- Create posts for users
- Strong relational integrity: each post belongs to one user
- Automatic database migrations with Alembic
- Pydantic schemas for input validation and response shaping
- Swagger UI documentation available at `/docs`
- Automated tests using pytest and FastAPI TestClient

---

## 🛠️ Tech Stack

- **Python 3.12**
- **FastAPI** – Modern, high-performance web framework
- **PostgreSQL** – Relational database
- **SQLAlchemy** – ORM to interact with PostgreSQL
- **Alembic** – Database migrations
- **Pydantic** – Data validation
- **pytest** – Automated testing
- **Uvicorn** – ASGI server

---

## 📁 Project Structure

users-posts-api/
│
├── app/
│ ├── main.py
│ ├── database.py
│ ├── models/
│ │ ├── user.py
│ │ └── post.py
│ ├── schemas/
│ │ ├── user.py
│ │ └── post.py
│ └── routers/
│ ├── users.py
│ └── posts.py
│
├── alembic/
├── tests/
│ ├── test_users.py
│ └── test_posts.py
├── requirements.txt
└── README.md

---

## ⚡ Getting Started

### 1. Clone the repo

```bash
git clone <your-repo-url>
cd users-posts-api

2. Create a virtual environment
python3 -m venv venv
source venv/bin/activate

3. Install dependencies
pip install -r requirements.txt

4. Setup PostgreSQL database
CREATE DATABASE users_posts_db;


Update app/database.py if your DB URL is different.

5. Run migrations
alembic upgrade head

6. Start server
uvicorn app.main:app --reload


Open browser: http://127.0.0.1:8000/docs

docs

🧪 Running Tests
pytest


Tests cover:

User creation

Post creation

Invalid post creation (non-existent user)

🔗 API Endpoints
Users

POST /users/ – Create user

GET /users/ – List all users

Posts

POST /posts/users/{user_id} – Create post for a specific user

GET /posts/ – List all posts for a user

🧠 Key Learnings

Proper relational modeling (one-to-many)

Schema separation (Pydantic vs SQLAlchemy models)

Database migrations with Alembic

Automated testing for API endpoints

Clean, modular project structure ready for GitHub and recruiters

Meeps-dev.
```
