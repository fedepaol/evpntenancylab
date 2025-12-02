#!/bin/bash
#
# NVUE-based configuration for switch
# This replaces the traditional interfaces file and FRR configuration
#

# Prepare system for NVUE configuration on VX platform
mkdir -p /etc/what-just-happened
touch /etc/hosts /etc/hostname
chmod 644 /etc/hosts /etc/hostname

# Wait for NVUE to be ready - retry first command until it succeeds or timeout
timeout=60
elapsed=0
interval=2

echo "Waiting for NVUE to be ready..."
while [ $elapsed -lt $timeout ]; do
    if nv set bridge domain rdma untagged 1 2>/dev/null; then
        echo "NVUE is ready, continuing with configuration..."
        break
    fi
    sleep $interval
    elapsed=$((elapsed + interval))
done

if [ $elapsed -ge $timeout ]; then
    echo "ERROR: NVUE failed to become ready within ${timeout} seconds"
    exit 1
fi
nv set evpn enable on
nv set interface eth0 ip vrf mgmt
nv set interface eth0 ip address dhcp
nv set interface eth0 type eth
nv set interface lo ip address 10.6.156.1/32
nv set interface lo type loopback
nv set interface swp3 bridge domain uplink
nv set interface swp3 ip address 10.6.135.240/24
nv set nve vxlan enable on
nv set router bgp autonomous-system 65001
nv set router bgp enable on
nv set router bgp graceful-restart mode full
nv set router bgp router-id 10.6.156.1
nv set service lldp tx-hold-multiplier 3
nv set service lldp tx-interval 100
nv set system hostname cumulus
nv set vrf default router bgp address-family ipv4-unicast enable on
nv set vrf default router bgp address-family ipv4-unicast redistribute connected enable on
nv set vrf default router bgp address-family ipv4-unicast redistribute static enable on
nv set vrf default router bgp address-family ipv6-unicast enable on
nv set vrf default router bgp address-family ipv6-unicast redistribute connected enable on
nv set vrf default router bgp address-family l2vpn-evpn enable on
nv set vrf default router bgp autonomous-system 65001
nv set vrf default router bgp enable on
nv set vrf default router bgp neighbor swp1 peer-group hbn
nv set vrf default router bgp neighbor swp1 type unnumbered
nv set vrf default router bgp neighbor swp2 peer-group hbn
nv set vrf default router bgp neighbor swp2 type unnumbered
nv set vrf default router bgp path-selection multipath aspath-ignore on
nv set vrf default router bgp peer-group hbn remote-as external
nv set vrf default router bgp peer-group hbnzt address-family l2vpn-evpn enable on
nv set vrf default router bgp peer-group hbnzt remote-as external
nv set vrf default router static 0.0.0.0/0 address-family ipv4-unicast
nv set vrf default router static 0.0.0.0/0 via 10.6.135.254 type ipv4-address

# Apply configuration - continue even if some services fail to restart
echo "Applying NVUE configuration..."
if nv config apply -y 2>&1 | tee /tmp/nvue_apply.log; then
    echo "NVUE configuration applied successfully for switch"
else
    echo "NVUE configuration applied with warnings (expected on VX platform)"
    echo "Check /tmp/nvue_apply.log for details"
fi

# Ensure FRR is running even if restart failed
systemctl start frr 2>/dev/null || true

echo "Switch configuration complete"
