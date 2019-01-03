#!/bin/bash -e

[ "${DEBUG:-false}" == 'true' ] && set -x

DIR=$(dirname "$0")

for file in `ls | grep -e ".sh"`; do
  if [[ "$DIR/$file" != "$0" ]]; then
    . $DIR/$file
  fi
done

help() # Show a list of functions
{
    echo "Type one of the following commands:"
    for command in $(declare -F -p | cut -d " " -f 3);do
      echo " - $command"
    done
}

if [ "_$1" = "_" ]; then
    help
else
    "$@"
fi
