#! /bin/bash

export JEKYLL_VERSION=3.8

if [ ! "$(docker ps -q -f name=blog)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=blog)" ]; then
        docker rm blog > /dev/null
    fi
fi

docker run --name blog \
    --volume="$PWD/vendor/bundle:/usr/local/bundle" \
    --volume="$PWD:/srv/jekyll" \
    -p 4000:4000 -it \
    jekyll/jekyll:$JEKYLL_VERSION \
    jekyll serve --watch --drafts
