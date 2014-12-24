#!/bin/bash
# Author: xlp at 20130108
# to get the same object in the last 3 images
#======================
#=====================
line=`wc listsky | awk '{print($1)}'`
if [ $line -ge 3 ]
then
	cat listsky | tail -3 >listtemp
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
	rm -rf first.db second.db third.db
fi

