#!/usr/bin/env bash
chmod +x build.sh
./build.sh
chmod +x provision.sh
docker push andrenguyener/gatewaymito

ssh root@159.89.85.95 'bash -s' < provision.sh



