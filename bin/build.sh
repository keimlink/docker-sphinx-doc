#!/usr/bin/env sh
# This file:
#
#  - Build Docker container
#
# Usage:
#
#  ./bin/build.sh [TAG]

# Exit on error. Append "|| true" if you expect an error.
set -e
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail

build_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
image="sphinx-doc"
tag=$*
vcs_ref=$(git rev-parse --short HEAD)
version=$(grep --color=no ^sphinx== requirements.pip | tr -s '==' | cut -d '=' -f 2)

echo "Building ${image}:${tag}."
echo

case $tag in
    latest) docker build --build-arg BUILD_DATE="${build_date}" \
        --build-arg VCS_REF="${vcs_ref}" \
        --build-arg VERSION="${version}" \
        --tag "${image}:${version}" \
        --tag "${image}:${tag}" \
        .;;
    latex) docker build --build-arg BUILD_DATE="${build_date}" \
        --build-arg VCS_REF="${vcs_ref}" \
        --build-arg VERSION="${version}" \
        --file Dockerfile."${tag}" \
        --tag "${image}:${version}-${tag}" \
        --tag "${image}:${tag}" \
        .;;
esac
