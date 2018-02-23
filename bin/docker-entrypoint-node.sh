#!/usr/bin/env sh
set -e

ln -s /home/node/node_modules
exec "$@"
