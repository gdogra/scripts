 
#!/bin/bash

# Find out where what dir this script is from and import common functions
#export script_base="$( readlink -f -- "$( dirname -- "$0" )" )"'/..'
#source "$script_base/common/cm_common_functions.bash"

if [[ $# -ne 1 || ! "$1" ~= ^(NAV|PL|GCIM|ALL)$ ]]; then
    echo "Usage: $(basename $0) PL|NAV|GCIM|ALL" >&2
    exit 1
fi

# Get a list of all instances
export instances=$(
  ps -ef -u oracle |
  grep ora_lgwr_ |
  grep -v grep |
  sed -e 's/^.*_//'
)

# Remove ASM instances
instances=$( echo "$instances" | grep -v ASM )

# If we were called with a parameter other than 'ALL' limit the results
if [[ "$1" != 'ALL' ]]; then
    instances=$( echo "$instances" | grep "$1" )
fi

# This prevents a blank line in the case $instances is empty
if [[ "$instances" ]]; then
    echo "$instances"
fi
