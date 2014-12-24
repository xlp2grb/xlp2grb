#!/bin/bash
echo "xFwhm_noMatch.sh"
NstarForfwhmLimit=200
Dir_monitor=/data2/workspace/monitor/
stringtimeForMonitorT=`date -u +%Y%m%d`
stringtimeForMonitor=`echo $Dir_monitor"reduc_"$stringtimeForMonitorT`".log"
rm -rf OUTPUT_PSF fwhm_lastdata

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

#        displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
#        kill -9 $displayPadNum
         gnuplot plot.fwhm.gn
#        display average_fwhm.png &
        else
                echo "No fwhm_lastdata in this image"
        fi
}

DIR_data=$1
FITFILE=$2
#OUTPUT_fwhm=$3
OUTPUT_fwhm=`echo $FITFILE | sed 's/\.fit/.fit.fwhm/'`
fwhmmax=10
fwhmmin=1.2
echo $DIR_data $FITFILE $OUTPUT_fwhm
OUTPUT_ini=`echo $FITFILE | sed 's/\.fit/.fit.sexini/'`
OUTPUT_bg=`echo $FITFILE | sed 's/\.fit/.bg.fit/'`
sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH 15.0 -ANALYSIS_THRESH 15.0 -CATALOG_NAME $OUTPUT_ini -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $OUTPUT_bg
rm -rf $OUTPUT_bg

cat $OUTPUT_ini | sort -n -k 7 | awk '{if($1>500 && $1<2500 && $2>500 && $2<2500 && $4==0) print($1,$2,"1 a")}'| head -500 >newimageStandxy.db
NstarForfwhm=`wc -l newimageStandxy.db | awk '{print($1)}'`
if [ $NstarForfwhm -lt $NstarForfwhmLimit ]
then
	echo "The objects for fwhm in noMatch.sh are too small, only: " $NstarForfwhm
	rm -rf newimageStandxy.db
else
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
	cat OUTPUT_PSF | grep "ERROR" >errormsg
	if test -s errormsg
	then
	         echo "Error in the psf calculate, when doing xFwhmCal_noMatch.sh "
	         echo "Error in the psf calculate xFwhmCal_noMatch.sh" >>$stringtimeForMonitor
	else
		cat OUTPUT_PSF | sed -e '/^$/d' | grep '[1-9]' | grep -v "NOAO" | grep -v "This" | grep -v "line" | grep -v "m" | awk '{if($5>1.0)print($1,$2,$5,"0 0 0")}' | column -t >$OUTPUT_fwhm
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
