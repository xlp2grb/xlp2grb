#!/bin/bash
#Author: xlp at 2012/12/11
#This soft is to test the tempfiles exist or not in temfile.
#if exist, they will be copied to the redufile 
#and then run the xmatch3.sh

Dir_temp=/home/jianyan/workspace/tempfile
echo $Dir_temp

if test -f $Dir_temp/refcom3d.cat
then
	cp $Dir_temp/refcom3d.cat ./
	if test -f $Dir_temp/refcom.fit
	then
		cp $Dir_temp/refcom.fit ./
		if test -f $Dir_temp/refcom.acc
		then
			cp $Dir_temp/refcom.acc ./
			if test -f $Dir_temp/GwacStandall.cat
			then
				cp   $Dir_temp/GwacStandall.cat ./
				if test -f $Dir_temp/refcom1d.cat
				then
					cp $Dir_temp/refcom1d.cat ./
					./xmatch3.sh
				else
					echo "====These is no refcom1d.cat in tempfile====="
				fi
			else
				echo "====These is no GwacStandall.cat in tempfile====="
			fi
		else
			echo "====These is no refcom.acc in tempfile====="
		fi
	else
		echo "====There is no refcom.fit in tempfile======"
	fi
else
	echo "====These is no refcom3d.cat in tempfile====="
fi
