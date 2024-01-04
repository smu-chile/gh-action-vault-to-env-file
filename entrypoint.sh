#!/bin/bash -     
#title           :entrypoint.sh
#description     :This script will connect and download env configuration from Consul
#author		       :Polimatas
#date            :20221109
#version         :1.0.0  
#usage		       :sh entrypoint.sh
#==============================================================================

set -e

cd /

function main() {    
  echo "Validating required params..."
  sanitize "${INPUT_SECRET_PATHS}" "secret_paths"
  sanitize "${INPUT_VAULT_TOKEN}" "vault_token"
  sanitize "${INPUT_VAULT_ADDR}" "vault_addr"
  sanitize "${INPUT_FILE_FORMAT}" "file_format"
  sanitize "${INPUT_FILE_NAME}" "file_name"

  if [ "$INPUT_FILE_FORMAT" != "json" ] && [ "$INPUT_FILE_FORMAT" != "toJson" ] && [ "$INPUT_FILE_FORMAT" != "env" ] ; then
    echo "Must select 'env' or 'json' or 'toJson' as valid values"
    exit 1
  fi;

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

  if [ "$INPUT_FILE_FORMAT" == "env" ] ; then
  cat <<EOT >> env.tmpl
{{ with secret "$i" }}{{ range \$k, \$v := .Data.data }}export {{ \$k | replaceAll "-" "_" | replaceAll " " "_" | toUpper }}='{{ \$v }}'
{{ end }}{{ end }}
EOT
  fi

  if [ "$INPUT_FILE_FORMAT" == "toJson" ] ; then
  cat <<EOT >> env.tmpl
{{ with secret "$i" }}{{ range \$k, \$v := .Data.data }}{{ \$k }}={{ \$v }}
{{ end }}{{ end }}
EOT
  fi;

  if [ "$INPUT_FILE_FORMAT" == "json" ] ; then
  cat <<EOT >> env.tmpl
{{ with secret "$i" }}{{ range \$k, \$v := .Data.data }}{{ \$v }}
{{ end }}{{ end }}
EOT
  fi;
  done
  consul-template -template="./env.tmpl:./github/workflow/${INPUT_FILE_NAME}" -config ./config/config.hcl -once -log-level info
  

  if [ "$INPUT_FILE_FORMAT" == "toJson" ] ; then
    a=$(jq -Rn '[inputs | capture("(?<key>[^=]+)=(?<value>.*)") | { (.key): .value }] | add' ./github/workflow/${INPUT_FILE_NAME}) 
    echo $a > ./github/workflow/${INPUT_FILE_NAME}
  fi
}

function sanitize() {
  if [ -z "${1}" ]; then
    >&2 echo "Unable to find the ${2}. Did you set with.${2}?"
    exit 1
  fi
}


###Execute main
main
