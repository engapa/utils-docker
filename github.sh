#!/bin/bash -e
#
# Utility to generate a Github release and upload asset files from a local directory.
#
# Author: Enrique Garcia <engapa@gmail.com>
#
# Env parameters:
#
# * GITHUB_TOKEN (required)
# * GITHUB_OWNER (required)
# * GITHUB_REPO (required)
# * RELEASE_TAG (required)
# * RELEASE_NAME (optional, default is empty)
# * RELEASE_TARGET (optional, default is master)
# * RELEASE_BODY (optional, default empty)
# * RELEASE_DRAFT (optional, default isn't a draft)
# * RELEASE_PRERELEASE (optional, default isn't a prerelease)
# * RELEASE_DIR (optional, if not present assets won't be uploaded)
# * DEBUG (optional, show trace output if is 'true')
#
# Example:
#
# GITHUB_TOKEN=4321 RELEASE_TAG=v0.1.6 RELEASE_DIR=$(pwd)/dist ./github.sh gh-release
#
# WARN: This script requires curl and jq
#


gh-release(){

  # Required vars
  if [[ -z $GITHUB_TOKEN || -z $GITHUB_OWNER || $GITHUB_REPO || $RELEASE_TAG ]]; then
     echo 'GITHUB_TOKEN, GITHUB_OWNER, GITHUB_REPO and RELEASE_TAG env variables are required.' && exit 1;
  fi

  # Optional vars
  RELEASE_TARGET=${RELEASE_TARGET:-master}
  RELEASE_NAME=${RELEASE_NAME:-''}
  RELEASE_BODY=${RELEASE_BODY:-''}
  RELEASE_DRAFT=${RELEASE_DRAFT:-false}
  RELEASE_PRERELEASE=${RELEASE_PRERELEASE:-false}
  RELEASE_DIR=${RELEASE_DIR:-''}

  GITHUB_AUTH_TOKEN="Authorization: token ${GITHUB_TOKEN}"

  RELEASE_DATA=$(cat << EOF
{
  "name": "${RELEASE_NAME}",
  "tag_name": "${RELEASE_TAG}",
  "target_commitish": "${RELEASE_TARGET}",
  "body": "${RELEASE_BODY}",
  "draft": ${RELEASE_DRAFT},
  "prerelease": ${RELEASE_PRERELEASE}
}
EOF
)

  RELEASE_RES=`curl -X POST \
    -H "${GITHUB_AUTH_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${RELEASE_DATA}" \
    https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases`

  RELEASE_ID=$(echo $RELEASE_RES | jq '.id')

  [[ "$RELEASE_ID" && "$RELEASE_ID" != 'null' ]] || (echo "Invalid release id " && exit 1)

  if [[ "$RELEASE_DIR" && -d $RELEASE_DIR ]]; then
    for FILE in $RELEASE_DIR/*; do
      ASSET_URL="https://uploads.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/releases/${RELEASE_ID}/assets?name=$(basename $FILE)"
      echo "Uploading asset: ${FILE}"
      curl -X PUT -H "$GITHUB_AUTH_TOKEN" --data-binary @"$FILE" -H "Content-Type: application/octet-stream" $ASSET_URL
    done
  else
    echo "Not found directory ${RELEASE_DIR}" && exit 1
  fi
}