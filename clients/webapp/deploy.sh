#!/usr/bin/env bash

set -e

./build.sh

docker push andrenguyener/mitoclient

ssh -oStrictHostKeyChecking=no root@165.227.18.0 'bash -s' < provision.sh