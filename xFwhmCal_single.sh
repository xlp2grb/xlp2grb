#!/bin/bash

	DIR_data=$1
	FITFILE=$2
	imagetmp3sd=$3
	OUTPUT_fwhm=$4
	rm -rf OUTPUT_PSF
        cat $imagetmp3sd | grep -v "#" | sed '/^$/d'| awk '{print($3,$4,"1 a")}'| column -t >newimageStandxy.db
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo digiphot >> login.cl
        echo daophot >>login.cl
        echo "cd $DIR_data" >> login.cl
        echo "daoedit(\"$FITFILE\", icommand=\"newimageStandxy.db\")"  >> login.cl
        echo logout >> login.cl
        cl < login.cl  >OUTPUT_PSF
        mv OUTPUT_PSF $DIR_data
        cp -f login.cl.old login.cl
        cd $DIR_data
        cat OUTPUT_PSF | sed -e '/^$/d' | grep '[1-9]' | grep -v "NOAO" | grep -v "This" | grep -v "line" | grep -v "m" | awk '{print($1,$2,$5,"0 0 0")}' | column -t >$OUTPUT_fwhm
        #ls $OUTPUT_fwhm >list_fin
	cat $OUTPUT_fwhm | awk '{if($1>500 && $1<2500 && $2>500 && $2<2500) print($1,$2,$3,$4,$5,$6)}' >list_fin
        ./xfwhmave
        cat averagefile_new | column -t | grep -v "nan" >temfile
        cat -n averagefile temfile | column -t >averagefile_fin
        tail -1 averagefile_fin  >fwhm_lastdata_2k
        cat averagefile_fin | awk '{print($2,$3,$4,$5,$6)}' | column -t >averagefile
	
#======================================================
        mountid=`gethead $FITFILE "MOUNTID" `
        ccdid=`gethead $FITFILE "CCDID"`
        case $ccdid in
         A | C | E | G | I | K )
            realccdid=`echo "S"`
            echo "The image is from" $mountid "mount and " $realccdid "CCD"
            echo $mountid$realccdid >imageidlist.txt
         ;;
         B | D | F | H | J | L )
           realccdid=`echo "N"`
           echo "The image is from" $mountid "mount and " $realccdid "CCD"
           echo $mountid$realccdid >imageidlist.txt
         ;;
         *)
           echo "Ignorant"
         ;;
        esac  

#======================================================
	paste fwhm_lastdata_2k imageidlist.txt | column -t >fwhm_lastdata

#        ./sentfwhm #send the massage to focusor system (huanglei's computer)

#        displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
#        kill -9 $displayPadNum
        gnuplot plot.fwhm.gn
#        display average_fwhm.png &
	ps -all | awk '{if($14=="evince") print($4)}' >evince.temp
	if test -s evince.temp
	then
		:
	else
		evince average_fwhm.eps &
	fi
		
