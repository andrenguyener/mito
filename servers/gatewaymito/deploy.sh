#!/usr/bin/env bash
chmod +x build.sh
./build.sh
chmod +x provision.sh
docker push andrenguyener/gatewaymito

ssh root@api.projectmito.io 'bash -s' < provision.sh



