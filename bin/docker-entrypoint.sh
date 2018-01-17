#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. /home/python/.venv/bin/activate
exec "$@"
