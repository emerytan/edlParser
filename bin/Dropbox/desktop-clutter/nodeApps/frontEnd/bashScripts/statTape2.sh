#!/bin/bash

sudo mt -f /dev/nst1 status | grep File | cut -d"," -f 1
sleep .3
sudo mt -f /dev/nst1 status | awk 'NR==6'

exit
