#!/bin/bash

destBase="/media/AmUltra_Source_1"
TAPE="/dev/nst0"
awk '{ print $3, $1, $2 }' AMU015.txt | while read n reel clip; do
	if (( n != previous + 1 )); then
		echo -e "clip: $clip"
		echo -e "tarball: ${n}"
		echo -e "reel: $reel"
		echo -e "destination: $destBase/$reel"
		mt -f $TAPE ${n}
		tar -b 128 -xvf $TAPE -C $destBase/$reel
	else
		echo -e "clip: $clip"
		echo -e "tarball: ${n}"
		echo -e "reel: $reel"
		echo -e "destination: $destBase/$reel"
		mt -f $TAPE fsf 1
		ar -b 128 -xvf $TAPE -C $destBase/$reel
	fi
done

