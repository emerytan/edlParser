#!/bin/bash
# gcEDLparser.sh
# Written by: Emery Anderson
# December 2017


function parseEDL () {
	
	awk '/^[0-9]{6}/ { printf "%s %s %s ", $2, $5, $6 } \
	/LOC/ { printf "%s \n", $(NF) }' "$thisEDL" > "$projectBase"/tmp/shots.txt 
	
	echo -e "\nStarting SMPTE to frames conversion..."
	
	sleep 1
	awk 'BEGIN { FS = "[\ \:]+" } {  \
		inHours = $2 * 3600 * 24
		inMinutes = $3 * 60 * 24
		inSeconds = $4 * 24
		inFrames = $5
		start = inHours + inMinutes + inSeconds + inFrames
		outHours = $6 * 3600 * 24
		outMinutes = $7 * 60 * 24
		outSeconds = $8 * 24
		outFrames = $9
		end = outHours + outMinutes + outSeconds + outFrames
		printf "%-26s %07d %07d %-16s \n", $1, start, end, $10 }' "$projectBase"/tmp/shots.txt > "$projectBase"/tmp/frames.txt
	
	sleep 2
	cat "$projectBase"/tmp/frames.txt
	echo -e "starting conversion..."	
	# locateFiles
	exit

}


function locateFiles () { 
	
	cd "$projectBase"
	currentDir=$(pwd)

	if [[ "$currentDir" != "$projectBase" ]]; then
		echo "not in project base directory"
		exit 
	else
		echo "in project base Dir"
		open "$destPath"
	fi

	#	echo -en "enter renumber startpoint: "
	#	read sequence
	#	numberOfChars=$(echo ${sequence} | wc -c)
	#	numberOfChars=$(expr $numberOfChars - 1)
	#	echo -e "number of sequence chars: ${numberOfChars}"
	#	echo -en "enter leading zeros: "
	#	read leadingZeros
	echo -e "\nStarting Copy\n"
	handle=12
	sleep 1
	while read sourceName inPoint outPoint clipName
	do
		if [[ -e "$srcPath"/"$sourceName" ]]; then
			sequence="1"		
			echo -e "Source File:\t$sourceName"
			echo -e "in:\t\t$inPoint"
			echo -e "out:\t\t$outPoint"
			deliveredPath=""$destPath"/${clipName}"
			inHandle=$(expr ${inPoint} - ${handle})
			outHandle=$(expr ${outPoint} + ${handle})
			frameCount=$(expr ${outPoint} - ${inPoint})
			echo -e "Clip name:\t$clipName"		
			echo -e "Frames:\t\t$frameCount"
			echo ""$srcPath"/${sourceName}/${sourceName}.0${inHandle}.dpx"
			mkdir -p "$deliveredPath"
			for ((i=${inHandle};i<${outHandle};i++)); do 
				cp -aLv "$srcPath"/"$sourceName"/${sourceName}.$(printf "%08d" ${i}).dpx "$deliveredPath"/${clipName}.$(printf "%08d" ${sequence}).dpx
				(( sequence ++ ))
			done
		else
			echo -e "\nSource File:\t$sourceName -- NOT FOUND\n" 
			sleep 1
		fi
	done < "$projectBase"/tmp/frames.txt

	exit

}

function edlCheck () {
	isEDL=$(awk 'NR <= 1 { print $1 }' "$thisEDL")
	if [ "$isEDL" = "TITLE:" ]; then
	  echo -e "\tEDL file looks OK"
	  parseEDL "$thisEDL"
	else
		echo -e "not an EDL"
		exit
	fi
}


if [[ "$1" == "undefined" ]]; then
	echo -e "\nWhoops!"
	echo -e "\nno user input to work with"
	echo -e "Make sure you set base path, get EDL, set source, set dest..."
	echo -e "\nHave a nice day!\n"
	exit
else
	echo -e "Goldcrest Post EDL Parser"
	sleep 1
	echo -n "validating file entry..."
fi

redRegex="[A-Z][0-9]{3}_C[0-9]{3}"
arriRegex="[A-Z][0-9]{3}C[0-9]{3}"
thisEDL="$1"
projectBase="$2"
cd "$projectBase"
srcPath="$3"
destPath="$4"
sequence="$5"


if [[ -e tmp ]]; then
	echo "temp directory exists"
else
	mkdir -p tmp
fi

if [ -e "$1" ]; then
	sleep 1
	echo -e "\t"$thisEDL" passed..."
	echo -n "checking EDL formatting..."
	edlCheck "$thisEDL"
else
	echo -e "\n\nerror:\n\t-- file entered doesn't exist.\n\t-- check your path, make sure the file you'd like to use exists.\nexiting.\n"
	exit
fi

exit
