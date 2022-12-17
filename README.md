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
