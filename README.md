# threshold-statesync
A threshold based statesync script that will automate cosmos validator storage management.

## Installation

To prepare to install Threshold Statesync, run the following commands:

```
sudo su
git clone https://github.com/iprouteth0/threshold-statesync
cd threshold-statesync
chmod +x deploy.sh
```

Then, run the deploy.sh. The `systemd` argument can be passed to install using systemd service and timer files. Otherwise, crontab will be used to routinely run the scripts:
```
# To install with systemd files
./deploy systemd 

# To install with crontab
./deploy
```

For chains that require snapshots due to oracle files or wasm files not being obtained via statesync;

```
chmod +x deploy-snapshot.sh

# To install with systemd files
./deploy-snapshot.sh systemd

# To isntall with crontab
./deploy-snapshot.sh
```

## Usage

Depending on the installation method, either the crontab file or the `threshold-*.service` files control the script behavior. Multiple arguments can be passed to configure the script to your system settings within these files.

### Available Parameters
| Parameter            | Type   | Required | Description                                     | Default
|----------------------|--------|----------|-------------------------------------------------|---------|
| -b, --blocks         | Int    | Yes      | The number of blocks to retain (cosmprund)      | None |
| -c, --chain          | String | Yes      | The chain name (jackal, kujira, etc)            | None |
| -d, --daemon_dir     | String | Yes      | The daemon directory (eg: `/home/user/.canine`)  | None |
| -n, --daemon_name    | String | Yes      | The daemon name or full path (eg: `canined` or `/usr/local/go/bin/canined`)| None |
| -r, --rpc            | String | No       | The RPC to use as the state sync endpoint (only available if using the `threshold-statesync.sh` script)| `https://${CHAIN}-rpc.polkachu.com:443` |
| -s, --service_file   | String | Yes      | The service file that controls the daemon (eg: `cosmovisor.service`, `canined.service`, etc.)| `cosmovisor.service` |
| -t, --threshold      | String | No       | The % threshold full to run the statesync/snapshot at (eg: 75)| `75` |
| -u, --user           | String | Yes      | The user that runs the daemon service (eg: cosmovisor)| None |
| -v, --volume         | String | Yes      | The device with the chain data (eg: `/dev/sda3`) | None |

### Example systemd configuration

`/etc/systemd/system/threshold-statesync.service`

```
[Unit]
Description=Threshold Statesync Service

[Service]
Type=simple
User=root
ExecStart=/root/threshold-statesync.sh \
            -c jackal \
            -d /home/cosmovisor/.canine/ \
            -n canined \
            -r "https://jackal-rpc.polkachu.com:443" \
            -s cosmovisor.service \
            -t 75 \
            -u cosmovisor \
            -v /dev/sda3

[Install]
WantedBy=default.target
```

### Example crontab configuration

```
0 * * * * /bin/bash -c "./threshold-statesync-jackal.sh -c jackal -d /home/cosmovisor/.canine/ -n canined -r 'https://jackal-rpc.polkachu.com:443' -s cosmovisor.service -t 75 -u cosmovisor -v /dev/sda3" >> ./threshold.log 2>&1
