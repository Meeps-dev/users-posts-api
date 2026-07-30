#!/usr/bin/env bash

set -Eeuo pipefail

exec uvicorn app.main:app \
  --host "${HOST:-0.0.0.0}" \
  --port "${PORT:-8000}"


# Added deployment/runtime scripts to the artifact