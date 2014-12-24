#!/bin/bash
#Author: xlp at 20130118
#do the combination for 5 images which have been shifted well.
#the combination file is named with the name of the 3th image in those 5 images.
#comlist=listcom
DIR_data=`pwd`
comlist=$1
echo $comlist
comref=`cat $comlist | head -1`
echo $comref
comimage=`echo $comref | sed 's/\.fit/.com.fit/'`
echo $comimage
rdnoise=10
gain=1.3

if test -r $comimage
then
        rm -rf $comimage
fi
#-----------------------------------------
cd $HOME/iraf1
cp -f login.cl.old login.cl
echo noao >> login.cl
echo digiphot >> login.cl
echo daophot >>login.cl
echo "cd $DIR_data" >> login.cl
echo flpr >> login.cl
echo "imcombine(\"@$comlist\",\"$comimage\", reject=\"crreject\",combine=\"average\",scale=\"exposure\",weight=\"exposure\",rdnoise=$rdnoise,gain=$gain)" >>login.cl
echo logout >>login.cl
cl < login.cl >xlogfile
#----------------------------------------------
cd $DIR_data
mv $comimage gototemp.fit

echo "=============="$comimage" finished====================="

