#!/bin/bash

xautoDatareduction ( )
{
	datacode=$1
	otline=`ps aux | awk '{if($12=="/home/gwac/newxgwacmatchsoft/$datacode")print($12)}' | wc -l`

	if [    $otline -eq 0     ]
	then
		gnome-terminal -t "$datacode" -x bash -c "$datacode; exec bash;"
	fi
}

xautoDatareduction	xsubOnline.sh
wait
xautoDatareduction	xtrim_xyf_online.sh
wait
xautoDatareduction 	xotOnline_readdata.sh
wait
