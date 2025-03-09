#!/bin/bash

##
# RAG
docker build \
    -t oe-rag:local \
    -f projects/ai-rag/Dockerfile \
    projects/ai-rag \
##
filepath="./packages/lnsp-mediator/package-metadata.json"
envs=$(jq -r '.environmentVariables | to_entries | .[] | "\(.key)=\(.value)"' $filepath)

# Export each environment variable
while IFS= read -r line; do
  export "$line"
done <<< "$envs"

migrate_mongo_config_js_DIGEST="$(cat ./packages/lnsp-mediator/importer/migrate-mongo-config.js | md5sum | cut -d ' ' -f1)"
export migrate_mongo_config_js_DIGEST
package_json_DIGEST="$(cat ./packages/lnsp-mediator/importer/package.json | md5sum | cut -d ' ' -f1)"
export package_json_DIGEST

docker compose \
    -f packages/lnsp-mediator/importer/docker-compose.migrate.yml \
    build