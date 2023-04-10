#! /bin/bash

if [[ $1 == "systemd" || $1 == "systemctl" ]]; then
    cp threshold-cosmprund.sh /root/
    chmod +x /root/threshold-cosmprund.sh
    cp threshold-cosmprund.service /etc/systemd/system/
    cp threshold-cosmprund.timer /etc/systemd/system/
    systemctl enable threshold-cosmprund.timer
    systemctl start threshold-cosmprund.timer
else
    cp threshold-*.sh /root/
    crontab -l > /root/crontab.tmp
    cat crontab.example.cosmprund >> /root/crontab.tmp
    crontab crontab.tmp
fi
