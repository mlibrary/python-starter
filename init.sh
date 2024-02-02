#!/usr/bin/env bash

echo "🚢 Build docker images"
docker compose build

echo "📦 Starting python app"
docker compose up -d app