#!/bin/bash

if [ $# -ne 4 ]
then
        echo "usage:command:  xuptempbyhand.sh RA DEC[mount]  CCDID[A,B,C,D...] update[or delete] "
        exit 0
fi
xra=$1
xdec=$2
xccdid=$3
xdoflag=$4

case $ccdid in A )
    ccdid=M1AA;;
B )
    ccdid=M1AB;;
C )
    ccdid=M2AC;;
D )
    ccdid=M2AD;;
E )
    ccdid=M3AE;;
F )
    ccdid=M3AF;;
G )
    ccdid=M4AG;;
H )
    ccdid=M4AH;;
I )
    ccdid=M5AI;;
J )
    ccdid=M5AJ;;
K )
    ccdid=M6AK;;
L )
    ccdid=M6AL;;
esac

Dir_pres=`pwd`
Dir_temp=/data2/workspace/tempfile/result
temp_ip=`echo 190.168.1.40`
temp_dir=/home/gwac/newfile

xcopyupdateflag ( )
{
echo "to update the temp"
rm listupdate
touch noupdate.flag
echo $tempfilenamefinal
mv noupdate.flag $tempfilenamefinal
}

xdelete( )
{
	echo "to delete the temp"
	
	#touch delete.flag
	echo $tempfilename >delete.flag
	xatcopy_remote.f delete.flag delete.flag $temp_ip $temp_dir"/"$xccdid
	cat delete.flag
	rm -rf delete.flag
	cd $Dir_temp	
	echo $xra $xdec $xccdid >newimageCoordForDelete
	cp GPoint_catalog GPoint_catalog.old
	xcheckskyfieldAndDelete
	mv xcheckResultForDelete GPoint_catalog
	rm -rf newimageCoordForDelete
	datetimeForDelete=`date +%Y%m%d%H%M%S`
	newTempfilename=`echo $tempfilename"."$datetimeForDelete`
	mv $tempfilename $newTempfilename
	echo "have update the GPoint_catalog in local file"
	cd $Dir_pres
}

xtellflag ( )
{
	if [ "$xdoflag" == "update" ]
	then
		xcopyupdateflag
	elif [ "$xdoflag" == "delete" ]
	then
		xdelete
	else
		echo "input 4th parameters is not right"
	fi
}

xtelltempname ( )
{
	tempfilename=`cat xcheckResult | awk '{print($9"_"$8)}'`
	tempfilenamefinal=`echo $Dir_temp"/"$tempfilename`
}

#=======main=========
echo $xra $xdec $xccdid >newimageCoord
cp -f $Dir_temp/GPoint_catalog ./
cp GPoint_catalog  newtest.txt
xcheck_skyfield
if [  -s xcheckResult ]
then
	xtelltempname
	xtellflag
else
	echo "no xcheckResult, process is faild. which might be due to the non-exist tempfile"
fi
