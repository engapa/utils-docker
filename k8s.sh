#!/bin/bash -e

## Util functions
## Author : Enrique Garcia <engapa@gmail.com>

name_index_domain() {
  # Gets the name, domain and index of an element in a StatefulSets or a PetSets

  HOST=${1:-`hostname -s`}
  DOMAIN=${2:-`hostname -d`}

  if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
    NAME=${BASH_REMATCH[1]}
    ORD=${BASH_REMATCH[2]}
    INDEX=$((ORD+1))
    local ARRAY=($NAME $INDEX $DOMAIN)
    return "${ARRAY[@]}"
  else
    echo "Name of host doesn't match with pattern: (.*)-([0-9]+). Consider using PetSets or StatefulSets."
    exit 1
  fi

}