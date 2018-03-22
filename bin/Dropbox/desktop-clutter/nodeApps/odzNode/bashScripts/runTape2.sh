#!/bin/bash

# locals
DATE=$(date)
headerDate=$(date +%k%M%S)


cd "$1" && echo "cd success"
sleep 3


# make header
if [ ! -f DPXDIR.txt ]
	then echo "making header"
	HEADER=$(touch DPXDIR.txt)
	echo -e "#\tFacility:\tSixteen19" | tee -a DPXDIR.txt
	echo -e "#\tContact:\thttp://www.sixteen19.com/contact/" | tee -a DPXDIR.txt
	echo -e "#\tArchive Date:\t${DATE}" | tee -a DPXDIR.txt
	ls -lR --time-style=+%Y:%m:%d:%T:%Z | grep .dpx | awk '{ print $7, $5, $6 }' | column -t | tee -a DPXDIR.txt
fi


# write header
echo "tape 1 tarball header..."
sleep 5
if [ -f DPXDIR.txt ]
    then echo "header file exists"
    sudo tar cvf /dev/nst1 -b 1024 DPXDIR.txt && echo "header file tarred up."
else
    echo -n "header file doesn't exist"
    exit 1
fi


# write files
cd "$1" && echo "cd to tarsouce - sucess"
TARBALL=$(basename `pwd`)
cd .. && echo "resolition: "$TARBALL"  -- tape 2 starting tarball in 5 seconds."
sleep 5
sudo tar cvf /dev/nst1 -b 1024 "$TARBALL"

exit
