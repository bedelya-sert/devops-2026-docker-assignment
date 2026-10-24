#!/bin/sh

docker rm -f -v mcp-gateway postgres-db 2>/dev/null

docker network rm chinook-net 2>/dev/null

docker rmi chinook-seeder:latest agentc:latest 2>/dev/null