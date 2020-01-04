#! /bin/bash

set -e

source ./scripts/util.sh

ISTAG=false
SEMVER=0.0.1
REPO=nathanboyd
IMAGE=blog
JEKYLL_VERSION=3.8

if grep -q '^tags/' <<< "$CHECKOUT"; then
    ISTAG=true
    SEMVER=$(echo "$CHECKOUT" | grep -oE "[0-9]+[.][0-9]+[.][0-9]+")
fi

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
        --volume="$PWD/_site:/srv/jekyll" \
        18fgsa/html-proofer --file-ignore '/srv/jekyll/404.html' /srv/jekyll

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
    IMAGE_TAG="$REPO/$IMAGE:$SEMVER"

    logInfo "building image with tag IMAGE_TAG"

    docker build . -t $IMAGE_TAG

    logInfo "completed building image"
}

publish() {
    if [ $ISTAG != true ]; then
        logWarn "publish skipped, publish only runs on tagged commits"
        return
    fi
}

{
    logInfo "tag is "\""$Tag"\"""
    logInfo "semver is "\""$SEMVER"\"""

    build
    test
    doctor
    tag
    publish

} | log withTime
