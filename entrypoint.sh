#!/bin/bash -     
#title           :entrypoint.sh
#description     :This script will connect and download env configuration from Consul
#author		       :Polimatas
#date            :20221109
#version         :1.0.0  
#usage		       :sh entrypoint.sh
#==============================================================================

set -e

function main() {    
  echo "Validating required params..."
  sanitize "${INPUT_SECRET_PATHS}" "secret_paths"
  sanitize "${INPUT_VAULT_TOKEN}" "vault_token"
  sanitize "${INPUT_VAULT_ADDR}" "vault_addr"


  #########################
  # GENERATE ENV VARIABLES
  #########################
  export VAULT_ADDR="$INPUT_VAULT_ADDR"
  export VAULT_TOKEN="$INPUT_VAULT_TOKEN"

  if [ -n "${INPUT_VAULT_NAMESPACE}" ]; then
    export VAULT_NAMESPACE="$INPUT_VAULT_NAMESPACE"
  fi

  arr_base_paths=($INPUT_SECRET_PATHS)

  #########################
  # CONSUL TEMPLATE
  #########################

  for i in "${arr_base_paths[@]}"
  do
  cat <<EOT >> env.tmpl
{{ with secret "$i" }}{{ range \$k, \$v := .Data.data }}export {{ \$k | replaceAll "-" "_" | replaceAll " " "_" | toUpper }}='{{ \$v }}'
{{ end }}{{ end }}
EOT
  done
  ls -al
  consul-template -template="./env.tmpl:./${INPUT_ENV_FILENAME}" -config ./config/config.hcl -once -log-level info
  
}

function sanitize() {
  if [ -z "${1}" ]; then
    >&2 echo "Unable to find the ${2}. Did you set with.${2}?"
    exit 1
  fi
}


###Execute main
main
