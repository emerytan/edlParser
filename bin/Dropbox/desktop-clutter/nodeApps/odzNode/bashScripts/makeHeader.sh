#!/bin/bash

headerPath="/home/gittar/Documents/headerFiles/GT/DSM/R1/"
DATE=$(date)

echo -e "#\tFacility:\tSixteen19" | tee -a ${headerPath}/${2}.txt
echo -e "#\tContact:\thttp://www.sixteen19.com/contact/" | tee -a ${headerPath}/${2}.txt
echo -e "#\tArchive Date:\t${DATE}" | tee -a ${headerPath}/${2}.txt

ls -l ${1} --time-style=+%Y:%m:%d:%T:%Z | awk '{ print $7, $5, $6 }' | column -t | tee -a ${headerPath}/${2}.txt

exit

