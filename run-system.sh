#!/bin/sh

set -e

docker network inspect chinook-net >/dev/null 2>&1 || docker network create chinook-net
#Chinook seeder bec it's gonna take the chinook.db file
docker build --target seeder -t chinook-seeder:latest .
docker build --target agent -t chinook-agent:latest .

docker run -d \
    --name postgres-db \
    --network chinook-net \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=pass123 \
    -e POSTGRES_DB=chinook_db \
    postgres:17
