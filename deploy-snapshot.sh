#! /bin/bash

if [[ $1 == "systemd" || $1 == "systemctl" ]]; then
    cp threshold-statesync.sh /root/
    chmod +x /root/threshold-statesync.sh
    cp threshold-statesync.service /etc/systemd/system/
    cp threshold-statesync.timer /etc/systemd/system/
    systemctl enable threshold-statesync.timer
    systemctl start threshold-statesync.timer
else
    cp threshold-*.sh /root/
    crontab -l > /root/crontab.tmp
    cat crontab.example.snapshot >> /root/crontab.tmp
    crontab crontab.tmp
fi