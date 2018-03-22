#!/bin/bash

echo -n "getting tarball count... "
#sudo mt -f /dev/st0 rewind && echo -e "done rewindig."
#sudo mt -f /dev/nst0 eod
#fileCount=$(sudo mt -f /dev/nst0 status | sed -n 2p | cut -d, -f 1 | grep -o [0-9])
fileCount=4
counter=0

while [[ $counter -lt $fileCount ]]; do
    echo -n "listing file no. ${counter}" 2>&1
    sleep 1
    (( counter ++ ))
done

exit



#sleep 5
#sudo tar tvf /dev/nst0 -b 1024

