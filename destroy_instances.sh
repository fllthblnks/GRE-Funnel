#!/bin/bash
# Script to destory all containers

for i in {5..254}
do
   echo "Killing ins$i"
   lxc-stop -k -n ins$i &
done
