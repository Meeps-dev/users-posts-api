#!/usr/bin/env bash

set -Eeuo pipefail

: "${DATABASE_URL:?DATABASE_URL must be configured}"

alembic upgrade head

# updates the alembic version table to the latest revision
# data migrations are run in the deploy-ec2.sh script