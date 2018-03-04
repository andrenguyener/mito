#!/usr/bin/env bash

set -e

docker build -t andrenguyener/mitoclient .

if [ "$(docker ps -aq --filter name=mitoclient)" ]; then
    docker rm -f mitoclient
fi

# Remove dangling images.
if [ "$(docker images -q -f dangling=true)" ]; then
    docker rmi $(docker images -q -f dangling=true)
fi