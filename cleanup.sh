#!/bin/sh

docker rm -f $(docker ps -aq --filter label=project=chinook) 2>/dev/null

docker volume rm $(docker volume ls -q --filter label=project=chinook) 2>/dev/null

docker network rm $(docker network ls -q --filter label=project=chinook) 2>/dev/null

docker rmi $(docker images -q --filter label=project=chinook) 2>/dev/null