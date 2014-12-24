#!/bin/bash
#Author: xlp at 20130328
#to update the refcom3d.cat from list2framelist
date -u >time_dir
year=`cat time_dir | awk '{print($6)}'`
month=`cat time_dir | awk '{print($2)}'`
day=`cat time_dir | awk '{print($3)}'`
time=`cat time_dir | awk '{print($4)}'`
updatetime=`echo $year"_"$month"_"$day"_"$time`
newfilename=`echo "refcom3d.cat."$updatetime".bak"`
if test -r matchchb.log
then
	cat matchchb.log | awk '{printf("%.0f %.0f %f\n ",$5,$6,$14)}' | sort -n -k 1 | sort -n -k 2 | uniq | sed '/^$/d' | tr '\n' ' ' | xargs -n 3 > updaterefcom3d.cat
	wc updaterefcom3d.cat
	cp refcom3d.cat $newfilename
	echo "before update"
	wc $newfilename 
	cat  updaterefcom3d.cat $newfilename | uniq | sed -e '/^\n$/d' >refcom3d.cat
	echo "after update"
	wc refcom3d.cat 
	rm -rf matchchb.log  updaterefcom3d.cat
	dir_tempfile=`cat listtemp_dirname`
	cat refcom3d.cat | sed '/^$/d'  >refcom3d.cat.temp
	mv refcom3d.cat.temp refcom3d.cat
	cp refcom3d.cat $dir_tempfile 
else 
	echo "No matchchb.log"
fi

