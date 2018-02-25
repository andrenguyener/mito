#!/usr/bin/env bash
chmod +x build.sh
./build.sh
chmod +x provision.sh
docker push andrenguyener/messaging

ssh root@159.89.141.71 'bash -s' < provision.sh


