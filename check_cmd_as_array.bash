#!/bin/bash

source "$( readlink -f -- "$( dirname -- "$0" )" )"'/cm_common_functions.bash'

IFS=$'\n'
out=( $(
    ls -la /
) )

for line in "${out[@]}"; do
  echo "LS: $line"
done
