#!/usr/bin/env sh
# This file:
#
#  - Run smoke tests in Docker container
#
# Usage:
#
#  ./bin/test.sh [TAG]

# Exit on error. Append "|| true" if you expect an error.
set -e
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail

image="sphinx-doc"
tag=$*

echo "Running smoke tests for ${image}:${tag}."
echo

rm -fr docs/*

docker run \
    --interactive \
    --rm \
    --tty \
    --volume "$(pwd)/docs":/app/docs \
    "${image}:${tag}" \
    sh -c "sphinx-quickstart --author=me --project=smoke-test --quiet docs && make --directory=docs html"

[ -f docs/conf.py ] && [ -f docs/Makefile ] && [ -f docs/_build/html/index.html ]

if [ "${tag}" = "latex" ]; then
    docker run \
        --interactive \
        --rm \
        --tty \
        --volume "$(pwd)/docs":/app/docs \
        "${image}:${tag}" \
        make --directory=docs latexpdf LATEXMKOPTS="-silent"
    [ -f docs/_build/latex/smoke-test.pdf ]
fi
