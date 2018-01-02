#!/usr/bin/env sh
# This file:
#
#  - Save Docker image
#
# Usage:
#
#  ./bin/save.sh [IMAGE] [TAG]

# Exit on error. Append "|| true" if you expect an error.
set -e
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail

image=$1
tag=$2
version=$(grep ^sphinx== requirements.pip | tr -s '==' | cut -d '=' -f 2)

case $tag in
    latest) docker save "${image}:${version}" "${image}:${tag}";;
    latex) docker save "${image}:${version}-${tag}" "${image}:${tag}";;
esac
