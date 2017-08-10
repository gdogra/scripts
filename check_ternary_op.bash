#!/bin/bash

#export var=xxx
if [ "$var" != '' ]; then var="$var"$'\n'; fi
var="$var"'yyy'

echo "$var"

[gdogra@lvn-dbd-db82 ~]$ cat check_ternary_op.bash
#!/bin/bash

#export var=xxx
if [ "$var" != '' ]; then var="$var"$'\n'; fi
var="$var"'yyy'

echo "$var"
