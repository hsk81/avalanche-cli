#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2214
###############################################################################
CMD_SCRIPT=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
###############################################################################

source "$CMD_SCRIPT/../../cli/color.sh" ;
source "$CMD_SCRIPT/../../cli/command.sh" ;
source "$CMD_SCRIPT/../../cli/rpc/data.sh" ;
source "$CMD_SCRIPT/../../cli/rpc/post.sh" ;

###############################################################################
###############################################################################

function cli_help {
    local usage ;
    usage="${BB}Usage:${NB} $(command_fqn "${0}")" ;
    usage+=" [-s|--subnet-id=\${AVAX_SUBNET_ID}]" ;
    usage+=" [-n|--node-id=\${AVAX_NODE_ID}]" ;
    usage+=" [-t|--start-time=\${AVAX_START_TIME}]" ;
    usage+=" [-T|--end-time=\${AVAX_END_TIME}]" ;
    usage+=" [-N|--node=\${AVAX_NODE-https://api.avax.network}]" ;
    usage+=" [-S|--silent-rpc|\${AVAX_SILENT_RPC}]" ;
    usage+=" [-V|--verbose-rpc|\${AVAX_VERBOSE_RPC}]" ;
    usage+=" [-Y|--yes-run-rpc|\${AVAX_YES_RUN_RPC}]" ;
    usage+=" [-h|--help]" ;
    source "$CMD_SCRIPT/../../cli/help.sh" ; # shellcheck disable=2046
    printf '%s\n\n%s\n' "$usage" "$(help_for $(command_fqn "${0}"))" ;
}

function cli_options {
    local -a options ;
    options+=( "-s" "--subnet-id=" ) ;
    options+=( "-n" "--node-id=" ) ;
    options+=( "-t" "--start-time=" ) ;
    options+=( "-T" "--end-time=" ) ;
    options+=( "-N" "--node=" ) ;
    options+=( "-S" "--silent-rpc" ) ;
    options+=( "-V" "--verbose-rpc" ) ;
    options+=( "-Y" "--yes-run-rpc" ) ;
    options+=( "-h" "--help" ) ;
    printf '%s ' "${options[@]}" ;
}

function cli {
    while getopts ":hSVYN:s:n:t:T:-:" OPT "$@"
    do
        if [ "$OPT" = "-" ] ; then
            OPT="${OPTARG%%=*}" ;
            OPTARG="${OPTARG#$OPT}" ;
            OPTARG="${OPTARG#=}" ;
        fi
        case "${OPT}" in
            list-options)
                cli_options && exit 0 ;;
            s|subnet-id)
                AVAX_SUBNET_ID="${OPTARG}" ;;
            n|node-id)
                AVAX_NODE_ID="${OPTARG}" ;;
            t|start-time)
                AVAX_START_TIME="${OPTARG}" ;;
            T|end-time)
                AVAX_END_TIME="${OPTARG}" ;;
            N|node)
                AVAX_NODE="${OPTARG}" ;;
            S|silent-rpc)
                export AVAX_SILENT_RPC=1 ;;
            V|verbose-rpc)
                export AVAX_VERBOSE_RPC=1 ;;
            Y|yes-run-rpc)
                export AVAX_YES_RUN_RPC=1 ;;
            h|help)
                cli_help && exit 0 ;;
            :|*)
                cli_help && exit 1 ;;
        esac
    done
    if [ -z "$AVAX_SUBNET_ID" ] ; then
        cli_help && exit 1 ;
    fi
    if [ -z "$AVAX_NODE_ID" ] ; then
        cli_help && exit 1 ;
    fi
    if [ -z "$AVAX_START_TIME" ] ; then
        cli_help && exit 1 ;
    fi
    if [ -z "$AVAX_END_TIME" ] ; then
        cli_help && exit 1 ;
    fi
    if [ -z "$AVAX_NODE" ] ; then
        AVAX_NODE="https://api.avax.network" ;
    fi
    shift $((OPTIND-1)) ;
}

function rpc_method {
    printf "platform.getMaxStakeAmount" ;
}

function rpc_params {
    printf '{' ;
    printf '"subnetID":"%s",' "$AVAX_SUBNET_ID" ;
    printf '"nodeID":"%s",' "$AVAX_NODE_ID" ;
    printf '"startTime":%s,' "$AVAX_START_TIME" ;
    printf '"endTime":%s' "$AVAX_END_TIME" ;
    printf '}' ;
}

###############################################################################

cli "$@" && rpc_post "$AVAX_NODE/ext/P" "$(rpc_data)" ;

###############################################################################
###############################################################################
