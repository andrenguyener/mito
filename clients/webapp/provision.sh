#!/usr/bin/env bash

# This file will be running on the cloud.
# Linux machine expects file with LF line endings instead of CRLF.
# Make sure the file is saved with appropriate line endings.

export CLIENT_CONTAINER=mitoclient

docker pull andrenguyener/mitoclient

if [ "$(docker ps -aq --filter name=$CLIENT_CONTAINER)" ]; then
    docker rm -f $CLIENT_CONTAINER
fi

docker image prune -f

docker run -d \
-p 80:80 \
-p 443:443 \
--name mitoclient \
-v /etc/letsencrypt:/etc/letsencrypt:ro \
andrenguyener/mitoclient