#!/bin/bash

echo -e "sudo mt -f /dev/nst0 status | grep File | cut -d"," -f 1"
sleep .3
echo -e "sudo mt -f /dev/nst0 status | awk 'NR==6'"

exit

