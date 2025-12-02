#!/bin/bash
#
# NVUE-based configuration for DPU
#

# Wait for NVUE to be ready - retry first command until it succeeds or timeout
timeout=60
elapsed=0
interval=2

echo "Waiting for NVUE to be ready..."
while [ $elapsed -lt $timeout ]; do
    if nv set bridge domain br_default vlan 11 vni 10010 2>/dev/null; then
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
nv set bridge domain br_default vlan 21 vni 10020
nv set evpn enable on
nv set evpn route-advertise
nv set interface lo ip address 11.0.0.0/32
nv set interface lo type loopback
nv set interface swp1,swp2,swp3,swp4 link mtu 9000
nv set interface swp1,swp2,swp3,swp4 type swp
nv set interface swp3 bridge domain br_default access 11
nv set interface swp4 bridge domain br_default access 21
nv set interface vlan11 ip address 10.0.121.2/29
nv set interface vlan11 ip vrf RED
nv set interface vlan11 vlan 11
nv set interface vlan11,21 type svi
nv set interface vlan21 ip address 10.0.122.2/29
nv set interface vlan21 ip vrf BLUE
nv set interface vlan21 vlan 21
nv set nve vxlan arp-nd-suppress on
nv set nve vxlan enable on
nv set nve vxlan source address 11.0.0.0
nv set router bgp enable on
nv set router bgp graceful-restart mode full
nv set vrf BLUE evpn enable on
nv set vrf BLUE evpn vni 100002
nv set vrf BLUE loopback ip address 11.0.0.0/32
nv set vrf BLUE router bgp address-family ipv4-unicast enable on
nv set vrf BLUE router bgp address-family ipv4-unicast redistribute connected enable on
nv set vrf BLUE router bgp address-family ipv4-unicast route-export to-evpn enable on
nv set vrf BLUE router bgp autonomous-system 65101
nv set vrf BLUE router bgp enable on
nv set vrf BLUE router bgp router-id 11.0.0.0
nv set vrf RED evpn enable on
nv set vrf RED evpn vni 100001
nv set vrf RED loopback ip address 11.0.0.0/32
nv set vrf RED router bgp address-family ipv4-unicast enable on
nv set vrf RED router bgp address-family ipv4-unicast redistribute connected enable on
nv set vrf RED router bgp address-family ipv4-unicast route-export to-evpn enable on
nv set vrf RED router bgp autonomous-system 65101
nv set vrf RED router bgp enable on
nv set vrf RED router bgp router-id 11.0.0.0
nv set vrf default router bgp address-family ipv4-unicast enable on
nv set vrf default router bgp address-family ipv4-unicast redistribute connected enable on
nv set vrf default router bgp address-family l2vpn-evpn enable on
nv set vrf default router bgp autonomous-system 65101
nv set vrf default router bgp enable on
nv set vrf default router bgp neighbor swp1 peer-group hbnzt
nv set vrf default router bgp neighbor swp1 type unnumbered
nv set vrf default router bgp neighbor swp2 peer-group hbnzt
nv set vrf default router bgp neighbor swp2 type unnumbered
nv set vrf default router bgp path-selection multipath aspath-ignore on
nv set vrf default router bgp peer-group hbnzt address-family ipv4-unicast enable on
nv set vrf default router bgp peer-group hbnzt address-family l2vpn-evpn enable on
nv set vrf default router bgp peer-group hbnzt remote-as external
nv set vrf default router bgp router-id 11.0.0.0

# Apply configuration
nv config apply -y

echo "NVUE configuration applied successfully for DPU"
