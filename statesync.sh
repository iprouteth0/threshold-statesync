#!/bin/bash

make_opts() {
    # getopt boilerplate for argument parsing
    local _OPTS=$(getopt -o c:r:d: --long chain:,rpc:daemon_dir: \
            -n 'Treshold Statesync' -- "$@")
    [[ $? != 0 ]] && { echo "Terminating..." >&2; exit 51; }
    eval set -- "${_OPTS}"
}

parse_args() {
    while true; do
    case "$1" in
        -c | --chain ) CHAIN="$2"; shift 2 ;;
        -d | --daemon_dir ) DAEMON_DIR="$2"; shift 2 ;;
        -r | --rpc ) RPC="$2"; shift 2 ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
    done

    if [[ -z $DAEMON_DIR || -z $CHAIN ]]; then
        printf "\
        ${SCRIPT_NAME}: Error - Missing Arguments
        The following arguments are required:
            -c, --chain
            -d, --daemon_dir
        "
        exit 1
    fi
    if [[ -z $RPC ]]; then
      RPC="https://${CHAIN}-rpc.polkachu.com:443"
    fi
}

configure_state_sync() {
    # Ensure state sync RPC is available
    curl -s $RPC 1>/dev/null
    if [[ $? -ne 0 ]]; then
        printf "\
        Error connecting to RPC
        "
        exit 2
    fi

    LATEST_HEIGHT=$(curl -s $RPC/block | jq -r .result.block.header.height); \
    BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
    TRUST_HASH=$(curl -s "$RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

    sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
    s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC,$RPC\"| ; \
    s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
    s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $DAEMON_DIR/config/config.toml
}

# Main:
make_opts
parse_args "${@}"
configure_state_sync
exit "${?}"
