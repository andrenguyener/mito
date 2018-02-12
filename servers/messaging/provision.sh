#!/usr/bin/env bash
docker pull andrenguyener/messaging
docker rm -f messaging
docker run -d \
--network appnet \
--name messaging \
-e REDISADDR=redissvr:6379 \
-e DBADDR=mongos:27017 \
-e SESSIONKEY=password \
-e MQADDR=rabbit:5672 \
andrenguyener/messaging