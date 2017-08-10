#!/bin/bash


CM_DEBUG=
debug() { [[ "$CM_DEBUG" == '' ]] && return 0; for var in "$@"; do echo "$var"; done }

debug "foo!"
