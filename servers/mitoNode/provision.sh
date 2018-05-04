#!/usr/bin/env bash
# docker pull andrenguyener/mitonode
# docker rm -f mitonode
# docker run -d \
# --network appnet \
# --name mitonode \
# -e REDISADDR=redissvr:6379 \
# -e SESSIONKEY=password \
# -e MQADDR=rabbit:5672 \
# -e ADDR=:80 \
# andrenguyener/mitonode


set -e

export MESSAGING_CONTAINER=mitonode
export MQ_CONTAINER=rabbit
export APP_NETWORK=appnet

docker pull andrenguyener/$MESSAGING_CONTAINER

if [ "$(docker ps -aq --filter name=$MESSAGING_CONTAINER)" ]; then
    docker rm -f $MESSAGING_CONTAINER
fi

if [ "$(docker images -q -f dangling=true)" ]; then
    docker rmi $(docker images -q -f dangling=true)
fi

docker system prune -f

if ! [ "$(docker network ls | grep $APP_NETWORK)" ]; then
    docker network create $APP_NETWORK
fi

# No need to specify Redis port here,
# because it is default to 6379.
docker run \
-d \
-e ADDR=:80 \
-e MQADDR=$MQ_CONTAINER:5672 \
-e REDISADDR=redissvr:6379 \
--name $MESSAGING_CONTAINER \
--network $APP_NETWORK \
--restart unless-stopped \
andrenguyener/$MESSAGING_CONTAINER