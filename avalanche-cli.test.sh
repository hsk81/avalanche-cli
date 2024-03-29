#!/usr/bin/env bash
###############################################################################
CLI_TEST_SCRIPT=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
###############################################################################

function _shunit2 {
    local shunit2_system ;
    shunit2_system="$(command -v shunit2)" ;
    if [[ -x "$shunit2_system" ]] ; then
        printf '%s' "$shunit2_system" ; return
    fi
    local shunit2_travis ;
    shunit2_travis="$CLI_TEST_SCRIPT/shunit2-2.1.8/shunit2" ;
    if [[ -x "$shunit2_travis" ]] ; then
        printf '%s' "$shunit2_travis" ; return
    fi
    exit 1 ;
}

function run {
    if [[ -z "$_SHUNIT2" ]] ; then
        _SHUNIT2="$(_shunit2)" ;
    fi
    "$_SHUNIT2" "$1" ;
}

###############################################################################

if [ -z "${1}" ] ; then
    for script in $(find "$CLI_TEST_SCRIPT/cli" -name '*.test.sh' | sort) ; do
        run "$script" ;
    done
    for script in $(find "$CLI_TEST_SCRIPT/cmd" -name '*.test.sh' | sort) ; do
        AVAX_ARGS_RPC="" \
        AVAX_DEBUG_RPC=1 \
        AVAX_NODE="" \
        AVAX_PIPE_RPC="" \
        AVAX_SILENT_RPC="" \
        AVAX_SUBNET_ID="" \
            run "$script" ;
    done
else
    for script in $(find "$CLI_TEST_SCRIPT/${1}" -name '*.test.sh' | sort) ; do
        AVAX_ARGS_RPC="" \
        AVAX_DEBUG_RPC=1 \
        AVAX_PIPE_RPC="" \
        AVAX_NODE="" \
        AVAX_SILENT_RPC="" \
        AVAX_SUBNET_ID="" \
            run "$script" ;
    done
fi

###############################################################################
###############################################################################
