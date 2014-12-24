#!/bin/bash
DIR_data=`pwd`
gain=1.3
rdnoise=10
#ls flat*.fit >listflat
darkname=Dark.fit
if test -r $darkname
then
	echo "----Doing the flat process----"
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	echo noao >> login.cl
	echo imred >>login.cl
	echo ccdred >>login.cl
	echo "cd $DIR_data" >> login.cl
	echo "ccdpro((images=\"@listflat\", output=\"  \",trim-,zerocor-,darkcor+,flatcor-,dark=\"$darkname\")" >>login.cl
	echo "flatcombine(input=\"@listflat\", output=\"Flat.fit\",combine=\"median\",reject=\"minmax\",ccdtyp=\" \",process-,rdnoise=$rdnoise,gain=$gain,)" >>login.cl
	echo "display(image=\"Flat\",frame=1)" >>login.cl
	echo logout >> login.cl
	cl < login.cl >xlogfile 
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	cd $DIR_data

	sex Flat.fit  -c  xmatchdaofind.sex -DETECT_THRESH 2.5 -ANALYSIS_THRESH 2.5 -CATALOG_NAME Flat.sex -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME Flat_bg.fit

        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo imred >>login.cl
        echo ccdred >>login.cl
        echo "cd $DIR_data" >> login.cl
	echo "display(image=\"Flat_bg.fit\",frame=2)" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data

else
	echo "No Dark.fit"
fi
