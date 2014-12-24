#!/bin/bash

xsub2frames (  )
{
	DIR_data=`pwd`
	listfile=$1
	newimg=`cat $listfile | tail -1` 
	oldimg=`cat $listfile | head -1`
	subimage=`echo $newimg | sed 's/.fit/_sub.fit/g'`
	subOUTPUT=`echo $newimg | sed 's/.fit/.sex/g'`
	cd $HOME/iraf1
	cp -f login.cl.old login.cl
	echo noao >> login.cl
	echo image >> login.cl
	echo digiphot >> login.cl
	echo daophot >>login.cl
	echo "cd $DIR_data" >> login.cl
	echo echo "imarith( \"$newimg\",\"-\",\"$oldimg\",\"$subimage\")"  >> login.cl
	echo logout >> login.cl
	cl < login.cl  >OUTPUT_PSF
	mv OUTPUT_PSF $DIR_data
	cp -f login.cl.old login.cl
	cd $DIR_data
	
	sex $subimage  -c  xmatchdaofind.sex -DETECT_MINAREA 6 -DETECT_THRESH 5 -ANALYSIS_THRESH 5 -CATALOG_NAME $subOUTPUT
	
	cd $HOME/iraf1
	cp -f login.cl.old login.cl
	echo noao >> login.cl
	echo digiphot >> login.cl
	echo image >> login.cl
	echo imcoords >>login.cl
	echo "cd $DIR_data" >> login.cl
	echo "display(image=\"$subimage\",frame=1)" >>login.cl #display newimage in frame 3
	echo "tvmark(frame=3,coords=\"$subOUTPUT\",mark=\"circle\",radii=20,color=205,label+,txsize=5)" >>login.cl # tvmark new OT in frame 3
	echo logout >> login.cl
	cl < login.cl >>xlogfile
	cd $HOME/iraf1
	cp -f login.cl.old login.cl
	cd $DIR_data
	sleep 5
}

listallimg=$1

while :
do
	head -2 $listallimg >list2frame
	sed '2,2000p' $listallimg >temp
	mv temp $listallimg
	xsub2frames list2frame
done

