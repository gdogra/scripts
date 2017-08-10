
#!/bin/bash

if [[ $# -ne 1 ]] || [[ "$1" != 'NAV' && "$1" != 'PL' && "$1" != 'ALL' ]]; then
    echo "Usage: `basename $0` PL|NAV|ALL" >&2
    exit 1
fi

# Get a list of all instances
export instances=`ps -ef -u oracle|grep ora_lgwr_|grep -v grep|sed -e 's/^.*_//'`

# Remove ASM instances
instances=`echo "$instances"|grep -v ASM`

# If we were called with a parameter other than 'ALL' limit the results
if [[ "$1" != 'ALL' ]]; then
    instances=`echo "$instances"|grep $1`
fi

# This prevents a blank line in the case $instances is empty
if [[ "$instances" ]]; then
    echo "$instances"
fi
