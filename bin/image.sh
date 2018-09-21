#!/bin/sh
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

readonly build_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
readonly cmd=$1
readonly image=$2
readonly tag=$3
readonly usage="Usage: $(basename "$0") [COMMAND] [IMAGE] [TAG]

    Available commands:
        build
        push
        release
        save
        test
"
readonly vcs_ref=$(git rev-parse --short HEAD)
readonly version=$(grep ^sphinx== requirements.pip | tr -s '==' | cut -d '=' -f 2)

set_image_variables() {
    case "${tag}" in
        latest)
            ext=""
            version_tag=$version
            ;;
        *)
            ext=".${tag}"
            version_tag="${version}-${tag}"
            ;;
    esac
}

image_build() {
    set_image_variables
    docker build --build-arg BUILD_DATE="${build_date}" \
        --build-arg VCS_REF="${vcs_ref}" \
        --build-arg VERSION="${version}" \
        --file Dockerfile"${ext}" \
        --tag "${image}:${version_tag}" \
        --tag "${image}:${tag}" \
        .
}

image_push() {
    set_image_variables
    docker push "${image}:${version_tag}"
    docker push "${image}:${tag}"
}

image_save() {
    set_image_variables
    docker save "${image}:${version_tag}" "${image}:${tag}"
}

image_test_cmd() {
    rm -fr docs
    test_cmd="sphinx-quickstart --author=me --project=smoke-test --quiet docs && $1"
    docker run --interactive --name sphinx-doc_test --tty "${image}:${tag}" sh -c "${test_cmd}"
    container=$(docker ps --all --filter ancestor="${image}:${tag}" --format "{{.Names}}")
    docker cp "${container}:/home/python/docs" "$(pwd)"
    docker rm "${container}"
}

image_test() {
    image_test_cmd "make --directory=docs html"
    [ -f docs/conf.py ] && [ -f docs/Makefile ] && [ -f docs/_build/html/index.html ]
    if [ "${tag}" = "latex" ]; then
        image_test_cmd "make --directory=docs latexpdf LATEXMKOPTS='-silent'"
        [ -f docs/_build/latex/smoke-test.pdf ]
    fi
}

image_release() {
    echo "Are you sure you want to release version $version? [y/N]"
    read -r answer
    if echo "$answer" | grep -iq "^y"; then
        git diff --cached --quiet
        git checkout develop
        git pull --ff-only
        git checkout master
        git pull --ff-only
        git merge develop
        git tag "$version"
        git push --tags
    fi
}

main() {
    case "${cmd}" in
        build) image_build ;;
        push) image_push ;;
        release) image_release ;;
        save) image_save ;;
        test) image_test ;;
        *) echo "${usage}" && exit 1 ;;
    esac
}

main
