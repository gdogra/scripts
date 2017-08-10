#!/bin/bash

# Todo: migrate into a common library
# If the CM_DEBUG variable is set to a non-zero value, it will
# output all passed-in parameters to STDOUT
debug() {
  [[ "$CM_DEBUG" -eq 0 ]] && return 0
  for var in "$@"; do
    echo "$var"
  done
}

# Todo: migrate into a common library
# Prints all passed-in parameters as warnings to STDERR
warn() {
  for var in "$@"; do
    echo "WARNING: $var" >&2
  done
}

# Todo: migrate into a common library
# Exits the program with a message
# First parameter, if it is a number, is treated as an exit code
# Remaining parameters will be output as error messages to STDERR
die() {
  local exit_code=1
  if [[ "$1" =~ ^[0-9]+$  ]]; then
    exit_code=$1
    shift
  fi
  for var in "$@"; do
    echo "ERROR: $var" >&2
  done
  exit "$exit_code"
}

cmd_as_array() {
  local out=$($@)
  local array=()
  local IFS=$'\n'
  echo "$out" | while read -r line; do
    echo "LINE: $line"
    array+="$line"
  done
  "${array[@]}"
}

# Attempts to run a command/fucntion until it returns a non-zero exit
retry() {
  local retries="$1";   shift # Number of times to re-attempt
  local delay="$1";     shift # Amount of seconds to wait between tries
  local exit_code="$1"; shift # Exit code if unable to get a success
  local error="$1";     shift # Error to report if unable to succeed
  local retry_num=0
  while [[ $retry_num -lt $retries ]]; do
    let "retry_num++"
    "$@"
    if [[ $? -eq 0 ]]; then return 0; fi
    sleep $delay
    echo "Retry number $retry_num of $retries..."
  done
  die $exit_code "$error"
}
