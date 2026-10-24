#!/bin/sh

docker rm -f $(docker ps -aq --filter label=project=chinook) 2>/dev/null

docker network rm chinook-net 2>/dev/null

docker rmi chinook-seeder:latest agentc:latest 2>/dev/null