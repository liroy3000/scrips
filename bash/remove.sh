#!/bin/bash
HIGHTCPU=8

START_TIME=`date`
cd $1
TOP_FOLDERS=(*)

for TOP_FOLDER in ${TOP_FOLDERS[@]}; do
	cd $TOP_FOLDER
	LVLS_1=(*)
	for LVL_1 in ${LVLS_1[@]}; do
		cd $LVL_1
		LVLS_2=(*)
		for LVL_2 in ${LVLS_2[@]}; do
			cd $LVL_2
			TO_RMS=(*)
			for TO_RM in ${TO_RMS[@]}; do
				LOADCPU=`uptime | awk '{print $10}' | sed 's/.$//'`
				while true; do
				 if (( $(echo "$LOADCPU > $HIGHTCPU" | bc) )); then
				 	sleep 5
				 	LOADCPU=`uptime | awk '{print $10}' | sed 's/.$//' | sed 's/,/./'`
				 else
				 	break
				 fi
				done
				echo $TOP_FOLDER/$LVL_1/$LVL_2/$TO_RM
				rm -rfd $TO_RM
			done
			cd ../
		done
		cd ../
	done
	cd ../
done
echo "Start script: $START_TIME"
echo "Stop script: `date`"