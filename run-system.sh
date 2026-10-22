#!/bin/sh

set -e

export MSYS_NO_PATHCONV=1 #Prevent it from going out of LF

docker network inspect chinook-net >/dev/null 2>&1 || docker network create chinook-net
#Chinook seeder bec it's gonna take the chinook.db file
docker build --target seeder -t chinook-seeder:latest .
docker build --target agent -t agentc:latest .

#Temporary workaround for the password secret error
docker mcp secret set cockroachdb.password=pass123

docker run -d \
    --name postgres-db \
    --network chinook-net \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=pass123 \
    -e POSTGRES_DB=chinook_db \
    postgres:17

#Prevent ECONNREFUSED premature connection error
until docker exec postgres-db pg_isready -h localhost -U admin -d chinook_db >/dev/null 2>&1; do
    echo "Waiting for database..."
    sleep 1
done
echo "Database is ready"

docker run --rm \
    --name chinook-seeder \
    --network chinook-net \
    -v "$(pwd)/Chinook.db:/app/Chinook.db:ro" \
    -e SQLITE_FILE=/app/Chinook.db \
    -e DATABASE_URL=postgres://admin:pass123@postgres-db:5432/chinook_db \
    chinook-seeder:latest

docker run -d \
    --name mcp-gateway \
    --network chinook-net \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$(pwd)/mcp_config.yaml:/mcp_config.yaml:ro" \
    -v "$(pwd)/mcp_secret.env:/run/secrets/database-url:ro" \
    docker/mcp-gateway:latest \
    --transport=sse \
    --secrets=/run/secrets/database-url \
    --allow-unauthenticated \
    --servers=cockroachdb \
    --tools=execute_query \
    --config=/mcp_config.yaml

docker run --rm \
    --name agentc \
    --network chinook-net \
    -v "$(pwd)/secret.ollama-api-key:/run/secrets/openai-api-key:ro" \
    -e MCP_SERVER_URL=http://mcp-gateway:8811/sse \
    -e DATABASE_DIALECT=PostgreSQL \
    -e "QUESTION=What are the top 3 albums by sales?" \
    -e OPENAI_API_BASE_URL=https://ollama.com/v1 \
    -e OPENAI_MODEL_NAME=gpt-oss:20b \
    agentc:latest
