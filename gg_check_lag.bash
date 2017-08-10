[#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <SID>" >/dev/stderr
    exit 1
fi

#. /home/goldengate/$ORACLE_SID
export ORACLE_SID=$1
. ~/$ORACLE_SID

export IGNORE_PROCESS_LIST='/orashare/scripts/scripts_master/ggAlert.prm'
export IGNORE_PROCESS=`cat $IGNORE_PROCESS_LIST|grep $ORACLE_SID|awk '{print $3}'`

export ENTRIES=`echo 'info all'|./ggsci`
# Limit to only entries which are RUNNING and are of the appropriate type
ENTRIES=`echo "${ENTRIES}"|grep RUNNING|egrep 'EXTRACT|PUMP|REPLICAT'`
# Limit to entries which are not on the ignore process list
ENTRIES=`echo "${ENTRIES}"|grep -v $IGNORE_PROCESS`
echo -n "$ENTRIES"

export LAG_ERR=''
for lag_entry in $ENTRIES; do
    export lag_group=`echo "$lag_entry" | awk '{print $3}'`
    export lag_time=`echo "$lag_entry" | awk '{print $4}'`
    if [ $lag_time != '00:00:00' ]; then
        LAG_ERR="${LAG_ERR}\n$lag_group on $ORACLE_SID is behind by $lag_time\n"
    fi
done
LAG_ERR=`echo "{$LAG_ERR}"|grep -v '^$'` # Remove blank lines from $LAG_ERR

if [ $LAG_ERR != '' ]; then
    echo "${LAG_ERR}" >/dev/stderr
    exit 2
fi
