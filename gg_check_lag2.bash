#!/bin/bash

if [[ "$1" =~ ^\-+d(ebug)?$ ]]; then
    export CM_DEBUG=1
    shift
fi

if [ $# -ne 1 ]; then
    echo "Usage: $0 [--debug] <SID>" >&2
    exit 1
fi

#. /home/goldengate/$ORACLE_SID
export ORACLE_SID=$1
. ~/$ORACLE_SID # Todo: migrate contents of this script into git

echo "Determining lag for $ORACLE_SID"

export IGNORE_PROCESS_LIST='/orashare/scripts/scripts_master/ggAlert.prm' # Todo: move this into git
export IGNORE_PROCESS=`cat $IGNORE_PROCESS_LIST|grep $ORACLE_SID|awk '{print $3}'`

cd $GG_HOME
export ENTRIES=`echo 'info all'|./ggsci`
[ "$CM_DEBUG" == '' ] && echo -n "$ENTRIES"
# Limit to only entries which are RUNNING and are of the appropriate type
ENTRIES=`echo "$ENTRIES"|grep RUNNING`
ENTRIES=`echo "$ENTRIES"|egrep 'EXTRACT|PUMP|REPLICAT'`
# Limit to entries which are not on the ignore process list
ENTRIES=`echo "$ENTRIES"|grep -v $IGNORE_PROCESS`

if [ "$ENTRIES" == '' ]; then
    echo
    echo "No entries detected in GG list!" >&2
    exit 2
fi

if [ "$CM_DEBUG" == '' ]; then
    echo "Relevant entries:"
    echo "$ENTRIES"
    echo
fi

export LAG_ERR=''
IFS=$'\n'
for lag_entry in $ENTRIES; do
    export lag_group=`echo "$lag_entry" | awk '{print $3}'`
    export lag_time=`echo "$lag_entry" | awk '{print $4}'`
    if [ "$lag_time" != '00:00:00' ]; then
        if [ "$LAG_ERR" != '' ]; then LAG_ERR="$LAG_ERR"$'\n'; fi
        LAG_ERR="$LAG_ERR""$lag_group on $ORACLE_SID' is behind by $lag_time"
    fi
done

if [ "$LAG_ERR" != '' ]; then
    echo "$LAG_ERR" >&2
    exit 3
fi

echo "No lag on $ORACLE_SID"
