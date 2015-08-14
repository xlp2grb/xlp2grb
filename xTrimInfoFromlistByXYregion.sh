#!/bin/bash
echo " xTrimInfoFromlistByXYregion.sh listname xmin xmax ymin ymax"
list=$1
xmin=$2
xmax=$3
ymin=$4
ymax=$5
echo $list $xmin $xmax $ymin $ymax
cat $list | awk '{if($5>xmin && $5<xmax && $6>ymin && $6<ymax) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}' xmin=$xmin xmax=$xmax ymin=$ymin ymax=$ymax
