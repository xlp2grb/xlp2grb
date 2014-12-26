#!/bin/bash
echo "xFwhmCal_standmag.sh"
NstarForfwhmLimit=50
Dir_monitor=/data2/workspace/monitor/
stringtimeForMonitorT=`date -u +%Y%m%d`
stringtimeForMonitor=`echo $Dir_monitor"reduc_"$stringtimeForMonitorT`".log"
rm -rf fwhm_lastdata OUTPUT_PSF

xfwhmcalandsent ( )
{
        echo $OUTPUT_fwhm >imagename.lst
        paste imagename.lst averagefile_new >temp
        mv temp averagefile_new
        rm -rf imagename.lst
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
        #    echo "The image is from" $mountid "mount and " $realccdid "CCD"
            echo $mountid$realccdid >imageidlist.txt
         ;;
         B | D | F | H | J | L )
           realccdid=`echo "N"`
         #  echo "The image is from" $mountid "mount and " $realccdid "CCD"
           echo $mountid$realccdid >imageidlist.txt
         ;;
         *)
           echo "Ignorant"
         ;;
        esac

#======================================================
        paste fwhm_lastdata_2k imageidlist.txt | column -t >fwhm_lastdata
        if test -r fwhm_lastdata
        then
                cat fwhm_lastdata >>$stringtimeForMonitor
                ./sentfwhm #send the massage to focusor system (huanglei's computer)

        #displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
        #kill -9 $displayPadNum
        gnuplot plot.fwhm.gn
#        display average_fwhm.png &
        else
                echo "No fwhm_lastdata for this image"
        fi

}


 DIR_data=$1
 FITFILE=$2
 imagetmp3sd=$3
 OUTPUT_fwhm=$4
 fwhmmax=10.0
 fwhmmin=1.2
echo $imagetmp3sd $OUTPUT_fwhm
 cat $imagetmp3sd | grep -v "#" | sed '/^$/d'| awk '{if($1>500 && $1<2500 && $2>500 && $2<2500) print($1,$2,"1 a")}'| column -t >newimageStandxy.db
 NstarForfwhm=`cat  newimageStandxy.db | wc -l | awk '{print($1)}'`
echo $NstarForfwhm
 if [ $NstarForfwhm -lt $NstarForfwhmLimit ]
 then
         echo "The objects for fwhm in xFwhmCal_standmag.sh are too small: " $NstarForfwhm
         rm -rf newimageStandxy.db
 else
	 cd $HOME/iraf2
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
	  cat OUTPUT_PSF | grep "ERROR" >errormsg
	 if test -s errormsg
	 then
	 	 echo "Error in the psf calculate, when doing xFwhmCal_standmag.sh "
	 	 echo "Error in the psf calculate xFwhmCal_standmag.sh" >>$stringtimeForMonitor
	 else
		 cat OUTPUT_PSF | sed -e '/^$/d' | grep '[1-9]' | grep -v "NOAO" | grep -v "This" | grep -v "line" | grep -v "m" | awk '{print($1,$2,$5,"0 0 0")}' | column -t >$OUTPUT_fwhm
		 #ls $OUTPUT_fwhm >list_fin
		 #cat $OUTPUT_fwhm | awk '{if($1>500 && $1<2500 && $2>500 && $2<2500) print($1,$2,$3,$4,$5,$6)}' >list_fin
		 cat $OUTPUT_fwhm | awk '{print($1,$2,$3,$4,$5,$6)}' >list_fin
		 ./xfwhmave
		 if test -s averagefile_new
		 then
		 	newfwhm=`cat averagefile_new | awk '{print($3)}'`
		 	if [ ` echo " $newfwhm > $fwhmmax " | bc ` -eq 1 ] || [ ` echo " $newfwhm < $fwhmmin " | bc ` -eq 1  ]
		 	then
		 		echo "This FWHM is not normal:  " $newfwhm
		 	else
		 		xfwhmcalandsent
		 	fi
		 else
		 	echo "No averagefile_new file"
		 fi
	 	
	 fi
 fi
