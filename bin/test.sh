#!/usr/bin/env bash
# This file:
#
#  - Run smoke tests in Docker container
#
# Usage:
#
#  ./bin/test.sh [VERSION]
#
# Based on a template by BASH3 Boilerplate v2.3.0
# http://bash3boilerplate.sh/#authors
#
# The MIT License (MIT)
# Copyright (c) 2013 Kevin van Zonneveld and contributors
# You are not obligated to bundle the LICENSE file with your b3bp projects as long
# as you leave these references intact in the header comments of your source files.

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

echo "Running smoke tests for $* image."
echo

rm -fr docs/*

docker run \
    --interactive \
    --rm \
    --tty \
    --volume "$(pwd)/docs":/app/docs \
    "$*" \
    sh -c "sphinx-quickstart --author=me --project=smoke-test --quiet docs && make --directory=docs html"

[ -f docs/conf.py ] && [ -f docs/Makefile ] && [ -f docs/_build/html/index.html ]

if [[ "$*" == *"latex"* ]]; then
    docker run \
        --interactive \
        --rm \
        --tty \
        --volume "$(pwd)/docs":/app/docs \
        "$*" \
        make --directory=docs latexpdf LATEXMKOPTS="-silent"
    [ -f docs/_build/latex/smoke-test.pdf ]
fi
