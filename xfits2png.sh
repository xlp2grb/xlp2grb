#!/bin/bash
#author: xlp
#aim: to convert fits after xTrimIm.new.sh to png
#This code depends on the xinpng.py coded by mengxm 
date
fitfile=$1
regionfile=`echo $fitfile | sed 's/.fit/.mark/'`
pngfile=`echo $fitfile | sed 's/.fit/.png/'`
echo $regionfile
ls $fitfile >list
xc=`gethead $fitfile "XOT_SUB" | awk '{print($1)}'`
yc=`gethead $fitfile "yOT_SUB" | awk '{print($1)}'`
echo $xc $yc
#echo "global color=green dashlist=8 3 width=1 font=\"helvetica 10 normal roman\" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1" >$regionfile
#echo "physical" >>$regionfile
#echo "circle("$xc", "$yc", 2)" >>$regionfile
echo $xc $yc "circle 3 green 1" >$regionfile
python /home/xlp/mengxm/markplotw.py list
wait
gwenview $pngfile &
rm -rf $regionfile list
date
