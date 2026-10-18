#!/bin/sh

set -e

docker network create chinook-net
#Chinook seeder bec it's gonna take the chinook.db file
docker build --target seeder -t chinook-seeder:latest .
docker build --target agent -t chinook-agent:latest .
