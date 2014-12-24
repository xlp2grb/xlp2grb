#!/bin/bash
tvcolorred=204
tvcolorgreen=205
DIR_data=`pwd`
refFITFILE=$1
framNum=$2
file1=`cat listmark | head -1`
file2=`cat listmark | head -2 | tail -1`
file3=`cat listmark | head -3 | tail -1`
file4=`cat listmark | head -4 | tail -1`
file5=`cat listmark | head -5 | tail -1`

file6=`cat listmark | tail -5 | head -1`
file7=`cat listmark | tail -4 | head  -1`
file8=`cat listmark | tail -3 | head  -1`
file9=`cat listmark | tail -2 | head  -1`
file10=`cat listmark |tail  -1 | head -1`
	
	cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl
        echo "display(image=\"$refFITFILE\",frame=$framNum)" >>login.cl #display newimage in frame 2
        echo "tvmark(frame=$framNum,coords=\"$file1\",mark=\"circle\",radii=21,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file2\",mark=\"circle\",radii=21,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file3\",mark=\"circle\",radii=21,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file4\",mark=\"circle\",radii=21,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file5\",mark=\"circle\",radii=21,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file6\",mark=\"circle\",radii=21,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file7\",mark=\"circle\",radii=21,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file8\",mark=\"circle\",radii=21,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file9\",mark=\"circle\",radii=21,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file10\",mark=\"circle\",radii=21,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file1\",mark=\"circle\",radii=5,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file2\",mark=\"circle\",radii=5,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file3\",mark=\"circle\",radii=5,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file4\",mark=\"circle\",radii=5,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file5\",mark=\"circle\",radii=5,color=$tvcolorred)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file6\",mark=\"circle\",radii=5,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file7\",mark=\"circle\",radii=5,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file8\",mark=\"circle\",radii=5,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file9\",mark=\"circle\",radii=5,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=$framNum,coords=\"$file10\",mark=\"circle\",radii=5,color=$tvcolorgreen)" >>login.cl #tvmark new OT in frame 1
        echo logout >> login.cl
        cl < login.cl
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
