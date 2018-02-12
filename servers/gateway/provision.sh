#!/usr/bin/env bash
docker pull andrenguyener/gateway
docker rm -f gateway
docker run -d \
--network appnet \
-p 443:443 \
--name gateway \
-v /etc/letsencrypt:/etc/letsencrypt:ro \
-e TLSKEY=/etc/letsencrypt/live/api.andren.me/privkey.pem \
-e TLSCERT=/etc/letsencrypt/live/api.andren.me/fullchain.pem \
-e REDISADDR=redissvr:6379 \
-e DBADDR=mongos:27017 \
-e SESSIONKEY=password \
-e MESSAGESSVCADDR=messaging:80 \
-e SUMMARYSVCADDR=summary:80 \
-e MQADDR=rabbit:5672 \
andrenguyener/gateway