#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2076,SC2214,SC2153,SC2207
##############################################################################
CMD_SCRIPT=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
###############################################################################

source "$CMD_SCRIPT/../../cli/array.sh" ;
source "$CMD_SCRIPT/../../cli/color.sh" ;
source "$CMD_SCRIPT/../../cli/command.sh" ;
source "$CMD_SCRIPT/../../cli/environ.sh" ;
source "$CMD_SCRIPT/../../cli/rpc/data.sh" ;
source "$CMD_SCRIPT/../../cli/rpc/post.sh" ;
source "$CMD_SCRIPT/../../cli/si-suffix.sh" ;

###############################################################################
###############################################################################

function cli_help {
    local usage ;
    usage="${BB}Usage:${NB} $(command_fqn "${0}")" ;
    usage+=" [-a|--asset-id=\${AVAX_ASSET_ID}]" ;
    usage+=" [-P|--payload=\${AVAX_PAYLOAD}]" ;
    usage+=" [-e|--encoding=\${AVAX_ENCODING-hex}]" ;
    usage+=" [-@|--to=\${AVAX_TO}]" ;
    usage+=" [-f|--from|--from-address=\${AVAX_FROM_ADDRESS_\$IDX}]*" ;
    usage+=" [-c|--change|--change-address=\${AVAX_CHANGE_ADDRESS_\$IDX}]" ;
    usage+=" [-u|--username=\${AVAX_USERNAME}]" ;
    usage+=" [-p|--password=\${AVAX_PASSWORD}]" ;
    usage+=" [-b|--blockchain-id=\${AVAX_BLOCKCHAIN_ID-X}]" ;
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
    options+=( "-a" "--asset-id=" ) ;
    options+=( "-P" "--payload=" ) ;
    options+=( "-e" "--encoding=" "--encoding=hex" ) ;
    options+=( "-@" "--to=" ) ;
    options+=( "-f" "--from=" "--from-address=" ) ;
    options+=( "-c" "--change=" "--change-address=" ) ;
    options+=( "-u" "--username=" ) ;
    options+=( "-p" "--password=" ) ;
    options+=( "-b" "--blockchain-id=" "--blockchain-id=X" "--blockchain-id=P" "--blockchain-id=C" ) ;
    options+=( "-N" "--node=" ) ;
    options+=( "-S" "--silent-rpc" ) ;
    options+=( "-V" "--verbose-rpc" ) ;
    options+=( "-Y" "--yes-run-rpc" ) ;
    options+=( "-h" "--help" ) ;
    printf '%s ' "${options[@]}" ;
}

function cli {
    local -ag AVAX_FROM_ADDRESSES=() ;
    get_from_addresses AVAX_FROM_ADDRESSES ;
    while getopts ":hSVYN:a:P:e:@:f:c:u:p:b:-:" OPT "$@"
    do
        if [ "$OPT" = "-" ] ; then
            OPT="${OPTARG%%=*}" ;
            OPTARG="${OPTARG#$OPT}" ;
            OPTARG="${OPTARG#=}" ;
        fi
        case "${OPT}" in
            list-options)
                cli_options && exit 0 ;;
            a|asset-id)
                AVAX_ASSET_ID="${OPTARG}" ;;
            P|payload)
                AVAX_PAYLOAD="${OPTARG}" ;;
            e|encoding)
                AVAX_ENCODING="${OPTARG}" ;;
            @|to)
                AVAX_TO="${OPTARG}" ;;
            f|from|from-address)
                local i; i="$(next_index AVAX_FROM_ADDRESSES)" ;
                AVAX_FROM_ADDRESSES["$i"]="${OPTARG}" ;;
            c|change|change-address)
                AVAX_CHANGE_ADDRESS="${OPTARG}" ;;
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
    if [ -z "$AVAX_ASSET_ID" ] ; then
        cli_help && exit 1 ;
    fi
    if [ -z "$AVAX_PAYLOAD" ] ; then
        cli_help && exit 1 ;
    fi
    if [ -n "$AVAX_ENCODING" ] ; then
        local -a AVAX_ENCODINGS=( "hex" ) ;
        if [[ ! " ${AVAX_ENCODINGS[*]} " =~ " ${AVAX_ENCODING} " ]]; then
            cli_help && exit 1 ;
        fi
    fi
    if [ -z "$AVAX_TO" ] ; then
        cli_help && exit 1 ;
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
        AVAX_NODE="https://api.avax.network" ;
    fi
    shift $((OPTIND-1)) ;
}

function get_from_addresses {
    environ_vars "$1" "AVAX_FROM_ADDRESS_([0-9]+)" "${!AVAX_FROM_ADDRESS_@}" ;
}

function rpc_method {
    printf "avm.mintNFT" ;
}

function rpc_params {
    printf '{' ;
    printf '"assetID":"%s",' "$AVAX_ASSET_ID" ;
    printf '"payload":"%s",' "$AVAX_PAYLOAD" ;
    if [ -n "$AVAX_ENCODING" ] ; then
        printf '"encoding":"%s",' "$AVAX_ENCODING" ;
    fi
    printf '"to":"%s",' "$AVAX_TO" ;
    if [ -n "${AVAX_FROM_ADDRESSES[*]}" ] ; then
        printf '"from":[' ; # shellcheck disable=SC2046
        join_by ',' $(map_by '"%s" ' "${AVAX_FROM_ADDRESSES[@]}") ;
        printf '],' ;
    fi
    if [ -n "$AVAX_CHANGE_ADDRESS" ] ; then
        printf '"changeAddr":"%s",' "$AVAX_CHANGE_ADDRESS" ;
    fi
    printf '"username":"%s",' "$AVAX_USERNAME" ;
    printf '"password":"%s"' "$AVAX_PASSWORD" ;
    printf '}' ;
}

###############################################################################

cli "$@" && rpc_post "$AVAX_NODE/ext/bc/$AVAX_BLOCKCHAIN_ID" "$(rpc_data)" ;

###############################################################################
###############################################################################
