#! /bin/bash
## Script for automating statesync of cosmos nodes based on free space threshold

## this line may need to be altered on some systems to properly output the current
## usage.  Most often the "-f" integer in the cut command just needs to be adjusted
## until the currently used percentage of "/" is the only output.  
## 
## The other adjustable component is the threshold integer, which is 75 in this example.
## this means that the script will trigger the unsafe-reset and statesync if 76% storage is 
## used.
if [ $(df -h | grep mapper | cut -d' ' -f 12 | cut -d'%' -f 1) -gt 75 ] ; 

then

  ## terminal message to user
  echo "stopping blockchain daemon and performing unsafe-reset-all // state-sync"
  
  ## import .profile to ensure binary can be executed by root
  systemctl stop canined
  
  ## backup validator state file for satefy
  cp /home/cosmovisor/.canine/data/priv_validator_state.json /home/cosmovisor/
  
  ## clear validator blockchain db while keeping address book
  canined tendermint unsafe-reset-all --home /home/cosmovisor/.canined --keep-addr-book
  
  ## update statesync details in config file by running statesync script
  eval $(curl -s https://polkachu.com/tendermint_snapshots/chihuahua | grep curl | html2text )
  
  ## update ownership after running things as root 
  chown -R cosmovisor:cosmovisor /home/cosmovisor
 
  ## restart blockchain daemon
  sudo systemctl start canined

else
  ## terminal message to user
  echo "free space level is acceptable"
fi
