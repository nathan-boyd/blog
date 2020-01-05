#! /bin/bash

set -e

source ./scripts/util.sh

DOCKER_USERNAME=$1
DOCKER_PASSWORD=$2

JEKYLL_VERSION=3.8

ISTAG=false
SEMVER=0.0.1

command -v docker >/dev/null 2>&1 || { echo "docker is required but not installed" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "git is required but not installed" >&2; exit 1; }

CHECKOUT=$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)
if grep -q '^tags/' <<< "$CHECKOUT"; then
    ISTAG=true
    SEMVER=$(echo "$CHECKOUT" | grep -oE "[0-9]+[.][0-9]+[.][0-9]+")
fi

REPO=nathanboyd
IMAGE=blog
IMAGE_TAG="$REPO/$IMAGE:$SEMVER"

log() {
    while read -r data; do
        if [ -n "$data" ]; then
            $1 $data
        else
            echo ""
        fi
    done
}

build() {
    logInfo "building site"

    docker run --rm \
        --volume="$PWD/vendor/bundle:/usr/local/bundle" \
        --volume="$PWD:/srv/jekyll" \
        -it jekyll/jekyll:$JEKYLL_VERSION \
        jekyll build

    logInfo "completed building site"
}

test() {
    logInfo "testing site"

    docker run --rm \
        --volume="$PWD/_site:/_site" \
        18fgsa/html-proofer \
            --file-ignore '/_site/404.html' \
            --empty-alt-ignore \
            --disable-external \
            /_site

    logInfo "completed testing site"
}

doctor() {
    logInfo "checking config"

    docker run --rm \
        --volume="$PWD/vendor/bundle:/usr/local/bundle" \
        --volume="$PWD:/srv/jekyll" \
        -it jekyll/jekyll:$JEKYLL_VERSION \
        jekyll doctor

    logInfo "completed checking config"
}

tag() {

    logInfo "building image with tag $IMAGE_TAG"

    docker build . -t $IMAGE_TAG

    logInfo "completed building image"
}

publish() {

    logInfo "starting publish"

    if [ $ISTAG != true ]; then
        logWarn "publish skipped, publish only runs when tags are checked out"
        return
    fi

    # Required; if any are empty error and exit 1
    [ -n "$DOCKER_USERNAME" ] || { logErr "DOCKER_USERNAME is required" >&2; exit 1; }
    [ -n "$DOCKER_PASSWORD" ] || { logErr "DOCKER_PASSWORD is required" >&2; exit 1; }

    logInfo "running docker login"
    echo $DOCKER_PASSWORD | docker login -u="$DOCKER_USERNAME" --password-stdin
    logInfo "completed docker login"

    docker push $IMAGE_TAG
    logInfo "completed publish"
}

{
    logInfo "semver is "\""$SEMVER"\"""

    build
    test
    doctor
    tag
    publish

} | log withTime
