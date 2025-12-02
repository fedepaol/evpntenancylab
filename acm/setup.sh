#!/bin/bash
#

ip addr add 10.6.135.44/24 dev eth1

# set the default gw via eth1
ip r del default
ip r add default via 10.6.135.254 dev eth1
sleep infinity
