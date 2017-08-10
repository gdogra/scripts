#!/bin/bash
#set -e
# Find out where what dir this script is from
script_dir="$( readlink -f -- "${0%/*}" )"
. $script_dir/cm_common_functions.bash # Import common functions

# If present, remove -d or --debug as first argument and set CM_DEBUG
if [[ "$1" =~ ^\-+d(ebug)?$ ]]; then CM_DEBUG=1; shift; fi

# Make sure we have one parameter, the SID to run against
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 [--debug] <SID>" >&2
  exit 1
fi
export ORACLE_SID=$1

# Todo: migrate contents of  /home/goldengate/$ORACLE_SID into git
. ~/$ORACLE_SID # Runs /home/goldengate/$ORACLE_SID
#[[ $? != 0 ]] && die 2 "Failure when running ~/$ORACLE_SID"

echo "Determining lag for $ORACLE_SID"

# Todo: move the file referenced in IGNORE_PROCESS_LIST into git
IGNORE_PROCESS_LIST='/orashare/scripts/scripts_master/ggAlert.prm'
ignore_processes=`
  cat $IGNORE_PROCESS_LIST \
  | grep $ORACLE_SID \
  | awk '{print $3}'
`

cd $GG_HOME # This has been set by running ~/$ORACLE_SID above
gg_output=`echo 'info all' | ./ggsci`
debug "GG command output:" "$gg_output"
entries=$(
    echo "$gg_output" |
    grep RUNNING |                  
    egrep 'EXTRACT|PUMP|REPLICAT' |
    grep -v $ignore_processes
)
debug "Relevant Entries:" "$entries"

[[ "$entries" == '' ]] && die 3 "No entries detected in gg 'info all' list!"

lag_err=()
IFS=$'\n'
for lag_entry in $entries; do
  lag_group=`echo "$lag_entry" | awk '{print $3}'`
  lag_time=`echo "$lag_entry" | awk '{print $4}'`
  if [[ "$lag_time" != '00:00:00' ]]; then
    lag_err+=("$lag_group on $ORACLE_SID is behind by $lag_time")
  fi
done

[[ ${#lag_err[@]} -ne 0 ]] && die 4 "${lag_err[@]}"

echo "No lag on $ORACLE_SID"
