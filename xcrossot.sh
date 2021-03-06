#!/bin/bash
# Author: xlp at 20130108
# to get the same object in the last 3 images
#======================
echo ' ' >listtemp1 
#=====================
if test -r listsky
then
	rm -rf listsky
fi
#=====================
while :
do 
	ls *.skyOT >listsky1
	for file in `cat listsky1`
	do
		num=`wc $file | awk '{print($1)}'`
		if [ $num -lt 500 ]
		then
			ls $file >>listsky
		fi
	done
	line=`wc listsky | awk '{print($1)}'`
	while [ $line -ge 3 ]
	do
		diff listsky listtemp1 | grep  "<" | tr -d '<' | column -t >listtemp2
		cat listtemp2 | head -3 >listtemp
		cat listtemp | head -1 >>listtemp1
		cat `cat listtemp | head -1` >first.db
		cat `cat listtemp | head -2 | tail -1` >second.db
		cat `cat listtemp | tail -1` >third.db
		OTtable3frameHave=`cat listtemp| tail -1 | sed 's/\.skyOT/.skyOT.3frameHave/'`
		OTtable3frameNoAll=`cat listtemp| tail -1 | sed 's/\.skyOT/.skyOT.3frameNotAllHave/'`
		echo $OTtable3frameHave
		./xcross
		line1=`wc 3Frame_match.cat | awk '{print($1)}'`
		if [ $line1 -gt 0  ]
		then
			cat 3Frame_match.cat | column -t >$OTtable3frameHave
			rm -rf 3Frame_match.cat
		fi
		cat first.db second.db third.db >all.db
		diff all.db $OTtable3frameHave | grep  "<" | tr -d '<' | column -t >$OTtable3frameNoAll
	done
done
