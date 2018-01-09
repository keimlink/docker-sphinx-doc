#!/usr/bin/env sh
# This file:
#
#  - Various commands for Docker images
#
# Usage:
#
#  ./bin/image.sh [COMMAND] [IMAGE] [TAG]

# Exit on error. Append "|| true" if you expect an error.
set -e
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail

readonly BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
readonly COMMAND=$1
readonly IMAGE=$2
readonly TAG=$3
readonly USAGE="Usage: $(basename "$0") [COMMAND] [IMAGE] [TAG]

  Available commands:
    build
    push
    save
    test
"
readonly VCS_REF=$(git rev-parse --short HEAD)
readonly VERSION=$(grep ^sphinx== requirements.pip | tr -s '==' | cut -d '=' -f 2)

image_build()
{
  case "${TAG}" in
    latest)
      docker build --build-arg BUILD_DATE="${BUILD_DATE}" \
        --build-arg VCS_REF="${VCS_REF}" \
        --build-arg VERSION="${VERSION}" \
        --tag "${IMAGE}:${VERSION}" \
        --tag "${IMAGE}:${TAG}" \
        .
      ;;
    latex)
      docker build --build-arg BUILD_DATE="${BUILD_DATE}" \
        --build-arg VCS_REF="${VCS_REF}" \
        --build-arg VERSION="${VERSION}" \
        --file Dockerfile."${TAG}" \
        --tag "${IMAGE}:${VERSION}-${TAG}" \
        --tag "${IMAGE}:${TAG}" \
        .
      ;;
  esac
}

image_push()
{
  case "${TAG}" in
    latest) docker push "${IMAGE}:${VERSION}" ;;
    latex) docker push "${IMAGE}:${VERSION}-${TAG}" ;;
  esac
  docker push "${IMAGE}:${TAG}"
}

image_save()
{
  case "${TAG}" in
    latest) docker save "${IMAGE}:${VERSION}" "${IMAGE}:${TAG}" ;;
    latex) docker save "${IMAGE}:${VERSION}-${TAG}" "${IMAGE}:${TAG}" ;;
  esac
}

image_test_cmd()
{
    rm -fr docs
    cmd="sphinx-quickstart --author=me --project=smoke-test --quiet docs && $1"
    docker run --interactive --tty "${IMAGE}:${TAG}" sh -c "${cmd}"
    container=$(docker ps --all --filter ancestor="${IMAGE}:${TAG}" --format "{{.Names}}")
    docker cp "${container}:/app/docs" "$(pwd)"
    docker rm "${container}"
}

image_test()
{
    image_test_cmd "make --directory=docs html"
    [ -f docs/conf.py ] && [ -f docs/Makefile ] && [ -f docs/_build/html/index.html ]
    if [ "${TAG}" = "latex" ]; then
      image_test_cmd "make --directory=docs latexpdf LATEXMKOPTS='-silent'"
      [ -f docs/_build/latex/smoke-test.pdf ]
    fi
}

main()
{
  case "${COMMAND}" in
    build) image_build ;;
    push) image_push ;;
    save) image_save ;;
    test) image_test ;;
    *) echo "${USAGE}" && exit 1 ;;
  esac
}

main
