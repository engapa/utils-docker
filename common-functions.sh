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
  DEBUG=${8:-${DEBUG:-false}}                 # Activate debug mode

  if $DEBUG =~true; then
    echo -e "Writing environment variables to file :\n"
    echo "PREFIX           : ${PREFIX}"
    echo "DEST_FILE        : ${DEST_FILE}"
    echo "EXCLUSIONS       : ${EXCLUSIONS}"
    echo "CREATE_FILE      : ${CREATE_FILE}"
    echo "OVERRIDE         : ${OVERRIDE}"
    echo "FROM_SEPARATOR   : ${FROM_SEPARATOR}"
    echo "TO_SEPARATOR     : ${TO_SEPARATOR}"
    echo -e ".......................................\n"
    set -u
    set -o pipefail xtrace
  fi

  if [[ -z "${PREFIX}" || -z "${DEST_FILE}" ]]; then
    echo 'PREFIX and DEST_FILE are required values :-(' && exit 1;
  fi

  if $CREATE_FILE =~ true && [ ! -f $DEST_FILE ]; then
    >>$DEST_FILE
  fi

  for ENV_VAR in `env | grep "^${PREFIX}"`; do

    ENV_VAR_NAME=`echo "${ENV_VAR}" | sed -r "s/=(.*)//"`

    if [ ! -z "${EXCLUSIONS}" ] && `echo "${ENV_VAR_NAME}" | egrep -q "${EXCLUSIONS}"`; then
      $DEBUG =~ true && echo "[EXCLUDED] : ${ENV_VAR_NAME}"
      continue
    fi

    VAR_NAME=`echo "${ENV_VAR_NAME}" | sed -r "s/${PREFIX}//" | tr '[:upper:]' '[:lower:]' | tr ${FROM_SEPARATOR} ${TO_SEPARATOR}`
    VAR_VALUE=`echo "${ENV_VAR}" | sed -r "s/.*=//"`

    if `egrep -q "(^|^#)${VAR_NAME}=.*" ${DEST_FILE}`; then
      # Not use '+' symbol neither in VAR_NAME nor in VAR_VALUE
      $OVERRIDE =~ true && sed -r -i "s+(^|^#)${VAR_NAME}=.*+${VAR_NAME}=${VAR_VALUE}+g" ${DEST_FILE} \
        && $DEBUG =~ true && echo "[OVERRIDE] : ${ENV_VAR_NAME} --> ${VAR_NAME}=${VAR_VALUE}"
      $OVERRIDE =~ false && sed -r -i "s+^#${VAR_NAME}=.*+${VAR_NAME}=${VAR_VALUE}+g" ${DEST_FILE} \
        && $DEBUG =~ true && echo "[ UPDATE ] : ${ENV_VAR_NAME} --> ${VAR_NAME}=${VAR_VALUE}"
    else
      # If VAR name not found in file, insert it at end of file
      echo "${VAR_NAME}=${VAR_VALUE}" >> ${DEST_FILE}
      $DEBUG =~ true && echo "[  ADD   ] : ${ENV_VAR_NAME} --> ${VAR_NAME}=${VAR_VALUE}"
    fi
  done

}
