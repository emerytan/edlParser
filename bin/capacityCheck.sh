#!/bin/bash

refreshtime()
{
clear
echo -e "What unit of time would you like to use: "
echo -e -n "Enter (m) for minutes; (h) for hours; (d) for days: "
read tmunit
echo -e -n "Please enter time value (# of time units): "
read tmvalue
clear
echo -e -n "How many volumes do you want to monitor: "
read disknum
}

refreshkey()
{
clear
echo -e -n "How many volumes do you want to monitor: "
read disknum
}


disknum()
{	
let x=$disknum
count=0
while (( count < $x ))
	do
	let d=$count
	echo -e -n "please drag disk `expr $d + 1` into terminal: "
	read drop
	disk=`basename $drop`
	ARRAY[$count]=$disk
	(( count ++ ))
done
}


outputlinix()
{
printf '\e[8;6;50t'
while [ 1 ]
	do
	clear
	count=0
	while (( count < $x ))
		do
		PCT[$count]=`df -h | grep ${ARRAY[$count]} | awk '/Volumes/ { print $5 }'`
		echo -e "${ARRAY[$count]} is ${PCT[$count]} full."
		notify-send "${ARRAY[$count]} is ${PCT[$count]} full."
		(( count ++ ))
	done
	echo -e -n "Hit any key to refresh, control+c to quit"
read -n 1
done

}

outputosx()
{
	printf '\e[8;7;50t'
while [ 1 ]
	do
	clear
	count=0
	while (( count < $x ))
		do
		PCT[$count]=`df -h | grep ${ARRAY[$count]} | awk '/Volumes/ { print $5}'`
		check=`echo ${PCT[$count]} | sed 's/\%//'`
		if [ "${check}" = "" ]; then
			echo -e "${ARRAY[$count]} is not mounted."
		else
			echo -e "${ARRAY[$count]} is at: ${PCT[$count]}"
		fi
		(( count ++ ))
	done
	echo -e -n "\nHit any key to refresh, control+c to quit"
read -n 1
done
exit
}

refreshkey
disknum
outputosx
