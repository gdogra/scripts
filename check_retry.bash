#!/bin/bash

LAG_CHECK_RETRIES=12
LAG_CHECK_DELAY=0

# Find out where what dir this script is from and import common functions
source "$( readlink -f -- "$( dirname -- "$0" )" )"'/cm_common_functions.bash'

x=50
check_lag(){
  if [[ $x -eq 0 ]]; then return 0; fi
  let "x--"
  return 1;
}

retry "$LAG_CHECK_RETRIES" "$LAG_CHECK_DELAY" \
  254 "Still lagged after $LAG_CHECK_RETRIES tries" "check_lag"
