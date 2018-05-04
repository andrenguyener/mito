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



# set -e

# # # This file will be running on the cloud.
# # # Linux machine expects file with LF line endings instead of CRLF.
# # # Make sure the file is saved with appropriate line endings.

# export GATEWAY_CONTAINER=gatewaymito
# export REDIS_CONTAINER=redissvr
# export MQ_CONTAINER=rabbit

# export APP_NETWORK=appnet

# export TLSCERT=/etc/letsencrypt/live/api.projectmito.io/fullchain.pem
# export TLSKEY=/etc/letsencrypt/live/api.projectmito.io/privkey.pem 

# export SESSIONKEY=password

# export ADDR=:443
# export REDISADDR=$REDIS_CONTAINER:6379
# export MQADDR=$MQ_CONTAINER:5672


# # # Microservice addresses.
# export MITONODEADDR=mitonode:80

# # # Make sure to get the latest image.
# docker pull andrenguyener/$GATEWAY_CONTAINER

# # # Remove the old containers first.
# if [ "$(docker ps -aq --filter name=$GATEWAY_CONTAINER)" ]; then
#     docker rm -f $GATEWAY_CONTAINER
# fi

# if [ "$(docker ps -aq --filter name=$REDIS_CONTAINER)" ]; then
#     docker rm -f $REDIS_CONTAINER
# fi

# if [ "$(docker ps -aq --filter name=$MQ_CONTAINER)" ]; then
#     docker rm -f $MQ_CONTAINER
# fi

# # # Remove dangling images.
# if [ "$(docker images -q -f dangling=true)" ]; then
#     docker rmi $(docker images -q -f dangling=true)
# fi

# # # Clean up the system.
# docker system prune -f

# # # Create Docker private network if not exist.
# if ! [ "$(docker network ls | grep $APP_NETWORK)" ]; then
#     docker network create $APP_NETWORK
# fi

# # # Run Redis Docker container inside our appnet private network.
# docker run \
# -d \
# --name $REDIS_CONTAINER \
# --network $APP_NETWORK \
# --restart unless-stopped \
# redis


# # # Run RabbitMQ Docker container.
# docker run \
# -d \
# --network $APP_NETWORK \
# --name $MQ_CONTAINER \
# --hostname $MQ_CONTAINER \
# rabbitmq

# # # Run API Gateway Docker container inside our appnet private network.
# docker run \
# -d \
# -p 443:443 \
# --name $GATEWAY_CONTAINER \
# --network $APP_NETWORK \
# -v /etc/letsencrypt:/etc/letsencrypt:ro \
# -e TLSCERT=$TLSCERT \
# -e TLSKEY=$TLSKEY \
# -e SESSIONKEY=$SESSIONKEY \
# -e ADDR=$ADDR \
# -e REDISADDR=$REDISADDR \
# -e MITONODEADDR=$MITONODEADDR \
# -e MQADDR=$MQADDR \
# --restart unless-stopped \
# andrenguyener/$GATEWAY_CONTAINER