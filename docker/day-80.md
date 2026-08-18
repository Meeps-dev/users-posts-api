# Day 80: Docker Compose with FastAPI and PostgreSQL

## What I Did

* Created `compose.yaml` with `db`, `migrate`, and `api` services.
* Used `postgres:15` for PostgreSQL.
* Added `pg_isready` health checks.
* Added a one-off `migrate` service for `alembic upgrade head`.
* Configured dependency order: `db → migrate → api`.
* Used `.env.compose` for runtime configuration.
* Connected services through the default Compose network.
* Used `db:5432` as the internal database address.
* Published the API only on `127.0.0.1:8000`.
* Added the `postgres_data` named volume.
* Verified healthy API/database containers and successful migrations.
* Created a user and post through FastAPI Swagger.
* Destroyed and recreated the containers.
* Confirmed the database records survived through the named volume.

## What I Learned

* Docker Compose manages multiple related containers from one YAML file.
* Containers can communicate through Compose DNS using service names.
* `localhost` inside the API container refers to the API container itself.
* `service_healthy` waits for PostgreSQL readiness.
* `service_completed_successfully` can ensure migrations finish before the API starts.
* A migration container can exit with code `0` after completing its task.
* Named volumes persist data independently of container lifecycle.
* `docker compose down` keeps named volumes unless `-v` is used.
* Runtime configuration should be injected instead of baked into images.
* Application health and database readiness are separate concerns.

## What Broke and How I Fixed It

### Duplicate Image Build Conflict

* **Problem:** `api` and `migrate` both inherited the same `build:` configuration.
* **Error:** `image "meeps-users-posts-api:compose" already exists`.
* **Fix:** Kept `build:` only on `api` and allowed `migrate` to reuse the built image.

### Wrong Database Hostname

* **Problem:** Changed the database hostname from `db` to `localhost`.
* **Result:** `GET /users/` returned `500 Internal Server Error`.
* **Logs:** PostgreSQL connection to `localhost:5432` was refused.
* **Debugging:** Verified that Compose DNS still resolved `db`.
* **Fix:** Restored `DATABASE_URL` to use `db:5432`.
* **Result:** Database access recovered successfully.

## Result

* Successfully ran FastAPI, PostgreSQL, and Alembic with Docker Compose.
* Confirmed service dependency ordering and internal DNS.
* Confirmed health checks and successful migrations.
* Confirmed PostgreSQL was not exposed publicly.
* Confirmed persistent database data after container destruction and recreation.
* Completed the Day 80 Docker Compose practical lab.
  ::: 
