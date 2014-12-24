#!/bin/bash
echo "./xGetObjWithTempXY.sh xc yc"
xc=$1
yc=$2
radius=5
cat *.skyOT | sort -n -k 6 | awk '{if($6>(yc-r) && $6<(yc+r) && $5>(xc-r) && $5<(xc+r))print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)}' xc=$xc yc=$yc r=$radius | grep -v "test" |sort -k 7|  column -t > tempxycoor
echo tempxycoor
