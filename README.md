# threshold-statesync
A threshold based statesync script that will automate cosmos validator storage management.

To use statesync version;

```
sudo su
git clone https://github.com/iprouteth0/threshold-statesync
cd threshold-statesync
chmod +x deploy.sh
./deploy.sh
```

For chains that require snapshots due to oracle files or wasm files not being obtained via statesync;

```
sudo su
git clone https://github.com/iprouteth0/threshold-statesync
cd threshold-statesync
chmod +x deploy-snapshot.sh
./deploy-snapshot.sh
```

the line 
```
if [ $(df -h | grep mapper | cut -d' ' -f 12 | cut -d'%' -f 1) -gt 75 ] ;
```
that is in each version of the script will need to be slightly modified for different cloud providers.

The existing line in the script is meant for self-hosted ubuntu server installs with LVM enabled (default setting).

To use the scripts with Digial Ocean for instance, the subshell part of the line might look closer to this;
```
$(df -h | grep "vda1 " | cut -d' ' -f 17 | cut -d'%' -f 1 )
```

