#!/usr/bin/env sh
# This file:
#
#  - Push Docker images to registry
#
# Usage:
#
#  ./bin/push.sh [IMAGE] [TAG]

# Exit on error. Append "|| true" if you expect an error.
set -e
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail

image=$1
tag=$2
version=$(grep ^sphinx== requirements.pip | tr -s '==' | cut -d '=' -f 2)

case $tag in
    latest) docker push "${image}:${version}";
        docker push "${image}:${tag}";;
    latex) docker push "${image}:${version}-${tag}";
        docker push "${image}:${tag}";;
esac
