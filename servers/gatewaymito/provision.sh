#!/usr/bin/env bash
docker pull andrenguyener/gatewaymito
docker rm -f gatewaymito
docker run -d \
--network appnet \
-p 443:443 \
--name gatewaymito \
-v /etc/letsencrypt:/etc/letsencrypt:ro \
-e TLSKEY=/etc/letsencrypt/live/api.projectmito.io/privkey.pem \
-e TLSCERT=/etc/letsencrypt/live/api.projectmito.io/fullchain.pem \
-e REDISADDR=redissvr:6379 \
-e ADDR=:443 \
-e SESSIONKEY=password \
-e MITONODEADDR=mitonode:80 \
-e MQADDR=rabbit:5672 \
andrenguyener/gatewaymito