#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. /app/.venv/bin/activate
exec "$@"
