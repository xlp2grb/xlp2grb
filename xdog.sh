#!/bin/bash
#Author: xlp
#date:20131017
#Aim: to protect the code xotOnlinelist.sh from stop.

i=0
date +%s >>listmatch.old
while :
do
	if test -r listmatch.old
	then
		timelast=`cat listmatch.old | tail -1`
		timenow=`date +%s`
		timeused=`echo $timenow $timelast | awk '{print($1-$2)}'`
		if [ $timeused -gt 60 ]
		then
			diff listmatch.old listmatch | grep  ">" | tr -d '>' >listmatch.test1
			cat listmatch.test1 | awk '{print($1)}' >listmatch
			PadNum=`ps -all | awk '{if($14=="xmatch11.cata.s") print($4)}'` 
			kill -9 $PadNum
			date +%s >>listmatch.old
			#./xmatch11.cata.sh.20131013 &
			#./xotOnline.sh &
#			./xotOnlinelist.sh &
		else
			echo $i
			j=`echo $i | awk '{print($1+1)}'`
			i=`echo $j`
			sleep 60
		
		fi	
	else 
		./xotOnlinelist.sh &
	fi
done
