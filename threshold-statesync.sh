#! /bin/bash -x
## Script for automating statesync of cosmos nodes based on free space threshold

## this line may need to be altered on some systems to properly output the current
## usage.  Most often the "-f" integer in the cut command just needs to be adjusted
## until the currently used percentage of "/" is the only output.  
## 
## The other adjustable component is the threshold integer, which is 75 in this example.
## this means that the script will trigger the unsafe-reset and statesync if 76% storage is 
## used.
##
## also, this script was written with a self hosted unbuntu server installation in mind
## where LVM is used by default.  If you are using a cloud VPS, then you may need to alter 
## the grep string from mapper to something like vda1 for use with Digital Ocean VPS for 
## example.

make_opts() {
    # getopt boilerplate for argument parsing
    local _OPTS=$(getopt -o c:s:n:d:t:v:u:r:h --long chain:,service_file:,daemon_name:,daemon_dir:,threshold:,volume:,user:rpc:,help \
            -n 'Treshold Statesync' -- "$@")
    [[ $? != 0 ]] && { echo "Terminating..." >&2; exit 51; }
    eval set -- "${_OPTS}"
}

parse_args() {
  while true; do
  case "$1" in
      -c | --chain ) CHAIN="$2"; shift 2 ;;
      -d | --daemon_dir ) DAEMON_DIR="$2"; shift 2 ;;
      -n | --daemon_name ) DAEMON_NAME="$2"; shift 2 ;;
      -r | --rpc ) RPC="$2"; shift 2 ;;
      -s | --service_file ) SERVICE_FILE="$2"; shift 2 ;;
      -t | --threshold ) THRESHOLD="$2"; shift 2 ;;
      -u | --user ) USER="$2"; shift 2 ;;
      -v | --volume ) VOLUME="$2"; shift 2 ;;
      -h | --help ) HELP_MENU="True"; shift ;;
      -- ) shift; break ;;
      * ) break ;;
  esac
  done

  if [[ -z $SERVICE_FILE ]]; then
    SERVICE_FILE="cosmovisor.service"
  fi

  if [[ -z $THRESHOLD ]]; then
    THRESHOLD=75
  fi

  if [[ -z $DAEMON_NAME || -z $DAEMON_DIR || -z $CHAIN || -z $VOLUME || -z $USER ]]; then
      printf "\
      ${SCRIPT_NAME}: Error - Missing Arguments
      The following arguments are required:
          -n, --daemon_name
          -d, --daemon_dir
          -c, --chain
          -v, --volume
          -u, --user
      "
  fi
}
run_state_sync() {
  #
  if [[ $(df -h | grep $VOLUME | awk '{print $5}' | cut -d'%' -f 1) -gt $THRESHOLD ]]; then
    # get users's home directory
    user_dir=$(eval echo "~${USER}")

    ## terminal message to user
    echo "stopping blockchain daemon and performing unsafe-reset-all // state-sync"
    
    ## import .profile to ensure binary can be executed by root
    systemctl stop $SERVICE_FILE
    
    ## backup validator state file and privkey for satefy
    cp $DAEMON_DIR/data/priv_validator_state.json $user_dir
    cp $DAEMON_DIR/config/priv_validator_key.json $user_dir
    
    ## clear validator blockchain db while keeping address book
    $DAEMON_NAME tendermint unsafe-reset-all --home $DAEMON_DIR --keep-addr-book || \
    $DAEMON_NAME unsafe-reset-all --home $DAEMON_DIR --keep-addr-book
    
    ## update statesync details in config file by running statesync script
    if [[ -z $RPC ]]; then
      ./statesync.sh -c $CHAIN -d $DAEMON_DIR
    else
      ./statesync.sh -c $CHAIN -d $DAEMON_DIR -r $RPC
    fi
    
    ## update ownership after running things as root 
    chown -R $USER:$USER $user_dir
  
    ## restart blockchain daemon
    sudo systemctl start $SERVICE_FILE
  else
    ## terminal message to user
    echo "free space level is acceptable"
  fi
}

# Main:
make_opts
parse_args "${@}"
run_state_sync
exit "${?}"
