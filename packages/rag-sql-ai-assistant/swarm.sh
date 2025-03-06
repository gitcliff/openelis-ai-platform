#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="rag-sql-ai-assistant"

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly STACK
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  # local dev_compose_filename=""

  # TODO: Implement dev mode
  if [ "${MODE}" == "dev" ]; then
    log info "Running package in DEV mode - TODO"
  else
    log info "Running package in PROD mode"
  fi

  if [ "${CLUSTERED_MODE}" == "true" ]; then
    log warn "Clustered mode not implemented yet"
  fi

  (

    # docker::await_service_status "postgres" "postgres-1" "Running"

    if [[ "${ACTION}" == "init" ]]; then
      log info "Package configuration not implemented"
      # docker::deploy_config_importer "postgres" "$COMPOSE_FILE_PATH/importer/docker-compose.config.yml" "hapi_db_config" "hapi-fhir"
    fi

    # Similar to docker compose up - but for docker swarm using the helpers. 
    docker::deploy_service "$STACK" "${COMPOSE_FILE_PATH}" "docker-compose.yml"
  ) ||
    {
      log error "Failed to deploy package"
      exit 1
    }
}

function destroy_package() {
  docker::stack_destroy "$STACK"

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    log warn "Volumes are only deleted on the host on which the command is run. Postgres volumes on other nodes are not deleted"
  fi

  docker::prune_configs "hapi-fhir"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      log info "Running package in Cluster node mode"
    else
      log info "Running package in Single node mode"
    fi

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down package"

    docker::scale_services "$STACK" 0
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
