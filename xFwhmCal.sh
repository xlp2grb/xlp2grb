#!/bin/bash

	DIR_data=$1
	FITFILE=$2
	newxy=$3
	OUTPUT_fwhm=$4
	rm -rf OUTPUT_PSF
	cat $newxy |  awk '{print($4,$5,"1 a")}'| column -t >newimageStandxyRef.db
#        cat $imagetmp3sd | grep -v "#" | sed '/^$/d'| awk '{print($1,$2,"1 a")}'| column -t >newimageStandxyRef.db
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo digiphot >> login.cl
        echo daophot >>login.cl
        echo "cd $DIR_data" >> login.cl
        echo "daoedit(\"$FITFILE\", icommand=\"newimageStandxyRef.db\")"  >> login.cl
        echo logout >> login.cl
        cl < login.cl  >OUTPUT_PSF
        mv OUTPUT_PSF $DIR_data
        cp -f login.cl.old login.cl
        cd $DIR_data
        cat OUTPUT_PSF | sed -e '/^$/d' | grep '[1-9]' | grep -v "NOAO" | grep -v "This" | grep -v "line" | grep -v "m" | awk '{print($1,$2,$5,"0 0 0")}' | column -t >$OUTPUT_fwhm
        ls $OUTPUT_fwhm >list_fin
        ./xfwhmave
        cat averagefile_new | column -t | grep -v "nan" >temfile
        cat -n averagefile temfile | column -t >averagefile_fin
        tail -1 averagefile_fin  >fwhm_lastdata
        cat averagefile_fin | awk '{print($2,$3,$4,$5,$6)}' | column -t >averagefile

        ./sentfwhm #send the massage to focusor system (huanglei's computer)

#        displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
#        kill -9 $displayPadNum
#        gnuplot plot.fwhm.gn
#        display average_fwhm.png &
