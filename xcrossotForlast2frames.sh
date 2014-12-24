#!/bin/bash
# Author: xlp at 20130325
# to get the same object in the last 2 images
#======================
#=====================
line=`wc listsky | awk '{print($1)}'`
if [ $line -ge 2 ]
then
	cat listsky | tail -2 >listtemp
	cat `cat listtemp | head -1 ` >first.db
	cat `cat listtemp | tail -1 ` >second.db
	OTtable2frameHave=`cat listtemp| tail -1 | sed 's/\.skyOT/.skyOT.2frameHave/'`
	OTtable2frameNoAll=`cat listtemp| tail -1 | sed 's/\.skyOT/.skyOT.2frameNotAllHave/'`
	echo $OTtable2frameHave
	./xcross2frame
	line1=`wc 2Frame_match.cat | awk '{print($1)}'`
	if [ $line1 -gt 0  ]
	then
		cat 2Frame_match.cat | column -t >$OTtable2frameHave
		rm -rf 2Frame_match.cat
	fi
	cat first.db second.db >all.db
	diff all.db $OTtable2frameHave | grep  "<" | tr -d '<' | column -t >$OTtable2frameNoAll
#	rm -rf first.db second.db
fi
