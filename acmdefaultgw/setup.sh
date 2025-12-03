#!/bin/bash
#

ip addr add 10.6.135.254/24 dev eth1

# set the default gw via eth1
ip r del default
sleep infinity
