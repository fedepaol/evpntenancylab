#!/bin/bash
#

ip addr add 10.0.121.1/29 dev eth1
ip addr add 10.0.122.1/29 dev eth2

# set the default gw via eth1
ip r del default
ip r add default via 10.0.121.2 dev eth1
sleep INF
