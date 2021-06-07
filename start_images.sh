#!/bin/bash
# This script clones the base lxc image into a number of ephemeral containers that are then used for testing


for i in {5..254}
do
   # Copy the base image into an ephemeral state. This makes it so that the disk wont be duplicated or saved once stopped.
   lxc-copy -n base -N ins$i -e
 
   sleep 0.2
   # Set the basic IP address of the container
   lxc-attach ins$i -q -- /bin/bash -c "ip addr add 10.63.0.$i/23 dev eth0"
   # Bring up the L2 GRE tunnel with the controller
   lxc-attach ins$i -q -- /bin/bash -c "ip link add name gre1 type gretap remote 10.63.0.1"
   lxc-attach ins$i -q -- /bin/bash -c "ip link set gre1 up"
   # Set the VLAN for the GRE tunnel
   lxc-attach ins$i -q -- /bin/bash -c "ip link add link gre1 name gre1.639 type vlan id 639"
   lxc-attach ins$i -q -- /bin/bash -c "ip link set gre1.639 up"
   # Set the IP address for the GRE tunnel
   lxc-attach ins$i -q -- /bin/bash -c "ip addr add 10.63.128.$i/23 dev gre1.639"
   # Add a default route
   lxc-attach ins$i -q -- /bin/bash -c "ip route add 0.0.0.0/0 dev gre1.639"
   # Start iperf2 in deamon mode listening to multicast traffic on 224.1.1.1
   lxc-attach ins$i -q -- /bin/bash -c "iperf -s -B 224.1.1.1 -u -D"
done
