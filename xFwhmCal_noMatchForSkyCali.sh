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
    cp averagefile_fin allxyfwhm.cat.plot

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
        #./sentfwhm #send the massage to focusor system (huanglei's computer)

        #        displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
        #        kill -9 $displayPadNum
        ID_MountCamara=`gethead $FITFILE "IMAGEID"  | cut -c14-17`                                                                                 
        sh xplotfwhm.sh $ID_MountCamara
        #gnuplot plot.fwhm.gn
        #        display average_fwhm.png &
    else
        echo "No fwhm_lastdata in this image"
    fi
}

DIR_data=$1
FITFILE=$2
ejmin=20
ejmax=3030
#OUTPUT_fwhm=$3
OUTPUT_fwhm=`echo $FITFILE | sed 's/\.fit/.fit.fwhm/'`
fwhmmax=10
fwhmmin=1.2
echo $DIR_data $FITFILE $OUTPUT_fwhm
OUTPUT_ini=`echo $FITFILE | sed 's/\.fit/.fit.sexini/'`
OUTPUT_bg=`echo $FITFILE | sed 's/\.fit/.bg.fit/'`
sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH 3.0 -ANALYSIS_THRESH 3.0 -CATALOG_NAME $OUTPUT_ini -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $OUTPUT_bg
rm -rf $OUTPUT_bg

#======================================
NStar_ini=`cat $OUTPUT_ini | wc -l | awk '{print($1)}'`
rm -rf newbgbrightres.cat
cat $OUTPUT_ini | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax)print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' ejmin=$ejmin ejmax=$ejmax          >newbgbright.cat
head -1 newbgbright.cat 
tail -1 newbgbright.cat
if test -s newbgbright.cat
then
	./xavbgbrightAndEllip
	wait
fi
cat newbgbrightres.cat
if test ! -r newbgbrightres.cat
then        
    echo "No file of newbgbrightres.cat"
    echo $NStar_ini -99 -99 $FITFILE >ObjAndBgbrightAndEllipFile
else        
    bgbrightness=`cat newbgbrightres.cat | awk '{printf("%.1f\n", $1)}'`
    echo "bg brightness is : " $bgbrightness
    avellip=`cat newbgbrightres.cat | awk '{printf("%.2f\n",$2)}'`
    echo "Average ellipticity is:  $avellip"
    echo $NStar_ini $bgbrightness $avellip $FITFILE >ObjAndBgbrightAndEllipFile 
  fi          



#======================================
cat $OUTPUT_ini | sort -n -k 7 | awk '{if($1>500 && $1<2500 && $2>500 && $2<2500 && $4==0) print($1,$2,"1 a")}'| head -500 >newimageStandxy.db
NstarForfwhm=`wc -l newimageStandxy.db | awk '{print($1)}'`
if [ $NstarForfwhm -lt $NstarForfwhmLimit ]
then
    echo "The objects for fwhm in noMatch.sh are too small, only: " $NstarForfwhm
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
