#!/bin/sh

set -e

docker network create chinook-net
#Chinook seeder bec it's gonna take the chinook.db file
docker build --target seeder -t chinook-seeder:latest .
docker build --target agent -t chinook-agent:latest .

docker run --rm \
    --name chinook-seeder \
    --network chinook-net \
    --env-file mcp_secret.env \
    -e DATABASE_URL=postgres://admin:pass123@postgres-db:5432/chinook_db \
    chinook-seeder:latest