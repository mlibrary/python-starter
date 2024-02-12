#!/usr/bin/env bash

# We could add the environment variable to the docker compose file
#ENVIRONMENT=$1
#docker compose build --build-arg ENVIRONMENT="$ENVIRONMENT"

echo "🚢 Build docker images"
docker compose build

echo "📦 Starting python app"
docker compose up -d app