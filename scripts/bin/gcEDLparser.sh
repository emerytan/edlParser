#!/bin/bash
# gcEDLparser.sh
# Written by: Emery Anderson
# December 2017


redRegex="[A-Z][0-9]{3}_C[0-9]{3}"
arriRegex="[A-Z][0-9]{3}C[0-9]{3}"
thisEDL="$1"
projectBase="$2"
cd "$projectBase"
srcPath="$3"
destPath="$4"

if [[ -e tmp ]]; then
	echo "temp directory exists"
else
	mkdir -p tmp
fi

whereAmi="tmp"

function parseEDL () {
	
	awk '{ if ( $1 ~ /[0-9]{6}/ && $2 ~ /[A-Z][0-9]{3}C[0-9]{3}/ ) 
	printf "%s %s %s ", $2, $5, $6 } \
	/CLIP\ NAME/ { printf "%s \n", $(NF-1) }' "$thisEDL" > "$projectBase"/tmp/shots.txt 
	
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
	locateFiles

}


function locateFiles () { 
	# echo -en "enter renumber startpoint: "
	# read sequence
	# numberOfChars=$(echo ${sequence} | wc -c)
	# numberOfChars=$(expr $numberOfChars - 1)
	# echo -e "number of sequence chars: ${numberOfChars}"
	# echo -en "enter leading zeros: "
	# read leadingZeros

	cd "$projectBase"
	currentDir=$(pwd)

	if [[ "$currentDir" != "$projectBase" ]]; then
		echo "not in project base directory"
		exit 
	else
		echo "in project base Dir"
	fi

	echo -e "\nStarting Copy\n"
	handle=15
	sleep 1
	while read sourceName inPoint outPoint clipName
	do 
		echo -e "Source File:\t$sourceName"
	 	echo -e "in:\t\t$inPoint"
		echo -e "out:\t\t$outPoint"
		deliveredPath=""$destPath"/${clipName}"
		inHandle=$(expr ${inPoint} - ${handle})
		outHandle=$(expr ${outPoint} + ${handle})
		frameCount=$(expr $outPoint - $inPoint)
		echo -e "Clip name:\t$clipName"		
		echo -e "Frames:\t\t$frameCount"
		echo "$pullsPath"/${sourceName}/${sourceName}.0${i}.dpx
		sleep 5
		mkdir -p "$deliveredPath"
#		echo -e "rename preview: ${sourceName}.[${inPoint}]-[${outPoint}].dpx\t--->\t${clipName}.[${leadingZeros}${sequence}]-[${leadingZeros}$(expr $sequence + $frameCount)].dpx\n"
		for ((i=${inHandle};i<${outHandle};i++)); do echo "cp -aL "$srcPath"/"$sourceName"/${sourceName}.0${i}.dpx "$deliveredPath"/${clipName}.0${i}.dpx"; done
	done < $whereAmi/frames.txt

	

}

function edlCheck () {
	isEDL=$(awk 'NR <= 1 { print $1 }' "$thisEDL")
	if [ "$isEDL" = "TITLE:" ]; then
	  echo -e "\tEDL file looks OK"
	  parseEDL "$thisEDL" && echo -e "parse EDL exit status 0\n"
	else
		echo -e "not an EDL"
		exit
	fi
}


if [[ "$1" != "" ]]; then
	echo -e "Goldcrest Post EDL Parser"
	sleep 1
	echo -n "validating file entry..."
else
	echo -e "\nWhoops!"
	echo -e "\nno EDL file to work with"
	echo -e "command usage:\tgcEDLparser [ any_EDL_file.edl ]"
	echo -e "\nHave a nice day!\n"
	exit
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

# script should ask to rename by clipname or locator
# option to use source frame numbers or renumber...
# append gcLink to moved directory  

