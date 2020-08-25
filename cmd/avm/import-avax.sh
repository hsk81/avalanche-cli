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
    usage+=" [-@|--to=\${AVAX_TO}]" ;
    usage+=" [-s|--source-chain=\${AVAX_SOURCE_CHAIN-P}]" ;
    usage+=" [-u|--username=\${AVAX_USERNAME}]" ;
    usage+=" [-p|--password=\${AVAX_PASSWORD}]" ;
    usage+=" [-b|--blockchain-id=\${AVAX_BLOCKCHAIN_ID-X}]" ;
    usage+=" [-N|--node=\${AVAX_NODE-127.0.0.1:9650}]" ;
    usage+=" [-S|--silent-rpc|\${AVAX_SILENT_RPC}]" ;
    usage+=" [-V|--verbose-rpc|\${AVAX_VERBOSE_RPC}]" ;
    usage+=" [-Y|--yes-run-rpc|\${AVAX_YES_RUN_RPC}]" ;
    usage+=" [-h|--help]" ;
    source "$CMD_SCRIPT/../../cli/help.sh" ; # shellcheck disable=2046
    printf '%s\n\n%s\n' "$usage" "$(help_for $(command_fqn "${0}"))" ;
}

function cli_options {
    local -a options ;
    options+=( "-@" "--to=" ) ;
    options+=( "-s" "--source-chain=" ) ;
    options+=( "-u" "--username=" ) ;
    options+=( "-p" "--password=" ) ;
    options+=( "-b" "--blockchain-id=" ) ;
    options+=( "-N" "--node=" ) ;
    options+=( "-S" "--silent-rpc" ) ;
    options+=( "-V" "--verbose-rpc" ) ;
    options+=( "-Y" "--yes-run-rpc" ) ;
    options+=( "-h" "--help" ) ;
    printf '%s ' "${options[@]}" ;
}

function cli {
    while getopts ":hSVYN:@:s:u:p:b:-:" OPT "$@"
    do
        if [ "$OPT" = "-" ] ; then
            OPT="${OPTARG%%=*}" ;
            OPTARG="${OPTARG#$OPT}" ;
            OPTARG="${OPTARG#=}" ;
        fi
        case "${OPT}" in
            list-options)
                cli_options && exit 0 ;;
            @|to)
                AVAX_TO="${OPTARG}" ;;
            s|source-chain)
                AVAX_SOURCE_CHAIN="${OPTARG}" ;;
            u|username)
                AVAX_USERNAME="${OPTARG}" ;;
            p|password)
                AVAX_PASSWORD="${OPTARG}" ;;
            b|blockchain-id)
                AVAX_BLOCKCHAIN_ID="${OPTARG}" ;;
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
    if [ -z "$AVAX_TO" ] ; then
        cli_help && exit 1 ;
    fi
    if [ -z "$AVAX_SOURCE_CHAIN" ] ; then
        AVAX_SOURCE_CHAIN="P" ;
    fi
    if [ -z "$AVAX_USERNAME" ] ; then
        cli_help && exit 1 ;
    fi
    if [ -z "$AVAX_PASSWORD" ] ; then
        cli_help && exit 1 ;
    fi
    if [ -z "$AVAX_BLOCKCHAIN_ID" ] ; then
        AVAX_BLOCKCHAIN_ID="X" ;
    fi
    if [ -z "$AVAX_NODE" ] ; then
        AVAX_NODE="127.0.0.1:9650" ;
    fi
    shift $((OPTIND-1)) ;
}

function rpc_method {
    printf "avm.importAVAX" ;
}

function rpc_params {
    printf '{' ;
    printf '"to":"%s",' "$AVAX_TO" ;
    printf '"sourceChain":"%s",' "$AVAX_SOURCE_CHAIN" ;
    printf '"username":"%s",' "$AVAX_USERNAME" ;
    printf '"password":"%s"' "$AVAX_PASSWORD" ;
    printf '}' ;
}

###############################################################################

cli "$@" && rpc_post "$AVAX_NODE/ext/bc/$AVAX_BLOCKCHAIN_ID" "$(rpc_data)" ;

###############################################################################
###############################################################################
