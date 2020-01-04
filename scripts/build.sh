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

doctor() {
    logInfo "checking config with running doctor "

    docker run --rm \
        --volume="$PWD/vendor/bundle:/usr/local/bundle" \
        --volume="$PWD:/srv/jekyll" \
        -it jekyll/jekyll:$JEKYLL_VERSION \
        jekyll doctor

    logInfo "completed doctor"
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

tag() {
    logInfo "building image with tag $SEMVER"
    docker build . -t "$REPO/$IMAGE:$SEMVER"
    logInfo "completed building image"
}

test() {
    logInfo "Testing site"
    docker run --rm --volume="$PWD/_site:/srv/jekyll" 18fgsa/html-proofer /srv/jekyll
    logInfo "Testing complete"
}

publish() {
    if [ $ISTAG != true ]; then
        echo "Publish only from tag checkout; skipping"
        return
    fi
}

{
    logInfo "tag is "\""$Tag"\"""
    logInfo "semver is "\""$SEMVER"\"""

    doctor
    build
    test
    tag
    publish

} | log withTime
