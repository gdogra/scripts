#!/bin/bash

# Todo: move the file referenced in IGNORE_PROCESS_LIST into git
IGNORE_PROCESS_LIST='/orashare/scripts/scripts_master/ggAlert.prm'
LAG_CHECK_RETRIES=12
LAG_CHECK_DELAY=5

# Find out where what dir this script is from and import common functions
source "$( readlink -f -- "$( dirname -- "$0" )" )"'/cm_common_functions.bash'

# If present, remove -d or --debug as first argument and set CM_DEBUG
if [[ "$1" =~ ^\-+d(ebug)?$ ]]; then CM_DEBUG=1; shift; fi

# Make sure we have one parameter, the SID to run against
if [[ $# -ne 1 && ! "$1" =~ ^[A-Z0-9]+$ ]]; then
  echo "Usage: $0 [--debug] <SID>" >&2
  exit 1
fi
export ORACLE_SID=$1

# Todo: migrate contents of  /home/goldengate/$ORACLE_SID into git
. ~/$ORACLE_SID # Runs /home/goldengate/$ORACLE_SID
[[ $? != 0 ]] && die 2 "Failure when running ~/$ORACLE_SID"

echo "Waiting for lag to be zero on $ORACLE_SID"

ignore_processes=$(
  cat $IGNORE_PROCESS_LIST \
  | grep $ORACLE_SID \
  | awk '{print $3}'
)

cd $GG_HOME # This has been set by running ~/$ORACLE_SID above
# Todo: load ggsci command into git?
gg_output=$(echo 'info all' | ./ggsci) # Run the gg command, save output
debug "GG command output:" "$gg_output"

IFS=$'\n'
# Load the relevant rows of the info all command into the entries array
entries=( $(
    echo "$gg_output" |
    grep RUNNING |                  # Only running entried
    egrep 'EXTRACT|PUMP|REPLICAT' | # Only entries of the right tyep
    grep -v $ignore_processes       # Only entries we do not ignore
) )
debug "Relevant Entries:" "${entries[@]}"

# Check that the array is populated, if not then fail
[[ ${entries[@]} -eq 0 ]] && die 3 "No entries detected in gg 'info all' list!"

check_lag() {
  echo "Checking lag for $ORACLE_SID"
  local lag_err=()
  for lag_entry in $entries; do
    local lag_group=$(echo "$lag_entry" | awk '{print $3}')
    local lag_time=$(echo "$lag_entry" | awk '{print $4}')
    if [[ "$lag_time" != '00:00:00' ]]; then
      lag_err+=("$lag_group on $ORACLE_SID is behind by $lag_time")
    fi
  done
  if [[ ${#lag_err[@]} -ne 0 ]]; then
    echo "No lag on $ORACLE_SID"
  else 
    warn "${lag_err[@]}"
  fi
  return ${#lag_err[@]} # Return the number of entries lagged, will be zero on success
}

retry $LAG_CHECK_RETRIES \
  $LAG_CHECK_DELAY \
  254 \
  "$ORACLE_SID still lagged after $LAG_CHECK_RETRIES tries" \
  'check_lag'
