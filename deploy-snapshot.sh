#! /bin/bash

if [[ $1 == "systemd" || $1 == "systemctl" ]]; then
    cp threshold-snapshot.sh /root/
    chmod +x /root/threshold-snapshot.sh
    cp threshold-snapshot.service /etc/systemd/system/
    cp threshold-snapshot.timer /etc/systemd/system/
    systemctl enable threshold-snapshot.timer
    systemctl start threshold-snapshot.timer
else
    cp threshold-*.sh /root/
    crontab -l > /root/crontab.tmp
    cat crontab.example.snapshot >> /root/crontab.tmp
    crontab crontab.tmp
fi