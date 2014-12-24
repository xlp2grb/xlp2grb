#!/bin/bash
#Author: xlp
#This code is used to combine 5 images continuously 
#and have a sepration with 3 frames between two combination.

echo "usage: This soft need the list named as listall"
echo "You should list your images into the listall"
echo "like this: ls d12*.fit >listall"

DIR_data=`pwd`

if test -f listtmp
then
	rm -rf listtmp
fi

while :
do
#combination num is 5 images, with a sepration of 3 images.
#	cat listall | head -8 >listtmp
#	cat listtmp | head -5 >imcombinelist
#=========================================================
#combination num is 5 images, with overlap of 3 images.
#	cat listall | head -2 >listtmp
#	cat listall | head -5 >imcombinelist
#=========================================================
#combination num is 5 images, whitout any overlap or sepration.	
	cat listall | head -5 >listtmp
	cp listtmp imcombinelist

	line=`wc imcombinelist | awk '{print($1)}'`
	if [ $line -ne 0 ]
	then 
		diff listall listtmp |  tr -d '>' | awk '{print($2)}' | column -t  >listnew
		mv listnew listall
	        	
		FITFILEcom=`cat imcombinelist | head -1`
		OutputFile=`echo $FITFILEcom | sed 's/\.fit/_com.fit/'`
		
	        cd $DIR_data
	        cd $HOME/iraf
	        cp -f login.cl.old login.cl
	        echo noao >> login.cl
	        echo digiphot >> login.cl
	        echo daophot >>login.cl
	        echo "cd $DIR_data" >> login.cl
	        echo "imcombine(\"@imcombinelist\",\"$OutputFile\", reject=\"crreject\",combine=\"average\",scale=\"exposure\",weight=\"exposure\",rdnoise="10",gain="1.3")" >>login.cl
	        echo logout >>login.cl
	        cl < login.cl >xlogfile
	        cd $HOME/iraf
	        cp -f login.cl.old login.cl
		rm -rf xlogfile
	        cd $DIR_data
		
		if test -f $OutputFile
		then
			echo "===Output image ="$OutputFile "ncombine ="$line"======="
		fi
	else
		echo "======No any image in the listall======"
		exit 0
	fi 
done
