#!/bin/bash -e

## Util functions
## Author : Enrique Garcia <engapa@gmail.com>

# Write environment variables into a file
env_vars_in_file () {

  PREFIX=${1:-$PREFIX}                        # Example: RABBIT_ .
  DEST_FILE=${2:-$DEST_FILE}                  # Example: $HOME/conf/my.properties.
  EXCLUSIONS=${3:-$EXCLUSIONS}                # A match pattern for excluding env variables. Example: "^RABBIT_HOME_".
  CREATE_FILE=${4:-${CREATE_FILE:-true}}      # Create this file if doesn't exist. Example: $HOME/newFile.conf
  OVERRIDE=${5:-${OVERRIDE:-true}}            # Example: Override the variable in target file when it isn't in comment lines.
  FROM_SEPARATOR=${6:-${FROM_SEPARATOR:-'_'}} # Example: Locate this character for splitting, default to '_' .
  TO_SEPARATOR=${7:-${TO_SEPARATOR:-'.'}}     # Example: Convert FROM_SEPARATOR character/s into this, default to '.' .
  LOWER=${8:-${LOWER:-true}}                  # Convert to low characters RABBIT_PEPE-->pepe. If false preserve original characters RABBIT_size_isEnabled-->size.isEnabled
  DEBUG=${9:-${DEBUG:-false}}                 # Activate debug mode

  if $DEBUG ; then
    echo -e "Writing environment variables to file :\n"
    echo "PREFIX           : ${PREFIX}"
    echo "DEST_FILE        : ${DEST_FILE}"
    echo "EXCLUSIONS       : ${EXCLUSIONS}"
    echo "CREATE_FILE      : ${CREATE_FILE}"
    echo "OVERRIDE         : ${OVERRIDE}"
    echo "FROM_SEPARATOR   : ${FROM_SEPARATOR}"
    echo "TO_SEPARATOR     : ${TO_SEPARATOR}"
    echo "LOWER            : ${LOWER}"
    echo -e ".......................................\n"
    set -u
    set -o pipefail xtrace
  fi

  if [[ -z "${PREFIX}" || -z "${DEST_FILE}" ]]; then
    echo 'PREFIX and DEST_FILE are required values :-(' && exit 1;
  fi

  if [ ! -f $DEST_FILE ]; then
    $CREATE_FILE && >>$DEST_FILE
    [ ! $CREATE_FILE ] && { echo "Not found file ${DEST_FILE} :-("; exit 1; }
  fi

  for ENV_VAR in `env | grep "^${PREFIX}"`; do

    ENV_VAR_NAME=`echo "${ENV_VAR}" | sed -r "s/=(.*)//"`

    if [ ! -z "${EXCLUSIONS}" ] && `echo "${ENV_VAR_NAME}" | egrep -q "${EXCLUSIONS}"`; then
      $DEBUG && echo "[EXCLUDED] : ${ENV_VAR_NAME}"
      continue
    fi

    VAR_NAME=`echo "${ENV_VAR_NAME}" | sed -r "s/${PREFIX}//" | tr ${FROM_SEPARATOR} ${TO_SEPARATOR}`
    if $LOWER; then
      VAR_NAME=`echo "${VAR_NAME}" | tr '[:upper:]' '[:lower:]'`
    fi

    VAR_VALUE=`echo "${ENV_VAR}" | sed -r "s/.*=//"`

    if `egrep -q "(^|^#)${VAR_NAME}=.*" ${DEST_FILE}`; then
      # Not use '+' symbol neither in VAR_NAME nor in VAR_VALUE
      if $OVERRIDE; then
        sed -r -i "s+(^|^#)${VAR_NAME}=.*+${VAR_NAME}=${VAR_VALUE}+g" ${DEST_FILE} \
          && $DEBUG && echo "[OVERRIDE] : ${ENV_VAR_NAME} --> ${VAR_NAME}=${VAR_VALUE}"
      else
        sed -r -i "s+^#${VAR_NAME}=.*+${VAR_NAME}=${VAR_VALUE}+g" ${DEST_FILE} \
          && $DEBUG && echo "[ UPDATE ] : ${ENV_VAR_NAME} --> ${VAR_NAME}=${VAR_VALUE}"
      fi
    else
      # If VAR name not found in file, insert it at end of file
      echo "${VAR_NAME}=${VAR_VALUE}" >> ${DEST_FILE}
      $DEBUG && echo "[  ADD   ] : ${ENV_VAR_NAME} --> ${VAR_NAME}=${VAR_VALUE}"
    fi
  done
}
