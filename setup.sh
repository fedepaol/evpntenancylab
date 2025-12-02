#!/bin/bash
#


# Create and setup acmswitch bridge if it doesn't exist
if ! ip link show acmswitch &> /dev/null; then
    sudo ip link add name acmswitch type bridge
    sudo ip link set acmswitch up
    echo "Created and brought up acmswitch bridge"
else
    echo "acmswitch bridge already exists"
    sudo ip link set acmswitch up
fi

sudo clab deploy --reconfigure --topo multitenant.clab.yml
docker exec clab-evpnl3-switch /setup.sh
docker exec clab-evpnl3-dpu /setup.sh
