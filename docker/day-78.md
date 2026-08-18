# Day 78: Docker Foundations and Container Lifecycle

## What I Did

* Created the `feature/week-12-docker-ecr` branch from the updated `main` branch.
* Verified Docker Engine, Docker Compose, AWS CLI, and Git.
* Ran `nginx` to confirm the Docker client, daemon, and registry workflow.
* Pulled and ran Nginx with host port `8080` mapped to container port `80`.
* Used `docker ps`, `logs`, `inspect`, `exec`, `top`, and `stats` to examine the container.
* Tested an intentional host-port conflict and then ran the second Nginx container on `8081`.
* Tested the writable layer and confirmed that container data disappears after removal and recreation.
* Verified basic filesystem isolation and cleaned up the lab containers.

## What I Learned

* An image is a reusable, read-only package; a container is an instance created from that image.
* Docker commands move through the client, daemon, and image registry.
* `--rm` deletes the container after it exits but keeps the downloaded image.
* Port publishing uses `HOST_PORT:CONTAINER_PORT`.
* Containers may share the same internal port, but published host ports must be unique.
* Stop/start preserves a container’s writable layer; remove/recreate deletes it.
* Volumes or bind mounts are required for persistent data.
* Containers isolate filesystems, processes, and hostnames while sharing the host kernel.
* Tags are readable labels, while digests identify exact immutable image content.

## What Broke and How I Fixed It

### Docker Daemon Connection Failure

* **Cause:** Docker Desktop had not finished starting.
* **Fix:** Waited for the engine, reran `docker version`, and confirmed both Client and Server output.

### Container-Name Conflict

* **Cause:** I reused the existing name `docker-port-conflict`, so Docker rejected the command before checking the port.
* **Fix:** Used a new name, `docker-port-allocation-test`, for the intentional failure.

### Host Port `8080` Conflict

* **Cause:** `docker-foundations` already published `8080:80`.
* **Fix:** Located it with `docker ps --filter publish=8080`, removed the failed test container, and used `8081:80` for the second container.

### Terminal Displayed `quote>`

* **Cause:** An unmatched quotation mark left the shell waiting for more input.
* **Fix:** Cancelled with `Ctrl+C` and reran the command with matching quotes.

## Result

* Completed the Day 78 Docker foundations lab.
* Demonstrated container lifecycle, port publishing, inspection, troubleshooting, ephemeral storage, isolation, and cleanup.
* Prepared the backend repository for the Day 79 Dockerfile and multi-stage build work.
