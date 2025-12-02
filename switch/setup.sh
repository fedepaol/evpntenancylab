#!/bin/bash
#
# NVUE-based configuration for leaf1
# This replaces the traditional interfaces file and FRR configuration
#

# Wait for NVUE to be ready
sleep 5

nv set bridge domain rdma untagged 1
nv set evpn enable on
nv set interface eth0 ip address
nv set interface eth0 ip vrf mgmt
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
nv set system forwarding
nv set system hostname cumulus
nv set system wjh enable on
nv set vrf default loopback ip address
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
