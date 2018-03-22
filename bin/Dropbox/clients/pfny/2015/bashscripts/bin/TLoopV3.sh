#!/bin/bash

clear
echo -e "$(tput setaf 2)Post Factory NY - tar restore V3$(tput sgr 0)"


#global variables
TAPE="/dev/nst0"
mdRestorePath="/home/rgs/restore/tapeHeaders"
indexDest="/home/rgs/restore/bash"
destBase="/media/AmUltra_Source_3"
cutListBasePath="/home/rgs/restore/cutLists"


#get barcode and daily roll
echo -e -n "enter tape barcode: "
read bCode
echo -e -n "drop daily roll: "
read r1


#build REEL and DR variables by parsing /path/to/dailyRole/file.txt
REEL=`echo $r1 | grep -o "reel."`
if [ "$REEL" == "" ]
    then
	echo -e "bad entry.  exiting."
	exit 1
fi
dcSrcPath="/home/rgs/restore/temp/PARSED_DATA_ORIG/$REEL"
restorePath="$destBase/$REEL"
r1dr=`basename $r1`
drSrc="$dcSrcPath/$r1dr"
DR=`echo $r1dr | sed 's/.txt//'`


echo -e "$(tput setaf 2)----------------------------------------------$(tput sgr 0)\n\n"
#show results
echo -e "Reel Number:\t$REEL"
echo -e "Daily Roll:\t$DR"
#echo -e "Daily Roll Source Path: $drSrc "


#restore tape header
mkdir -p $mdRestorePath/$bCode
mt -f /dev/st0 rewind
tar -b 128 -xf $TAPE -C $mdRestorePath/$bCode
#error check
if [[ $? -eq 0 ]]
	then
		echo -e "got header\n"
	else
		echo -e "error at: getting header" >&2
		exit 1
fi
matchTape="$mdRestorePath/$bCode/archivingFiles"
mv $matchTape/ult* $matchTape/$bCode.txt &>/dev/null


#show user tapeHeader restore status # preview next step.
echo -e "$(tput setaf 2)restored header file:$(tput sgr 0)\t$(ls $matchTape) "
echo -e "\n$bCode tape header can be found at: ~/tapeHeaders/$bCode"
echo -e "$(tput setaf 2)----------------------------------------------$(tput sgr 0)\n\n"
echo -e "next step: get tarball indexes by filtering $bCode against $DR. "
echo -e -n "\nhit any key to proceed or press [control + c] to quit: "
read -n 1
echo -e "\n"


#code to extract cutlust by cross-referencing dailyRoll
clipsPath="$indexDest/$bCode"
cutListBase="$cutListBasePath/$REEL/$DR/$bCode"
parsedCutList="$cutListBasePath/$REEL/parsedCutList.txt"
mkdir -p $cutListBase
mkdir -p $clipsPath
rm -rf $clipsPath/*
rm -f $cutListBase/*
for drClips in `cat $drSrc`
	do
		grep -e $drClips $parsedCutList  | tee -a $cutListBase/rawCuts.txt
done
cat $cutListBase/rawCuts.txt | awk '{ print $1, $2, $3 }' | \
sort --key=1,1 --key=2,2 -u > $cutListBase/$bCode.txt

echo -e "Done parsing cutlist from Daily Roll. next step: convert SMPTE TC to frames."
sleep 5

cat $cutListBase/$bCode.txt | while read edlParse; do
	clipName=$(echo $edlParse | awk '{ print $1 }')
	cutStart=$(echo $edlParse | awk '{ print $2 }' | awk -F":" '{ hours = $1 * 24 * 3600
		minutes = $2 * 24 * 60
		seconds = $3 * 24
		frames = $4
		start = hours + minutes + seconds + frames
		print start  }')
	cutDur=$(echo $edlParse | awk '{ print $3 }')
	cutEnd=$(expr $cutStart + $cutDur)
	tarBalls=$(echo $cutDur/500 | bc)
	printf "%-20s.%07d.ari\n%-20s.%07d.ari\n" "$clipName" "$cutStart" "$clipName" "$cutEnd" | \
		tee -a $cutListBase/frames$bCode.txt
done

cat $cutListBase/frames$bCode.txt | awk '{ print $1 }' | while read clip
	do
		cat $matchTape/$bCode.txt | grep -E $clip | awk '{ print $1, $2 }' | sort -g | \
		tee -a $cutListBase/pullList$bCode.txt
done

echo -e "got cuts and tarball indexes: next step, create files to use in loop."
sleep 5

cat $cutListBase/pullList$bCode.txt | awk '{ print $1 }' | grep -E -o "[A-Z]...C[0-9]{3}_[0-9]{6}_[A-Z0-9]{4}" | \
while read clipOut; do
	touch $clipsPath/$clipOut.txt; cat $cutListBase/pullList$bCode.txt | grep $clipOut | awk '{ print $2 }' | \
	sort -n -u > $clipsPath/$clipOut.txt
done

cd $clipsPath
for sequenceFix in $(find . -maxdepth 1 -name "*.txt" -type f | sort -n)
	do 
	fixClips=`echo $sequenceFix | sed 's/\.\///g' | sed 's/.txt//g'`
	sequenceCheck=$(cat $sequenceFix | wc -l)
	if [[ "$sequenceCheck" -gt 1 ]]; then
		echo -e "fixing $fixClips - making tarball indexes sequnetial."
		firstNum=$(head -n 1 $sequenceFix)
		lastNum=$(tail -1 $sequenceFix | head -1)
		seq $firstNum $lastNum > $sequenceFix
	fi
done

chown -R rgs:rgs $mdRestorePath
chown -R rgs:rgs $indexDest


#status update + preview next step.
numberOfClips=$(ls -1 $clipsPath | wc -l)
echo -e "got the tarball indexes... $numberOfClips Clips to restore."
echo -e "files located at:  ~/bash/$bCode"
echo -e "$(tput setaf 2)----------------------------------------------$(tput sgr 0)\n\n"

echo -e "next step: preview clips to be restored."
echo -e -n "\nhit any key to proceed or press [control + c] to quit:  "
read -n 1
echo -e "\n"

#show restore que, quit if nothing to be restored.
clear
cd $clipsPath
whereami=`pwd`
echo -e "\nto be restored: "
echo -e "$(find . -maxdepth 1 -name "*.txt" -type f | sort -n | sed 's/\.\///g' | sed 's/.txt//g') "
echo -e "\nrestore path: \t$restorePath"
echo -e "\nall set to go.  verification emails will be sent if restore completes without error."
echo -e -n "press any key to continue, press [control + c] to quit: "
read -n 1
echo -e "\n\n\n"

logPath="$indexDest/restoreLogs/$REEL/$DR"
mkdir -p $logPath
log="$logPath/$restoreLog_$bCode.txt"


# restore clips loop
for clips in $(find . -maxdepth 1 -name "*.txt" -type f | sort -n)
	do startIndex=`head -n 1 $clips`
	loopCheck=$(cat $clips | wc -l)
	if [[ "$loopCheck" -gt 1 ]]; then
		loopyC=$(printf "%02d" "$loopCheck")
		echo "will loop $(echo -e "$clips" | sed 's/.txt//') clip $loopyC times"
	else
		loopyC="01"
	fi
	clipName=`echo $clips | sed 's/\.\///g' | sed 's/.txt//g'`
	echo -e "\nrestore info..."
	tput setaf 3
	echo -e "\tclip: $clipName"
	echo -e "\ttar index: $startIndex"
	echo -e "\tnumber of tarballs: $loopyC"
	tput sgr 0
	echo -e "\n\nshuttling tape to start of: $clipName\n"
	mt -f $TAPE asf $startIndex
	let count=1
	# tarball loop
	if [[ "$loopyC" -gt 1 ]]; then
		while (( count <= $loopyC )); do
			tarTrack=$count
			echo -e "loop counter: $tarTrack of $loopyC"
			tput setaf $tarTrack
			tar -b 128 -xvf $TAPE -C $restorePath
			mt -f $TAPE fsf 1
			(( count ++ ))
		done
	else
		tar -b 128 -xvf $TAPE -C $restorePath
		if [[ $? -eq 0 ]]
		then
			echo -e "\n\n\n$clipName restore success\n\n\n"
			echo -e "$clipName restore success" >> $log
		else
			echo -e "error tarLoop $clipName" >&2
			echo -e "error tarLoop $clipName" >> $log
		exit 1
		fi
	fi
	#error check
	tput sgr 0
	cd $clipsPath
done
#post loop error check
if [[ $? -eq 0 ]]
	then
	echo -e "clipLoop success\n"
	else
	echo -e "error at: tarLoop" >&2
	echo -e "error at: tarLoop.\nreel:\t\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" jeff@postfactoryny.com
	echo -e "error at: tarLoop.\nreel:\t\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" terry@postfactoryny.com
	echo -e "error at: tarLoop.\nreel:\t\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" keenan@postfactoryny.com
	echo -e "error at: tarLoop.\nreel:\t\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" will@postfactoryny.com
	exit 1
fi


# clean up and exit
tput sgr 0
echo -e "rewinding and ejecting tape..."
mt -f $TAPE rewind
mt -f /dev/st0 eject
echo -e "\nrestore complete.\nreel:\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nRestore Path: $(echo $restorePath)\nHave a nice day." | tee -a $log
echo -e "\n$(cat $log)\nHave a nice day." | mail -s "AM Ultra restore report" jeff@postfactoryny.com
echo -e "\n$(cat $log)\nHave a nice day." | mail -s "AM Ultra restore report" terry@postfactoryny.com
echo -e "\n$(cat $log)\nHave a nice day." | mail -s "AM Ultra restore report" keenan@postfactoryny.com
echo -e "\n$(cat $log)\nHave a nice day." | mail -s "AM Ultra restore report" will@postfactoryny.com
exit
