#!/bin/bash

SRC="/mnt/c/Users/NUTCRACKER/Downloads"
DST="/mnt/c/Users/NUTCRACKER/nodeApps"

if [[ -e "$SRC" ]]; then
	echo "good"
	rsync -ah --stats --dry-run "$SRC" "$DST" && exit
else 
	echo "bad"
	exit 1 
fi


