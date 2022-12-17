#! /bin/bash

cp threshold-*-jackal.sh /root/
crontab -l > /root/crontab.tmp
cat crontab.example.snapshot >> /root/crontab.tmp
crontab crontab.tmp
