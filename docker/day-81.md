# Day 81: Networking, Volumes, Logs, Health, and Troubleshooting

## What I Did

* Inspected the running Docker Compose services, network, and PostgreSQL named volume.
* Verified the API and database were healthy and existing user/post data was still available.
* Inspected container state, health status, restart count, network IPs, and runtime user.
* Stopped only the API while PostgreSQL remained healthy.
* Removed and recreated only the API container.
* Confirmed the API received a new container ID while the database container remained unchanged.
* Verified persistent database records survived API replacement.
* Stopped PostgreSQL and observed database-backed requests fail.
* Restarted PostgreSQL and confirmed the API reconnected without an API restart.
* Tested an incorrect database password and inspected the authentication failure through Docker logs.
* Restored the correct runtime configuration and verified recovery.
* Killed the API container's PID 1 intentionally.
* Verified `restart: unless-stopped` automatically restarted the same container.
* Confirmed `RestartCount` increased to `1` and the API became healthy again.

## What I Learned

* Containers communicate through Compose DNS using service names such as `db`.
* Containers can be replaced independently without affecting other services.
* Persistent database data belongs to the named volume, not the application container.
* PostgreSQL can fail while the FastAPI process remains alive.
* A liveness-style `/health` endpoint may still report healthy when a database dependency is unavailable.
* Docker logs are essential for diagnosing connection and authentication failures.
* `RestartCount` helps confirm automatic container recovery.
* `restart: unless-stopped` recovers containers after unexpected process termination.
* Automatic restart keeps the same container ID.
* Remove/recreate generates a new container ID.
* `docker compose down` preserves named volumes.
* `docker compose down -v` deletes named volumes and should be treated as destructive.

## What Broke and How I Fixed It

### Database Container Unavailable

* **Problem:** PostgreSQL was stopped intentionally.
* **Symptom:** Database-backed API requests failed while FastAPI remained running.
* **Debugging:** Checked Compose service state and API logs.
* **Fix:** Restarted PostgreSQL and waited for it to become healthy.
* **Verification:** `/users/` worked again without restarting the API.

### Incorrect Database Password

* **Problem:** Recreated the API with an intentionally incorrect PostgreSQL password.
* **Symptom:** `/users/` returned HTTP `500`.
* **Logs:** `password authentication failed for user "meeps"`.
* **Fix:** Restored the original Compose runtime configuration.
* **Verification:** Database reads recovered successfully.

### API Main Process Terminated

* **Problem:** Killed PID 1 inside the API container intentionally.
* **Symptom:** The application's main process exited unexpectedly.
* **Recovery:** Docker applied `restart: unless-stopped`.
* **Verification:** The same container ID returned to `running/healthy`, `RestartCount` increased to `1`, and the API recovered.

## Result

* Confirmed container-to-container networking and Compose DNS.
* Confirmed independent API replacement.
* Confirmed PostgreSQL named-volume persistence.
* Confirmed recovery after database interruption.
* Confirmed Docker log-based troubleshooting.
* Confirmed automatic container restart after process failure.
* Completed the Day 81 networking, volume, health, logging, and troubleshooting practical work.
  ::: 
