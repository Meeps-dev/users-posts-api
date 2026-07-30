#!/usr/bin/env bash

set -Eeuo pipefail

: "${DATABASE_URL:?DATABASE_URL must be configured}"

alembic upgrade head

# Added deployment/runtime scripts to the artifact