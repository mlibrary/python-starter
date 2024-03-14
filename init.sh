#!/usr/bin/env bash

if [ -f ".env" ]; then
  echo "🌎 .env exists. Leaving alone"
else
  echo "🌎 .env does not exist. Copying .env-example to .env"
  cp env.example .env
  YOUR_UID=`id -u`
  YOUR_GID=`id -g`
  echo "🙂 Setting your UID ($YOUR_UID) and GID ($YOUR_UID) in .env"
  sed -i -e s/YOUR_UID/$YOUR_UID/ .env
  sed -i -e s/YOUR_GID/$YOUR_GID/ .env
fi

echo "🚢 Build docker images"
docker compose build
