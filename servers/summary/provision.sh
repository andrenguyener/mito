#!/usr/bin/env bash
docker pull andrenguyener/summary
docker rm -f summary
docker run -d \
--network appnet \
--name summary \
-e REDISADDR=redissvr:6379 \
-e DBADDR=mongos:27017 \
-e SESSIONKEY=password \
andrenguyener/summary