# Day 82: Image Optimization, Tagging, Scanning, and Security

## What I Did

* Built a baseline image using `python:3.12-bookworm`.
* Built the optimized multi-stage image using `python:3.12-slim-bookworm`.
* Reduced image size from about `404.3 MB` to `62.8 MB` — roughly `84.5%`.
* Verified the optimized container runs as non-root UID/GID `10001`.
* Audited the image for secrets, `.git`, `.env`, tests, AWS files, Terraform files, host virtual environments, and database files.
* Confirmed unnecessary tools such as `gcc`, `make`, `git`, `sshd`, `systemctl`, and `nginx` were absent.
* Created Git-SHA image tag `00f06e819665`.
* Verified the Git-SHA and `local` tags reference the same image.
* Recorded image ID, digest, platform, runtime user, and size.
* Performed a layer-cache mutation test.
* Scanned the image with Docker Scout.
* Rebuilt using `--pull` and rescanned the refreshed base image.

## What I Learned

* Slim images and multi-stage builds significantly reduce image size.
* Copying dependencies before application code improves Docker cache reuse.
* Git-SHA tags provide reliable image-to-source traceability.
* Production containers should run as non-root.
* Runtime images should exclude secrets, build tools, source-control metadata, and unnecessary services.
* Container architecture must match the deployment platform.
* Vulnerability scanning is about identifying, classifying, remediating, and documenting risk.
* Some vulnerabilities originate from the base image rather than application dependencies.
* Vulnerabilities without available fixes should be documented and monitored.

## What Broke and How I Fixed It

### Base-Image Vulnerabilities

* **Problem:** Docker Scout reported `2 Critical` and `3 High` vulnerabilities.
* **Cause:** Findings came from Debian base-image packages including `perl` and `openssl`.
* **Fix Attempt:** Rebuilt using `docker build --pull` to fetch the latest `python:3.12-slim-bookworm`.
* **Result:** The same Critical/High findings remained with no fixed versions available.
* **Resolution:** Documented them as upstream/base-image residual risk instead of changing unrelated application dependencies.

### Layer-Cache Mutation Test

* **Test:** Temporarily modified `app/main.py`.
* **Observation:** Dependency and `/opt/venv` layers remained cached while the application `COPY` layer rebuilt.
* **Recovery:** Restored `app/main.py`.
* **Verification:** Before/after file hashes matched exactly.

## Result

* Baseline image: approximately `404.3 MB`.
* Optimized image: approximately `62.8 MB`.
* Image-size reduction: approximately `84.5%`.
* Runtime user: non-root `app`.
* Platform: `linux/amd64`.
* Git-SHA tag: `00f06e819665`.
* No sensitive runtime files or secrets detected.
* Layer caching verified.
* Vulnerability scanning completed.
* Base-image refresh tested and residual risk documented.
* Completed the Day 82 image optimization, tagging, scanning, and security practical work.
  ::: 
