import uuid

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_create_user():
    unique_email = f"testuser_{uuid.uuid4()}@test.com"
    response = client.post("/users/", json={"name": "Test User", "email": unique_email})
    assert response.status_code == 200
    assert response.json()["email"] == unique_email


def test_get_users():
    unique_email = f"testuser_{uuid.uuid4()}@test.com"
    client.post("/users/", json={"name": "Get Users Test User", "email": unique_email})

    response = client.get("/users/")
    assert response.status_code == 200
    users = response.json()
    assert isinstance(users, list)
    assert len(users) > 0
    assert any(u["email"] == unique_email for u in users)
