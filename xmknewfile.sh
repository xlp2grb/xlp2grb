#!/bin/bash
dir_now=`pwd`
date -u >time_dir
year=`cat time_dir | awk '{print($6)}'`
month=`cat time_dir | awk '{print($2)}'`
day=`cat time_dir | awk '{print($3)}'`
newdictory=`echo $year$month$day`
cd /data2/workspace/resultfile
if test ! -d $newdictory
then
        mkdir $newdictory
fi

cd $newdictory

if test ! -d otsubimfile
then
        mkdir otsubimfile
fi
if test ! -d wholeimfile
then
        mkdir wholeimfile
fi

cd $Dir_now
rm -rf time_dir
