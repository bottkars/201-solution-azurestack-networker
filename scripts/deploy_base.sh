#!/bin/bash
cp *.sh /root
echo "forking to configure-nve-azs.sh, monitor install.log for root or AVIGUI"
su root -c "nohup /root/configure-nve-azs.sh >/dev/null 2>&1 &"