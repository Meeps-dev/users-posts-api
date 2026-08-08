#!/usr/bin/env bash

set -Eeuo pipefail

exec uvicorn app.main:app \
  --host "${HOST:-0.0.0.0}" \
  --port "${PORT:-8080}"
  
# Adds deployment/runtime scripts to the artifact
# starts the API server using uvicorn with specified host and port, defaulting to
