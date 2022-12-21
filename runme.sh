#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if test -f terraform/backend.tf; then
  pushd "${SCRIPT_DIR}/terraform" && terraform init && terraform ${@:-plan}
  popd
else
  bash "${SCRIPT_DIR}/scripts/setup-backend.aws.sh"
fi
