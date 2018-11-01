#!/bin/bash
. ./func
rm -f if_temp
Stop_Mon
#[ -f /etc/init.d/network-manager ] && service network-manager start
systemctl start  NetworkManager.service
