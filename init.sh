#!/usr/bin/env bash

# We could add the environment variable to the docker compose file
#ENVIRONMENT=$1
#docker compose build --build-arg ENVIRONMENT="$ENVIRONMENT"

echo "🚢 Build docker images"
DOCKER_BUILDKIT=1 docker build --target=runtime .

echo "📦 Starting python app"
docker compose up -d app