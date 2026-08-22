# Day 79: Production Dockerfile and Multi-Stage Build

## What I Did

- Verified the backend with Python 3.12 and PostgreSQL 15.
- Ran the test suite successfully: `21 passed`.
- Applied and validated Alembic migrations at revision `8a9f3c2d1e70`.
- Confirmed the platform as `linux/amd64` for future ECS compatibility.
- Created a secure `.dockerignore`.
- Created a multi-stage production Dockerfile using `python:3.12-slim-bookworm`.
- Installed dependencies in a builder stage and copied only the virtual environment into the runtime stage.
- Configured the API to run as the non-root `app` user.
- Added a Docker health check for `/health`.
- Started Uvicorn with `app.main:app` on `0.0.0.0:8000`.
- Built and inspected `meeps-users-posts-api:local`.
- Recorded the image size as approximately `62.8 MB` (`59.86 MiB`).
- Tested an intentional startup failure, reviewed the logs and exit status, and then ran the corrected container.

## What I Learned

- Multi-stage builds keep unnecessary build tools out of the final runtime image.
- Copying `requirements.txt` before application code improves Docker layer caching.
- `.dockerignore` reduces the build context and prevents secrets and unnecessary files from entering an image.
- `EXPOSE` documents a container port but does not publish it to the host.
- Containers should run application processes as a non-root user.
- Docker health checks determine whether the application is responding correctly.
- A container stops when its main process exits.
- Containers on the same user-defined network can communicate through container names.
- Container architecture must match the target AWS runtime architecture.
- Image content size and local Docker disk usage are different measurements.

## What Broke and How I Fixed It

### Incorrect `.dockerignore` Exception

- **Problem:** `.env.example` was excluded instead of re-included.
- **Fix:** Changed it to `!.env.example` so the safe template remains available.

### Incorrect Dependency Entry

- **Problem:** `httpx==0.28.1` was accidentally changed to `httpx2>=2.0.0`.
- **Fix:** Restored the correct pinned dependency before building the image.

### PostgreSQL Hostname Resolution Failure

- **Problem:** Alembic could not resolve `day79-postgres`.
- **Cause:** The database container was not reachable through the same Docker network.
- **Fix:** Attached PostgreSQL to `day79-network` and used `day79-postgres:5432`.

### PostgreSQL Authentication Failure

- **Problem:** PostgreSQL rejected the supplied password.
- **Cause:** The shell password no longer matched the password stored by PostgreSQL.
- **Fix:** Reset the `postgres` role password and verified authentication from another container.

### Intentional Invalid Application Module

- **Problem:** The container exited with code `1` because Uvicorn could not import `app.not_real`.
- **Debugging:** Used `docker ps -a`, `docker logs`, and `docker inspect`.
- **Fix:** Used the correct startup target: `app.main:app`.

## Result

- Produced a functioning production-style multi-stage image.
- Confirmed the image runs as UID/GID `10001`, not root.
- Confirmed the container reports `healthy`.
- Confirmed `/health` returns `{"status":"healthy"}`.
- Prepared the backend image for Docker Compose and Amazon ECR.