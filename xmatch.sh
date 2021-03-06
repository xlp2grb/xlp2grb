#!/bin/bash
#Author: xlp at 20130101
#20141204
#Version: V1.0
#function: to match the newimage to the refcom.fit with xyxymatch
#input newimage 
#output *tempxyOT *skyOT
#This codes includes the catalog match and image subtraction
#image match is only done with 1 times.
# modified by xlp at 20130110
#update the codes about the flux match for subimage
#update the codes about the FWHM calculation for xFhmwCal.sh
# modifed by xlp at 20130.13
#reduction time is reduced from 13 sec to 7 sec.
#rm -rf listsky*
Dir_redufile=`pwd`

#=====================
Dir_monitor=/data2/workspace/monitor
stringtimeForMonitorT=`date -u +%Y%m%d`
stringtimeForMonitor=`echo $Dir_monitor"/reduc_"$stringtimeForMonitorT".log"`
stringtimeForReduc=`echo $Dir_monitor"/TimeForReduc_"$stringtimeForMonitorT".log"`
Dir_monitor_allplot=`echo $Dir_monitor"/"$stringtimeForMonitorT`
if test ! -r $Dir_monitor_allplot
then
    mkdir $Dir_monitor_allplot
fi
#=====================
UploadParameterfile=`echo http://190.168.1.25/gwacFileReceive`
sub_dir=/data2/workspace/redufile/subfile
lc_dir=/data2/workspace/redufile/getlc
Dir_temp=/data2/workspace/tempfile/result
trimsubimage_dir=/data2/workspace/redufile/trimsubimage
trimsubimageForTemp_dir=/data2/workspace/redufile/trimsubimageForTemp
Alltemplatetable=refcom3d.cat
temp_dir=/home/gwac/newfile
temp_ip=`echo 190.168.1.40` #(ip for temp builder at xinglong)
IPforMonitorAndTemp=`echo 190.168.1.40`
Dir_IPforMonitorAndTemp=/home/gwac/webForFwhm
#cat $Alltemplatetable | sed '/^$/d'  >new1
#mv new1 $Alltemplatetable
AlltemplatetableForVariable=refcom4d.cat
tempfile=refcom.fit
tempmatchstars_mag=GwacStandall_mag.cat
tempsubbgfile=refcom_subbg.fit
Accfile=refcom.acc
CCDsize=3056
ejmin=300  #3056-(20sqrdegree*3600/29.8arcsec)/2 = 320 
#This makes sure that the effective FoV for one image is as larger as 20*20 sqr degrees
#The difference of 20 pixel makes that two ccds on one mount could be overlap even though the angle of 0.76 degrees  between two CCDs  
ejmax=`echo $CCDsize | awk '{print($1-ejmin)}' ejmin=$ejmin` 
crossRedius=1.5
diffmag=0.5
crossRedius_inner=1.5
crossRedius_outer=1.8
PSF_Critical_min=1.15
PSF_Critical_max=5.0
darkname=Dark.fit
flatname=Flat_bg.fit
dir_basicimage=/data2/workspace/basicfile
DIR_CVfile=/data2/workspace/cvfile
DIR_badpixlefile=/data2/workspace/badpixelfile
pixelscale=29.8 #arcsec
DETECT_TH=2.0
maglimitSigma=5.0
ra_imgCenter=`cat listemp_radecForImg | awk '{printf("%.6f\n",$1)}'`
dec_imgCenter=`cat listemp_radecForImg | awk '{printf("%.6f\n",$2)}'`


Nstar_ini_limit=2000  #The lower limit of star num. in the image
Nbgbright_ini_uplimit=30000 #The upper limit of background brightness
fwhm_uplimit=2.0
NumOT_center_max=100
#datenum=`date +%Y%m%d`
#Nf=0
#rm -rf matchchb.log matchchb_all.log
#rm -rf list2frame.list list_fin listnewskyot.list listOT listsky listsky1 listskyotfile listskyotfileHis listskyot.list listtemp listtime 
#rm -rf noupdate.flag listupdateimage.list listupdate_last5 listupdate crossoutput_skytemp
./xmknewfile.sh  # build a new directory for results
#========================================================================
xUploadImgStatusAndKeeplog (  )
{
    cat $MonitorParameterslog >>$stringtimeForMonitor
    xUploadImgStatus
    wait
}


xtimeCal ( )
{
    #timeobs=`gethead $FITFILE "T-OBS-UT"`
    date "+%H %M %S" >time_redu1
    time_need=`cat time_redu_f time_redu1 | tr '\n' ' ' | awk '{print(($4-$1)*3600+($5-$2)*60+($6-$3))}'`
    echo $time_need $FITFILE >>allxytimeNeed.cat
    cat -n allxytimeNeed.cat >allxytimeNeed.cat.plot
    sh xplottimeneed.sh $ID_MountCamara  
    wait 
    timeneedresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_timeneed.jpg")}'`
    mv Timeneed.jpg $timeneedresjpg
    curl $UploadParameterfile  -F fileUpload=@$timeneedresjpg
#    echo "TimeProcess=$time_need" >>$MonitorParameterslog
#    cat $MonitorParameterslog | tr ' ' '\n'  >temp
#    mv temp $MonitorParameterslog
    #curl $UploadParameterfile  -F fileUpload=@$MonitorParameterslog
    #./xatcopy_remoteimg.f $timeneedrespng  $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp  &
    echo "All were done in  $time_need sec"
    echo `date -u +%T` $timeobs $FITFILE $time_need >>$stringtimeForReduc
}

xdefinefilename ( )
{
    echo "xdefinefilename"
    ls $FITFILE >>listmatch.old
    echo `date +%s` >>listmatch.old
    allfile=`echo $FITFILE | sed 's/\.fit/.fit.*/'`
    otc2=`echo $FITFILE | sed 's/\.fit/.fit.otc2/'`
    FITFILE_subbg=`echo $FITFILE | sed 's/\.fit/_subbg.fit/'`
    OUTPUT=`echo $FITFILE | sed 's/\.fit/.fit.sex/'`	# output of SourceExtractor
    OUTPUT_ini=`echo $FITFILE | sed 's/\.fit/.fit.sexini/'`
    OUTPUT_new=`echo $FITFILE | sed 's/\.fit/.fit.sexnew/'`	# Catalog for the bright source. Output from $OUTPUT. Input for the xyxymatch
    OUTPUT_newfirst=`echo $FITFILE | sed 's/\.fit/.fit.sexnewfirst/'`
    imagetmp1sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp1sd/'`
    imagetmp2sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp2sd/'`	# output of the xyxymatch, input for geomap	
    imagetmp3sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp3sd/'`
    imagetrans1sd=`echo $FITFILE | sed 's/\.fit/.fit.trans1sd/'`
    imagetrans2sd=`echo $FITFILE | sed 's/\.fit/.fit.trans2sd/'`	# output of the geomap,
    imagetrans3sd=`echo $FITFILE | sed 's/\.fit/.fit.trans3sd/'`
    imagetrans3sd_re=`echo $FITFILE | sed 's/\.fit/.fit.trans3sd_re/'`
    inprefix=`echo $FITFILE | sed 's/\.fit//'`			# inprefix of the fit. it was used in the iraf.geomap and iraf.geoxytran
    
    crossoutput_xy=`echo $FITFILE | sed 's/\.fit/.fit.tempxyOT/'`	# Output of the Crossmatch in the temp frame. This code is writed by CHB. It is also the input for cctran.
    crossoutput_sky=`echo $FITFILE | sed 's/\.fit/.fit.skyOT/'`	# Output of the iraf.cctran. The input for this process is $crossoutput_xy. Catalog in which RA DEC are included, 
    newimageOTxyFis=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT1/'`  # Output of the iraf.geoxytran. The input for this process is $crossoutput_xy. Catalog in which xc,yc are includec in the new image frame.
    newimageOTxyThird=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT3/'`

    crossoutput_mag=`echo $FITFILE | sed 's/\.fit/.fit.tempMagOT/'`
    crossoutput_sky_mag=`echo $FITFILE | sed 's/\.fit/.fit.skymagOT/'`	# Output of the iraf.cctran. The input for this process is $crossoutput_xy. Catalog in which RA DEC are included, 
    newimageOTxyFis_mag=`echo $FITFILE | sed 's/\.fit/.fit.newxy_magOT1/'`  # Output of the iraf.geoxytran. The input for this process is $crossoutput_xy. Catalog in which xc,yc are includec in the new image frame.
    newimageOTxyThird_mag=`echo $FITFILE | sed 's/\.fit/.fit.newxy_magOT3/'`

    tempstandmagstarFis=`echo $FITFILE | sed 's/\.fit/.fit.standmag1/'`
    OUTPUT_fwhm=`echo $FITFILE | sed 's/\.fit/.fit.fwhm/'`			# Output of the FWHM caculation code xFwhmCal_single.sh. 
    OUTPUT_limitmag=`echo $FITFILE | sed 's/\.fit/.fit.limitmag/'`
    bg=`echo $FITFILE | sed 's/\.fit/.bg.fit/'`				# Output of the SourceExtractor. Background image for the new image. 
    OUTPUT_geoxytran1=`echo $FITFILE | sed 's/\.fit/.fit.tran1/'`
    OUTPUT_geoxytran3=`echo $FITFILE | sed 's/\.fit/.fit.tran3/'`
    newimgMaglimit=`echo $FITFILE | sed 's/\.fit/.fit.maglimitbin.png/'`
    xyxymatchResult=`echo $FITFILE | sed 's/\.fit/.fit.xyxymatchDeltaY.png/'`
    flux_calibration_png=`echo $FITFILE | sed 's/\.fit/.fit.fluxcali.png/'`
    MonitorParameterslog=`echo $FITFILE | sed 's/\.fit/.fit.monitorParaLog/'`
    imagetransfluxCali=`echo $FITFILE | sed 's/\.fit/.fit.imagetransfluxCali/'`
    imagetransFluxCaliPnG=`echo $FITFILE | sed 's/\.fit/.fit.imagetransfluxCali.png/'`
    echo $FITFILE 
}

xchangehe ( )
{
    echo "chang head" >> $stringtimeForMonitor
    delhead $FITFILE "OBSERVAT" "LATITUDE" "LONGITUD"
    cd $HOME/iraf
    cp -f login.cl.old login.cl
    echo noao >> login.cl
    echo astutil >> login.cl
    echo "cd $Dir_redufile" >> login.cl
    echo "setjd(\"$FITFILE\", date=\"D-OBS-UT\",time=\"T-OBS-UT\")" >>login.cl
    echo logout >> login.cl
    cl < login.cl >xlogfile
    cd $HOME/iraf
    cp -f login.cl.old login.cl
    cd $Dir_redufile
}
xprereduction ( )
{
    if [ ! -r $darkname ]
    then
        if [  -r $dir_basicimage/$darkname ]
        then
            cp $dir_basicimage/$darkname $Dir_redufile
            cp $dir_basicimage/badpixelFile.db $Dir_redufile
            echo "dark image copy and correcion"
            echo "dark image copy and correction" >>$stringtimeForMonitor
            ./xdarkcorr.sh $FITFILE $darkname
        else
            echo "No dark image for correction"
            echo "No dark image for correction" >>$stringtimeForMonitor
        fi
    else
        echo "dark image correction"
        echo "dark correction" >>$stringtimeForMonitor
        ./xdarkcorr.sh $FITFILE $darkname
    fi
    if [ ! -r $flatname ]
    then
        if [  -r $dir_basicimage/$flatname ]
        then
            cp $dir_basicimage/$flatname $Dir_redufile
            echo "flat copy and correction" >>$stringtimeForMonitor
            ./xflatcorr.sh $FITFILE $flatname
        else
            echo "No flat image for correction"
            echo "No flat image for correction" >>$stringtimeForMonitor
        fi

    else
        echo "flat correction" >>$stringtimeForMonitor
        ./xflatcorr.sh $FITFILE $flatname
    fi
}
xdeleteBeforeresult ( )
{
    rm -rf $allfile
}

xfits2jpg ( )
{
    ID_MountCamara=`gethead $FITFILE "IMAGEID"  | cut -c14-17`
    ccdimgjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_ccdimg.jpg")}'`
    python fits_cut_to_png.py $FITFILE_subbg $ccdimgjpg 1528 1528 1528 "" &
    wait
    convert -resize 50% $ccdimgjpg temp.jpg
    mv temp.jpg $ccdimgjpg
    curl $UploadParameterfile  -F fileUpload=@$ccdimgjpg
    #curl http://190.168.1.25/realTimeOtDstImageUpload  -F fileUpload=@$ccdimgjpg
    
        #./xatcopy_remoteimg.f $ccdimgjpg $IPforMonitorAndTemp ~/web &
    wait
    rm -rf $ccdimgjpg
}

xSentObjAndBgAndEllip (  )
{
    echo "Star num. is : " $NStar_ini
    rm -rf newbgbrightres.cat
    cat $OUTPUT_ini | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax)print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' ejmin=$ejmin ejmax=$ejmax >newbgbright.cat
   # ./xavbgbright 
   #wait
   ./xavbgbrightAndEllip  #output is the averagebg and average_ellip
   wait
    if test ! -s newbgbrightres.cat
    then
        echo "no result of bg brightness"
        continue
    else
        cat newbgbrightres.cat
        bgbrightness=`cat newbgbrightres.cat | awk '{printf("%.1f\n", $1)}'`
        avellip=`cat newbgbrightres.cat | awk '{printf("%.2f\n",$2)}'`
        echo "averaage bg brightness and ellipticity :  $bgbrightness , $avellip"
        echo $NStar_ini $bgbrightness $avellip $FITFILE >>allxyObjNumAndBgBrightAndavellip.cat

    fi    

    echo "=====to plot the obj and bg brightness ====="
    cat -n allxyObjNumAndBgBrightAndavellip.cat >allxyObjNumAndBgBrightAndavellip.cat.plot
    sh xplotobjAndBgAndEllip.sh $ID_MountCamara $Nstar_ini_limit $Nbgbright_ini_uplimit 
    wait
    objnumresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_objnum.jpg")}'`
    bgbrightresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_bgbright.jpg")}'`
    avellipresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_avellip.jpg")}'`
    mv objnum.jpg $objnumresjpg
    curl $UploadParameterfile  -F fileUpload=@$objnumresjpg
    #wait
    mv bgbright.jpg $bgbrightresjpg
    curl $UploadParameterfile  -F fileUpload=@$bgbrightresjpg
    mv avellip.jpg $avellipresjpg
    curl $UploadParameterfile  -F fileUpload=@$avellipresjpg
    #wait
    #    ./xatcopy_remoteimg4.f $fwhmrespng  $trackrespng  $limitmagrespng $rmsrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &
    #./xatcopy_remoteimg3.f $fwhmrespng  $trackrespng  $limitmagrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &
    #modified by xlp at 20150128
    #######./xatcopy_remoteimg2.f $objnumrespng  $bgbrightrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &

    #    ./xatcopy_remoteimg.f $trackrespng  $IPforMonitorAndTemp ~/webForTrack  &


}

xMakefalseValueFormonitor_TrackRMSFWHM (  )
{
    echo "Make a false value for Track, RMS and FWHM monitors"
    if test -s allxyshift.cat
    then
    	xshiftfalse=`tail -1 allxyshift.cat | awk '{print($1)}'`
    	yshiftfalse=`tail -1 allxyshift.cat | awk '{print($2)}'`
    else
	xshiftfalse=0.0
	yshiftfalse=0.0
    fi
    echo $xshiftfalse $yshiftfalse $FITFILE "false" >>allxyshift.cat
    cat -n allxyshift.cat >allxyshift.cat.plot
    cat allxyshift.cat.plot | grep "false" >allxyshiftfalse.cat.plot

    if test -s allxyrms.cat
    then
        xrmsfalse=`tail -1 allxyrms.cat | awk '{print($1)}'`
        yrmsfalse=`tail -1 allxyrms.cat | awk '{print($2)}'`
    else
	xrmsfalse=0.1
	yrmsfalse=0.1
    fi
    echo  $xrmsfalse $yrmsfalse $FITFILE "false" >>allxyrms.cat
    cat -n allxyrms.cat >allxyrms.cat.plot
    cat allxyrms.cat.plot | grep "false" >allxyrmsfalse.cat.plot
    sh xplottrackrms.sh $ID_MountCamara
    wait

    if test -s averagefile
    then
	firstfwhmfalse=`tail -1 averagefile | awk '{print($2)}'`
	secondfwhmfalse=`tail -1 averagefile | awk '{print($3)}'`
	thirdfwhmfalse=`tail -1 averagefile | awk '{print($4)}'`
    else
	firstfwhmfalse=0.0
        secondfwhmfalse=0.0
        thirdfwhmfalse=1.7
    fi	
    echo $FITFILE $firstfwhmfalse $secondfwhmfalse $thirdfwhmfalse "false" >>averagefile
    cat -n averagefile >allxyfwhm.cat.plot
    cat allxyfwhm.cat.plot | grep "false" >allxyfwhmfalse.cat.plot
    tail -1 allxyfwhm.cat.plot >fwhm_lastdata
    sh xplotfwhm.sh $ID_MountCamara
    wait 
}

xMakefalseValueFormonitor_LimitmagDiffmag (  )
{
    echo "Make a false value for limitmag and Diffmag monitors"
    if test -s allxyaveragelimit.cat
    then
	limitfalse=`tail -1 allxyaveragelimit.cat | awk '{print($1)}'`
    else
	limitfalse=12.0
    fi
    echo  $limitfalse $FITFILE "false" >>allxyaveragelimit.cat
    cat -n allxyaveragelimit.cat >allxyaveragelimitCol.cat.plot
    cat allxyaveragelimitCol.cat.plot | grep "false" >allxyaveragelimitfalseCol.cat.plot
    sh xplotLimitmag.sh $ID_MountCamara
    wait

    if test -s allxyDiffMag.cat
    then
	diffmagfalse=`tail -1 allxyDiffMag.cat | awk '{print($1)}'`
    else
	diffmagfalse=0.5
    fi
    echo $diffmagfalse $FITFILE "false" >>allxyDiffMag.cat
    cat -n allxyDiffMag.cat >allxyDiffMagCol.cat.plot
    cat allxyDiffMagCol.cat.plot | grep "false" >allxyDiffMagfalseCol.cat.plot
    sh xplotDiffExtincFromTemp.sh $ID_MountCamara
    wait
}

xProcessMonitorStatObjNumSmall (  )
{
    echo "This case shows that the  obj num is smaller than 3000 or bg is too bright"
    TimeProcessEnd=`date -u +%Y%m%d%H%M%S`
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Image=$FITFILE DirData=$DirData ra_mount=$ra_mount dec_mount=$dec_mount exptime=$exptime ra_imgCenter=$ra_imgCenter dec_imgCenter=$dec_imgCenter tempset=$tempset tempact=$tempact Fwhm=-99 ellipticity=$avellip xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Obj_Num=$NStar_ini bgbright=$bgbrightness AverDeltaMag=-99 AverLimit=-99 Extinc=-99 State=ObjNumSmall TimeProcess=$time_need TimeProcessEnd=$TimeProcessEnd" | tr ' ' '\n' >$MonitorParameterslog
}

xProcessMonitorStatReTrack (  )
{
    echo "This case shows that the ReTrack for the large rms after match"   
    TimeProcessEnd=`date -u +%Y%m%d%H%M%S`
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Image=$FITFILE DirData=$DirData ra_mount=$ra_mount dec_mount=$dec_mount exptime=$exptime ra_imgCenter=$ra_imgCenter dec_imgCenter=$dec_imgCenter tempset=$tempset tempact=$tempact Fwhm=-99 ellipticity=$avellip xshift=$xxshift yshift=$yyshift xrms=$xrms yrms=$yrms OC1=-99 VC1=-99 Obj_Num=$NStar_ini bgbright=$bgbrightness AverDeltaMag=-99 AverLimit=-99 Extinc=-99 State=Retrack TimeProcess=$time_need TimeProcessEnd=$TimeProcessEnd" | tr ' ' '\n' >$MonitorParameterslog
}
xProcessMonitorStatUpdateTemp (  )
{
    echo "This case shows the update for the temp"
    fwhmnow=`cat fwhm_lastdata | awk '{print($5)}'`
    TimeProcessEnd=`date -u +%Y%m%d%H%M%S`
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Image=$FITFILE DirData=$DirData ra_mount=$ra_mount dec_mount=$dec_mount exptime=$exptime ra_imgCenter=$ra_imgCenter dec_imgCenter=$dec_imgCenter tempset=$tempset tempact=$tempact Fwhm=$fwhmnow ellipticity=$avellip xshift=$xxshift yshift=$yyshift xrms=$xrms yrms=$yrms OC1=$NumOT VC1=$Num_Variable Obj_Num=$NStar_ini bgbright=$bgbrightness AverDeltaMag=$AverDeltaMag AverLimit=$averagelimit Extinc=-99 State=UpdateTemp TimeProcess=$time_need TimeProcessEnd=$TimeProcessEnd" | tr ' ' '\n' >$MonitorParameterslog
}    
xProcessMonitorStatUpdateTemp2 (  )
{
    echo "This case shows the update for the temp since the num of OT1 is larger than 30"
    fwhmnow=`cat fwhm_lastdata | awk '{print($5)}'`
    TimeProcessEnd=`date -u +%Y%m%d%H%M%S`
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Image=$FITFILE DirData=$DirData ra_mount=$ra_mount dec_mount=$dec_mount exptime=$exptime ra_imgCenter=$ra_imgCenter dec_imgCenter=$dec_imgCenter tempset=$tempset tempact=$tempact Fwhm=$fwhmnow ellipticity=$avellip xshift=$xxshift yshift=$yyshift xrms=$xrms yrms=$yrms OC1=$NumOT VC1=$Num_Variable Obj_Num=$NStar_ini bgbright=$bgbrightness AverDeltaMag=$AverDeltaMag AverLimit=$averagelimit Extinc=-99 State=LargeOT1 TimeProcess=$time_need TimeProcessEnd=$TimeProcessEnd" | tr ' ' '\n' >$MonitorParameterslog
}    

xProcessMonitorStatObjMonitor (  )
{
    echo "This case shows the Obj monitor"
    fwhmnow=`cat fwhm_lastdata | awk '{print($5)}'`
    TimeProcessEnd=`date -u +%Y%m%d%H%M%S`
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Image=$FITFILE DirData=$DirData ra_mount=$ra_mount dec_mount=$dec_mount exptime=$exptime ra_imgCenter=$ra_imgCenter dec_imgCenter=$dec_imgCenter tempset=$tempset tempact=$tempact Fwhm=$fwhmnow ellipticity=$avellip xshift=$xxshift yshift=$yyshift xrms=$xrms yrms=$yrms OC1=$NumOT VC1=$Num_Variable Obj_Num=$NStar_ini bgbright=$bgbrightness AverDeltaMag=$AverDeltaMag AverLimit=$averagelimit Extinc=-99 State=ObjMonitor TimeProcess=$time_need TimeProcessEnd=$TimeProcessEnd" | tr ' ' '\n' >$MonitorParameterslog
}    

xgetstars (  )
{
    sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH $DETECT_TH -ANALYSIS_THRESH $DETECT_TH -CATALOG_NAME $OUTPUT_ini -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $bg
    wc $OUTPUT_ini | awk '{print("Star_num  " $1)}' >>list_matchmatss
    wc $OUTPUT_ini | awk '{print("Star_num  " $1)}' >>$stringtimeForMonitor	
    NStar_ini=`cat $OUTPUT_ini | wc -l | awk '{printf("%.0f\n", $1)}'`
 #   bgbrightness=`head -1 $OUTPUT_ini | awk '{printf("%.0f\n",$5)}'`
    #ra1=`gethead $FITFILE "RA"`
    #dec1=`gethead $FITFILE "DEC"`

    cd $HOME/iraf
    cp -f login.cl.old login.cl
    echo noao >> login.cl
    echo digiphot >> login.cl
    echo image >> login.cl
    echo imcoords >>login.cl
    echo "cd $Dir_redufile" >> login.cl
    echo "imarith(\"$FITFILE\",\"-\",\"$bg\",\"$FITFILE_subbg\")" >>login.cl
    echo logout >> login.cl
    cl < login.cl>xlogfile
    cd $HOME/iraf
    cp -f login.cl.old login.cl
    cd $Dir_redufile	
    rm -rf $bg
    xfits2jpg &
    xSentObjAndBgAndEllip 
    #echo "Background brightness: " $bgbrightness
    if [ $NStar_ini -lt $Nstar_ini_limit ]
    then
        echo $FITFILE "Star num. is only: " $NStar_ini ", break" >>$stringtimeForMonitor
        ls $FITFILE >>xMissmatch.list
        #	if [ $NStar_ini -lt 3000 ] # cloudy or sunrise, moon phase
        #	then
        echo "The objects is too small,Star num: " $NStar_ini
        xInforMonitor
        xtimeCal
        xProcessMonitorStatObjNumSmall
        xUploadImgStatusAndKeeplog
        xMakefalseValueFormonitor_TrackRMSFWHM
	wait
        xMakefalseValueFormonitor_LimitmagDiffmag
	wait
        xSentFwhmAndTrack
	wait
        break
        #	else
        #		./xFwhmCal_noMatch.sh $Dir_redufile $FITFILE
        #		xtimeCal
        #        	break
        #	fi
    else 
        if [ ` echo " $bgbrightness > $Nbgbright_ini_uplimit " | bc ` -eq 1  ]
        #if [ $bgbrightness -gt $Nbgbright_ini_uplimit ] #if the brightness of background is too high, This image shall not reduced and no output for the FWHM
        then
            echo "Background is too brightness: " $bgbrightness
            echo $FITFILE "Background is too brightness: " $bgbrightness >>$stringtimeForMonitor
            ls $FITFILE >>xMissmatch.lis
            xInforMonitor
            xtimeCal
            xProcessMonitorStatObjNumSmall
            xUploadImgStatusAndKeeplog
            xMakefalseValueFormonitor_TrackRMSFWHM
	    wait
            xMakefalseValueFormonitor_LimitmagDiffmag
	    wait
            xSentFwhmAndTrack
	    wait
            break
            #	elif  [ $bgbrightness -gt $Nbgbright_ini_lowlimit ] #output the  
            #	then
            #		echo "Background is too brightness: " $bgbrightness
            #                echo "Background is too brightness: " $bgbrightness >>$stringtimeForMonitor	
            #		./xFwhmCal_noMatch.sh $Dir_redufile $FITFILE
            #		xtimeCal
            #		break
        fi
    fi

}

xreTrack (  )
{
    ls $FITFILE >>xNomatch.flag
    #./xFwhmCal_noMatch.sh $Dir_redufile $FITFILE & 
    Nnomatchimg=`cat xNomatch.flag | wc -l | awk '{print($1)}'`
    if [  $Nnomatchimg -gt 20   ]
    then
        #sethead -kr X TODO=ReTrack $FITFILE
        #	mkdir xNomatch_lot6c2.py.flag
        RaTemp=`gethead $tempfile "RaTemp"` 
        DecTemp=`gethead $tempfile "DecTemp"`
        #get the RA and DEC in the head of refcom.fit. The two keywords are the real pointing of FoV of the image, which was calculated by lot6c2.py and restorted in the *cencc1, and then rewrited into the head of refcom.fit
        sethead -kr X TODO=ReTrack RaTemp=$RaTemp DecTemp=$DecTemp $FITFILE 
        #xatcopy_reTrack.f $FITFILE
        ipadress=`ifconfig | grep "inet" |  awk '{if($5=="broadcast")print($2)}'`
        ipfile=`echo "ip_address_"$ID_MountCamara".dat"`
        echo $ipadress $Dir_temp >$ipfile
        echo "copy the combined image to the temp making computer" >>$stringtimeForMonitor
        ./xatcopy_remoteimg2.f $ipfile $FITFILE  $temp_ip $temp_dir"/"$ID_MountCamara
        wait
        rm -rf xNomatch.flag
    else
        echo "The Num. of unmatched image are: "$Nnomatchimg
    fi
    echo $xxshift $yyshift $FITFILE >>allxyshift.cat 
    echo $xrms $yrms $FITFILE >>allxyrms.cat 
    cat -n allxyshift.cat >allxyshift.cat.plot
    cat -n allxyrms.cat >allxyrms.cat.plot
    sh xplottrackrms.sh $ID_MountCamara 
     wait
    xInforMonitor
    xtimeCal
    xProcessMonitorStatReTrack
    xUploadImgStatusAndKeeplog
    xMakefalseValueFormonitor_LimitmagDiffmag
    wait
    xSentFwhmAndTrack
     wait
    rm -rf $allfile
    break
}

xmatchimgtempFailed (  )
{

    touch deletenewxyshift.cat
    tail -1 list_matchmatss >>$stringtimeForMonitor
    echo "rms is too much larger,image match faild"
    xreTrack
    #./xFwhmCal_noMatch.sh $Dir_redufile $FITFILE
    #xtimeCal
    #break
    #rm -rf $allfile

}


xmatchimgtemp ( )
{

    #=========================================================================
    #	echo `date` "1sh match obj extracted"
    xNpixel=`gethead $FITFILE "NAXIS1"`
    yNpixel=`gethead $FITFILE "NAXIS2"`		
    #=========================================================	
    #modified by xlp at 20140326
    #get the initial shift from the last newshift named by newxyshift.cat 
    #for the image coordinates 
    if test -r deletenewxyshift.cat
    then
        rm -rf newxyshift.cat
    fi
    if test -s newxyshift.cat
    then
        echo "have newxyshift.cat"
        cp newxyshift.cat newxyshift.cat.bak
        xshift0=`cat newxyshift.cat | awk '{print($1)}'`
        yshift0=`cat newxyshift.cat | awk '{print($2)}'`
        echo $xshift0 $yshift0
        toleranceradius=30
    else  #the first img for the day
        echo "No newxyshift.cat"
        echo 0 0 >newxyshift.cat
        cp newxyshift.cat newxyshift.cat.bak
        xshift0=0
        yshift0=0
        toleranceradius=60
    fi
    cat $OUTPUT_ini | awk '{if(($1-xshift0)>ejmin && ($1-xshift0)<ejmax && $1>ejmin && $1<ejmax && ($2-yshift0)>ejmin && ($2-yshift0)<ejmax && $2>ejmin && $2<ejmax )print($1-xshift0,$2-yshift0,$3,$4,$5,$6,$7,$8,$9,$10)}' ejmin=$ejmin ejmax=$ejmax xshift0=$xshift0 yshift0=$yshift0 > $OUTPUT
    cat $OUTPUT | sort -n -k 7 | head -1000 | awk '{print($1,$2,$3)}' > $OUTPUT_newfirst

    #========================================================
    #	echo `date` "The first tolerance match will be going on"
    matchflag=tolerance
    fitorder=4
    echo "First tolerance with  fitorder:"$fitorder
    tempmatchstars=GwacStandall.cat

    #=======================================================
    echo `date` "First tolerance match"
    rm -rf $imagetmp3sd
    cd $HOME/iraf
    cp -f login.cl.old login.cl
    echo noao >> login.cl
    echo image >> login.cl
    echo "cd $Dir_redufile" >> login.cl
    echo "xyxymatch(\"$OUTPUT_newfirst\",\"$tempmatchstars\", \"$imagetmp3sd\",toleranc=$toleranceradius, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=7, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
    echo "geomap(\"$imagetmp3sd\", \"$imagetrans3sd\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$yNpixel,fitgeom=\"general\", functio=\"legendre\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", maxiter=5,reject=3,inter-)" >>login.cl
    echo logout >> login.cl
    cl < login.cl >xlogfile
    cd $HOME/iraf
    cp -f login.cl.old login.cl
    cd $Dir_redufile
    xrms=`cat $imagetrans3sd | grep "xrms" | awk '{print($2)}'`
    yrms=`cat $imagetrans3sd | grep "yrms" | awk '{print($2)}'`
    xxshift=`cat $imagetrans3sd | grep "xshift" | awk '{print($2)}'`
    yyshift=`cat $imagetrans3sd | grep "yshift" | awk '{print($2)}'`
    if test -r $imagetrans3sd
    then
        #		echo "First xyxymatch with tolerance is finished!"
        xrms=`cat $imagetrans3sd | grep "xrms"  | awk '{print($2)}'`
        yrms=`cat $imagetrans3sd | grep "yrms"  | awk '{print($2)}'`
        echo `cat $imagetrans3sd | grep "shift"`
        echo $xrms $yrms
        Ntemp3sd=`cat $imagetmp3sd | wc -l | awk '{print($1)}'`
        #============================
        #	to check wether the match is good enough or not by rms at X-axis and Y-axis.
        if [ ` echo " $xrms > 0.13 " | bc ` -eq 1 ] || [ ` echo " $yrms > 0.13 " | bc ` -eq 1 ] || [ ` echo " $Ntemp3sd < 100.0 " | bc ` -eq 1 ] # if not good enough
        then
            echo "xrms or yrms is not good for the first tolerance match"
            rm -rf $imagetrans3sd
            cat $OUTPUT | awk '{if(($3-$5)/$6>20) print($1,$2,$3,$4,$5,$6,$7)}' | column -t >allres0
            matchflag=triangles
            Nbstar=10 #set 10*10 regions to extract the bright stars to match each other
            Ng=2
            fitorder=2
            toleranceredius=60
            tempmatchstars=refcom1d.cat
            xNb=`echo $xNpixel $Nbstar | awk '{print(int($1/$2))}'`
            yNb=`echo $yNpixel $Nbstar | awk '{print(int($1/$2))}'`
            for((i=$Ng;i<($Nbstar-$Ng);i++))
            do
                for((j=$Ng;j<($Nbstar-$Ng);j++))
                do
                    cat allres0 | awk '{if( (xnb*i)<$1 && $1<=(xnb*(i+1))  &&    (ynb*j)<$2 && $2<=(ynb*(j+1))) print($1,$2,$3)}' i=$i j=$j xnb=$xNb ynb=$yNb | sort -n -r -k 3 | head -5 | column -t >>$OUTPUT_new
                done
            done

            cd $HOME/iraf
            cp -f login.cl.old login.cl
            echo noao >> login.cl
            echo image >>login.cl
            echo "cd $Dir_redufile" >> login.cl
            echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"$imagetmp1sd\",toleranc=$toleranceredius, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=7, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
            echo "geomap(\"$imagetmp1sd\", \"$imagetrans1sd\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"legendre\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", maxiter=5,reject=3,inter-)" >>login.cl
            echo "geoxytran(\"$OUTPUT\", \"$OUTPUT_geoxytran1\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
            echo logout >> login.cl
            cl < login.cl >xlogfile
            cd $HOME/iraf
            cp -f login.cl.old login.cl
            cd $Dir_redufile
            #		        mv mattmp $imagetmp1sd
            #		        mv transform.db $imagetrans1sd
            echo "for imagetrans1sd,rms:"
            xrms=`cat $imagetrans1sd | grep "xrms" | awk '{print($2)}'`
            yrms=`cat $imagetrans1sd | grep "yrms" | awk '{print($2)}'`
            xxshift=`cat $imagetrans1sd | grep "xshift" | awk '{print($2)}'`
            yyshift=`cat $imagetrans1sd | grep "yshift" | awk '{print($2)}'`
            echo $xrms $yrms
            #=============================
            if [ ` echo " $xrms > 5.0 " | bc ` -eq 1  ] || [ ` echo " $yrms > 5.0 " | bc ` -eq 1  ]  # if not good enough
            then
                echo "rms after triangle match is too much, this image will be given up."
                echo $FITFILE `cat newxyshift.cat` `cat $imagetrans3sd | grep "rms"` "2times" >>list_matchmatss
                xmatchimgtempFailed
            fi
            #==============================
            rm -rf $OUTPUT_new
            cat $OUTPUT_geoxytran1 | awk '{if(($3-$5)/$6>20) print($1,$2,$3,$4,$5,$6,$7)}' | column -t >allres0
            Nbstar=30
            xNb=`echo $xNpixel $Nbstar | awk '{print(int($1/$2))}'`
            yNb=`echo $yNpixel $Nbstar | awk '{print(int($1/$2))}'`
            for((i=$Ng;i<($Nbstar-$Ng);i++))
            do
                for((j=$Ng;j<($Nbstar-$Ng);j++))
                do
                    cat allres0 | awk '{if( (xnb*i)<$1 && $1<=(xnb*(i+1))  &&    (ynb*j)<$2 && $2<=(ynb*(j+1))) print($1,$2,$3)}' i=$i j=$j xnb=$xNb ynb=$yNb | sort -n -r -k 3 | head -10 | column -t >>$OUTPUT_new 
                done
            done

            matchflag=tolerance
            tempmatchstars=GwacStandall.cat
            fitorder=4
            toleranceradius=`echo $xrms $yrms | awk '{print(50*($1+$2))}'`	
            echo $toleranceradius
            rm -rf $imagetmp3sd $OUTPUT_geoxytran3
            cp $OUTPUT_new testnew.dat
            cd $HOME/iraf
            cp -f login.cl.old login.cl
            echo noao >> login.cl
            echo image >>login.cl
            echo "cd $Dir_redufile" >> login.cl
            echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"$imagetmp3sd\",toleranc=$toleranceradius, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=5, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
            echo "geomap(\"$imagetmp3sd\", \"$imagetrans3sd\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"legendre\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", maxiter=5,reject=3,inter-)" >>login.cl
            echo "geoxytran(\"$OUTPUT_geoxytran1\", \"$OUTPUT_geoxytran3\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
            echo logout >> login.cl
            cl < login.cl >xlogfile
            #cl < login.cl
            cd $HOME/iraf
            cp -f login.cl.old login.cl
            cd $Dir_redufile
            if test -s $imagetrans3sd
            then
                echo "for tolerance imagetrans3sd,rms:"
                cat $imagetrans3sd | grep "rms" | awk '{print($2)}' 
                xrms=`cat $imagetrans3sd | grep "xrms"  | awk '{print($2)}'`
                yrms=`cat $imagetrans3sd | grep "yrms"  | awk '{print($2)}'`
                Ntemp3sd=`cat $imagetmp3sd | wc -l | awk '{print($1)}'`
                if [ ` echo " $xrms < 0.13 " | bc ` -eq 1 ] && [ ` echo " $yrms < 0.13 " | bc ` -eq 1 ] && [ ` echo " $Ntemp3sd > 100 " | bc ` -eq 1 ]
                then	
                    echo "image match successful"
                    rm deletenewxyshift.cat
                    xshift1=`cat $imagetrans1sd | grep "xshift" | awk '{print($2)}'`
                    yshift1=`cat $imagetrans1sd | grep "yshift" | awk '{print($2)}'`
                    xshift3=`cat $imagetrans3sd | grep "xshift" | awk '{print($2)}'`
                    yshift3=`cat $imagetrans3sd | grep "yshift" | awk '{print($2)}'`
                    cat newxyshift.cat | awk '{print($1+xshift1+xshift3,$2+yshift1+yshift3)}' xshift1=$xshift1 xshift3=$xshift3 yshift1=$yshift1 yshift3=$yshift3 >temp
                    mv temp newxyshift.cat
                    echo "final xyshift are: "
                    cat newxyshift.cat
                    #====================
                    #reconstrut the imagetemp3sd for the FWHM calculation
                    sed -n '1,15p' $imagetmp3sd >temp
                    sed -n '16,1000p' $imagetmp3sd | awk '{print($1,$2,$3+xshift+xshift0,$4+yshift1+yshift0,$5,$6)}' xshift1=$xshift1 yshift1=$yshift1 xshift0=$xshift0 yshift0=$yshift0 >>temp
                    mv temp $imagetmp3sd
                    #=====================
                    #reconstruct the imagetran3sd for the subimage calculation
                    xxshift=`cat newxyshift.cat | awk '{print($1)}'`
                    yyshift=`cat newxyshift.cat | awk '{print($2)}'`
                    xmag1=`cat $imagetrans1sd | grep "xmag" | awk '{print($2)}'`
                    ymag1=`cat $imagetrans1sd | grep "ymag" | awk '{print($2)}'`
                    xmag3=`cat $imagetrans3sd | grep "xmag" | awk '{print($2)}'`
                    ymag3=`cat $imagetrans3sd | grep "ymag" | awk '{print($2)}'`
                    xxmag=`echo $xmag1  $xmag3 | awk '{print(($1+$2)/2)}'`
                    yymag=`echo $ymag1  $ymag3 | awk '{print(($1+$2)/2)}'`
                    xrotation1=`cat $imagetrans1sd | grep "xrotation" | awk '{print($2)}'`
                    yrotation1=`cat $imagetrans1sd | grep "yrotation" | awk '{print($2)}'`
                    xrotation3=`cat $imagetrans3sd | grep "xrotation" | awk '{print($2)}'`
                    yrotation3=`cat $imagetrans3sd | grep "yrotation" | awk '{print($2)}'`
                    xxrotation=`echo $xrotation1 $xrotation3 | awk '{print(($1+$2)-360)}'`
                    yyrotation=`echo $yrotation1 $yrotation3 | awk '{print(($1+$2)-360)}'`
                    sed -n '1,8p' $imagetrans1sd >newfile1
                    echo "  	xshift          "$xxshift >>newfile1
                    echo "  	yshift          "$yyshift >>newfile1
                    echo "  	xmag            "$xxmag   >>newfile1
                    echo "        ymag            "$yymag   >>newfile1
                    echo "        xxrotation      "$xxrotation   >>newfile1
                    echo "        yyrotation      "$yyrotation   >>newfile1
                    sed -n '15,100p' $imagetrans3sd >>newfile1
                    # the three lines are used for ply when doing the geomap
                    #sed -n '15,25p' $imagetrans3sd >>newfile1
                    # echo "                  	"$xxshift $yyshift >>newfile1
                    #sed -n '27,100p' $imagetrans3sd >>newfile1
                    mv newfile1 $imagetrans3sd_re
                    #=====================
                    echo $FITFILE `cat newxyshift.cat` `cat $imagetrans3sd | grep "rms"` "3times" >>list_matchmatss
                    tail -1 list_matchmatss >>$stringtimeForMonitor
                    echo $xxshift $yyshift $FITFILE >>allxyshift.cat
                    echo $xrms $yrms $FITFILE >>allxyrms.cat
                    rm -rf xNomatch.flag 
                    #	rm xNomatch_lot6c2.py.flag
                else
                    echo $FITFILE `cat newxyshift.cat` `cat $imagetrans3sd | grep "rms"` "3times" >>list_matchmatss
                    xmatchimgtempFailed 
                fi
            else #faild
                echo "No $imagetrans3sd created for the third match"
                echo "xyxymatch failed 3times,No $imagetrans3sd created for the third match" >>$stringtimeForMonitor
                ls $FITFILE >>xMissmatch.list
                xreTrack	
                #	rm -rf $allfile
                #	./xFwhmCal_noMatch.sh $Dir_redufile $FITFILE
                #	xtimeCal
                #	break
            fi
        else #success
            rm deletenewxyshift.cat
            rm -rf xNomatch.flag 
            #	rm xNomatch_lot6c2.py.flag
            cat $imagetrans3sd | grep "shift" | awk '{print($2)}' |  tr '\n' '  ' > temp
            cat temp | awk '{print($1+xshift0,$2+yshift0)}' xshift0=$xshift0 yshift0=$yshift0 >newxyshift.cat
            echo "final xyshift are: "
            cat newxyshift.cat
            xxshift=`cat newxyshift.cat | awk '{print($1)}'`
            yyshift=`cat newxyshift.cat | awk '{print($2)}'`
            sed -n '1,8p' $imagetrans3sd >newfile1
            echo "        xshift          "$xxshift >>newfile1
            echo "        yshift          "$yyshift >>newfile1
            sed -n '11,100p' $imagetrans3sd >>newfile1
            #sed -n '11,25p' $imagetrans3sd >>newfile1
            #  echo "                        "$xxshift $yyshift >>newfile1 # the two lines are used for poly when geomap 
            #                        sed -n '27,100p' $imagetrans3sd >>newfile1
            mv newfile1 $imagetrans3sd_re
            echo $FITFILE `cat newxyshift.cat` `cat $imagetrans3sd | grep "rms"` "1times" >>list_matchmatss
            tail -1 list_matchmatss >>$stringtimeForMonitor
            echo $xxshift $yyshift $FITFILE >>allxyshift.cat
            echo $xrms $yrms $FITFILE >>allxyrms.cat
        fi
    else

        echo "No $imagetrans3sd created for the first match"
        echo "xyxymatch failed 1times,no $imagetrans3sd created for the first match" >>$stringtimeForMonitor
        ls $FITFILE >>xMissmatch.list
        xreTrack
        #	rm -rf $allfile
        #	./xFwhmCal_noMatch.sh $Dir_redufile $FITFILE
        #	xtimeCal
        #       break

    fi

    # transform the xy of new image to temp.
    if test -r $OUTPUT_geoxytran3
    then
        echo "All xytran from image to temp finished"
    else
        echo `date` "All xytran from image to temp"
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $Dir_redufile" >> login.cl
        echo "geoxytran(\"$OUTPUT\", \"$OUTPUT_geoxytran3\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $Dir_redufile
    fi

}

xplotxyxymatchresult ( )  #not used any more
{
    #sed -n '16,1000p' $imagetmp3sd | awk '{print($1,$2,sqrt(($1-$3)**2+($2-$4)**2))}' xxshift=$xxshift yyshift=$yyshift >xymatch.cat
    #sed -n '16,1000p' $imagetmp3sd | awk '{print($1,$2,$1-$3-xxshift)}' xxshift=$xxshift  >xymatch.cat
    #sed -n '16,1000p' $imagetmp3sd | awk '{print($1,$2,$2-$4-yyshift)}' yyshift=$yyshift  >xymatch.cat
    sed -n '16,1000p' $imagetmp3sd | awk '{print($1,$2,$2-$4)}' >xymatch.cat
gnuplot << EOF
set term png
set output "$xyxymatchResult"

set xlabel "x-axis (pixel)"
set ylabel "y-axis (pixel)"
set zlabel "Delta xy"
set contour base
set dgrid3d
#set view 60,60
set view 0,0
#set cntrparam levels 10
#set cntrparam levels incremental 2, 0.5, 7
#set cntrparam levels incremental 0, 0.2, 5
#set cntrparam levels discrete -0.2, -0.5, 0.2, 0.5
set pm3d at b
splot [][][] "xymatch.cat" u 1:2:3 with lines
EOF
    displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
    kill -9 $displayPadNum
    display $xyxymatchResult &
}


xMultiAreaFluxCali ( )
{
            Nbstar=4 #set 4*4 regions to extract the bright stars to match each other
            Ng=0
            xNb=`echo $xNpixel $Nbstar | awk '{print(int($1/$2))}'`
            yNb=`echo $yNpixel $Nbstar | awk '{print(int($1/$2))}'`
            for((i=$Ng;i<($Nbstar-$Ng);i++))
            do
                for((j=$Ng;j<($Nbstar-$Ng);j++))
                do
                    cat refsmall_new | awk '{if( (xnb*i)<$1 && $1<=(xnb*(i+1))  &&    (ynb*j)<$2 && $2<=(ynb*(j+1))) print($1,$2,$3,$4,$5,$6)}' i=$i j=$j xnb=$xNb ynb=$yNb  column -t >>MultiAreaFluxCali_$i$j

gnuplot << EOF
set term png
set output "$flux_calibration_png"
set xlabel "mag in new image"
set ylabel "mag in temp image"
set grid
set key left
f(x)=a*x+b
a=1
fit [13:5][13:5] f(x) 'MultiAreaFluxCali_$i$j' u 6:3 via b  
plot [14:5][14:5]'MultiAreaFluxCali_$i$j' u 6:3 t 'mag-mag',f(x)
quit
EOF

#in the gnuplot, a=1 is aiming to make the correct fit .
#cp fit.log fit.log.bak
#when fit above with only b
aa=1
bb=`cat fit.log | tail -7 | head -1 | awk '{print($3)}'`

#when fit above, via a,b,  the values of aa and bb are in the following
#aa=`cat fit.log | tail -9 | head -1 | awk '{print($3)}'`
#bb=`cat fit.log | tail -8 | head -1 | awk '{print($3)}'`
echo "the transformation format is f(x)="$aa"*x+"$bb

Xcenter=`echo $xNb $i | awk '{print($1*(1+2*$2)/2)}'`
Ycenter=`echo $yNb $j | awk '{print($1*(1+2*$2)/2)}'`

echo "f(x)= $aa *x+ $bb  $Xcenter  $Ycenter" >>$imagetransfluxCali
#instrumental magnitude is x, with the f(x), these magnitude could be transfermed to the standard R2 mag.
#mv newOTT.cat limitnewOT.cat
rm -rf fit.log 
cat $OUTPUT_geoxytran3 | awk '{print($1,$2,$3,$4,$5,$6,aa*$7+bb,$8,$9,$10)}' aa=$aa bb=$bb >>temp
                done
            done

 mv temp $OUTPUT_geoxytran3

gnuplot << EOF
set term png
set output "$imagetransFluxCaliPnG"

set xlabel "x-axis (pixel)"
set ylabel "y-axis (pixel)"
set zlabel "DeltaMag"
set contour base
set dgrid3d
#set view 60,60
set view 0,0
#set cntrparam levels 10
#set cntrparam levels incremental 2, 0.5, 7
#set cntrparam levels incremental 0, 0.2, 5
#set cntrparam levels discrete -0.2, -0.5, 0.2, 0.5
set pm3d at b
splot [][][] "$imagetransfluxCali" u 5:6:4 with lines
EOF



}


xfluxcalibration ( )
{
    echo "flux calibration"
    cat $OUTPUT_geoxytran3 | awk '{if($1>20 && $2>20 && $1<3020 && $2<3020) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}'| sort -n -k 7 | head -10000 | awk '{print($1,$2,$7)}' > obj.db
    cp $tempmatchstars_mag ref.db
    #       wc ref.db
    #       wc obj.db
    ./fluxmatch #output is refsmall_new
#    echo `date` "caculate the different magnitude"
#    #        wc refsmall_new
#    for((i=0;i<5;i++))
#    do
#        wc refsmall_new | awk '{print($1)}' >flux_res
#        cat refsmall_new | awk 'BEGIN{total=0}{total=total+($3-$6)}END{print total }' >>flux_res
#        cat flux_res | tr '\n' ' ' >flux_res1
#        AverDeltaMag=`cat flux_res1 | awk '{print($2/$1)}'` #模板流量比目标图像流量O2A mag
#    done
#    rm -rf flux_res flux_res1
#    echo "AverDeltaMag="$AverDeltaMag
#    echo "AverDeltaMag="$AverDeltaMag >>$stringtimeForMonitor
#    cat $OUTPUT_geoxytran3 | awk '{print($1,$2,$3,$4,$5,$6,$7+AverDeltaMag,$8,$9,$10)}' AverDeltaMag=$AverDeltaMag >temp
#    mv temp $OUTPUT_geoxytran3
#    echo $AverDeltaMag $FITFILE >>allxyDiffMag.cat
#    cat -n allxyDiffMag.cat >allxyDiffMagCol.cat.plot
#    sh xplotDiffExtincFromTemp.sh $ID_MountCamara
#==============================
gnuplot << EOF
set term png
set output "$flux_calibration_png"
set xlabel "mag in new image"
set ylabel "mag in temp image"
set grid
set key left
f(x)=a*x+b
a=1
fit [13:5][13:5] f(x) 'refsmall_new' u 6:3 via b  
plot [14:5][14:5]'refsmall_new' u 6:3 t 'mag-mag',f(x)
quit
EOF

#in the gnuplot, a=1 is aiming to make the correct fit .
#cp fit.log fit.log.bak
#when fit above with only b
aa=1
bb=`cat fit.log | tail -7 | head -1 | awk '{print($3)}'`

#when fit above, via a,b,  the values of aa and bb are in the following
#aa=`cat fit.log | tail -9 | head -1 | awk '{print($3)}'`
#bb=`cat fit.log | tail -8 | head -1 | awk '{print($3)}'`
echo "the transformation format is f(x)="$aa"*x+"$bb
echo "f(x)="$aa"*x+"$bb >imagetrans.cat
#instrumental magnitude is x, with the f(x), these magnitude could be transfermed to the standard R2 mag.
#mv newOTT.cat limitnewOT.cat
rm -rf fit.log 
###=========================
### The following two lines are replaced by function xMultiAreaFluxCali
### xlp at 20150804
cat $OUTPUT_geoxytran3 | awk '{print($1,$2,$3,$4,$5,$6,aa*$7+bb,$8,$9,$10)}' aa=$aa bb=$bb >temp
 mv temp $OUTPUT_geoxytran3
###==============================
AverDeltaMag=`echo $bb`
 echo $AverDeltaMag $FITFILE >>allxyDiffMag.cat
 cat -n allxyDiffMag.cat >allxyDiffMagCol.cat.plot
 sh xplotDiffExtincFromTemp.sh $ID_MountCamara

#xMultiAreaFluxCali

}

xlimitmagcal_magbin (  )
{
    #======================
    #	modefied by xlp at 20140929
    if test ! -r refall_magbin.cat
    then
    	echo "no refall_magbin.cat"
    else
         rm -rf outputlimit.cat newimg_magbin.cat newrefall_maglimit.res.cat
         cat $OUTPUT_geoxytran3 | awk '{print($1,$2,$7)}' | sort -n -k 3 >outputlimit.cat
         ./xlimit_newimg	#output is newimg_magbin.cat
         paste newimg_maglimit.cat refall_magbin.cat >newrefall_maglimit.cat
         cat newrefall_maglimit.cat | awk '{if($4>0)print($1,($2/$4)}' >newrefall_maglimit.res.cat
#         LimitFromMagbin=`cat newrefall_maglimit.res.cat | awk '{if($2>0.45 && $2<0.55)print($2)}'`
         sh xlimit_newimg_magbin.sh $newimgMaglimit
    fi
    #gnuplot << EOF
#set term png
#set output "$newimgMaglimit"
#set xlabel "Magnitude"
#set ylabel "Ratio of detected stars to full number of USNO B2 stars"
#set grid
#set key left
#f(x)=a*x+b
#fit [][0.2:0.6] f(x) 'newrefall_maglimit.res.cat' u 1:2 via a,b  
#plot [8:14][0:1]'newrefall_maglimit.res.cat' u 1:2 t '0.1magbin',f(x) t 'fit[0.2:0.6]'
#quit
#EOF
    #displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
    #kill -9 $displayPadNum
    #display -resize 300x300+0+0 $newimgMaglimit &
   # fi

    
    
    #=======================		
    #modified by xlp at 20141030
    #	#to calculate the limit magnitude, it is roughly right
    #	if test -r refcom_avermaglimit.cat
    #	then
    #	#	cat refcom_avermaglimit.cat | awk '{print($1-O2A)}' O2A=$O2A >$OUTPUT_limitmag
    #		newlimitmag=`cat refcom_avermaglimit.cat | awk '{print($1+O2A)}' O2A=$O2A`
    #		echo "limit magnitude: "$newlimitmag
    #		echo $newlimitmag >>list_matchmatss
    #		echo "limit magnitude: "$newlimitmag >>$stringtimeForMonitor
    #	else
    #		echo 8 >>list_matchmatss
    #		echo "No refcom_avermaglimit.cat, cannot calculate the limit magnitude"
    #	fi
    #       	
    #=========================
}

xlimitmagcal ( )
{
    cat  $OUTPUT_geoxytran3 | awk '{if($1>20 && $2>20 && $1<3020 && $2<3020 && $8<0.2 && $8>0.05)print($1,$2,$7+2.512*log($3*DETECT_TH/$6/sqrt(4)/maglimitSigma)/log(10))}'  DETECT_TH=$DETECT_TH maglimitSigma=$maglimitSigma >newimg_maglimit.cat  # area=4 for aperature phot
    if test -r newimg_maglimit_result.cat
    then
        rm -rf newimg_maglimit_result.cat	
    fi
    ./xmaglimitcal
    averagelimit=`cat newimg_maglimit_result.cat | awk '{print($1)}'`
    echo "average for the" $maglimitSigma  " sigma limit R magnitude:" $averagelimit >>$stringtimeForMonitor
    echo $averagelimit $FITFILE >>allxyaveragelimit.cat
    cat -n allxyaveragelimit.cat >allxyaveragelimitCol.cat.plot
    sh xplotLimitmag.sh $ID_MountCamara
   # gnuplot xplotLimitmag.gn &

    #	sum=0
    #	for R2limitmag in `cat newimg_maglimit.cat | awk '{print($3)}'`
    #	do
    #	        sum1=`echo $sum $R2limitmag | awk '{print($1+$2)}'`
    #	        sum=`echo $sum1`
    #	        j=`echo $i | awk '{print($1+1)}'`
    #	        i=`echo $j`
    #	done
    #	averagelimit=`echo $sum $i | awk '{print($1/$2)}'`
    #	echo "average for the" $maglimitSigma  " sigma limit R magnitude:" $averagelimit
    #	echo $averagelimit >>list_matchmatss
    #	echo "average for the" $maglimitSigma  " sigma limit R magnitude:" $averagelimit >>$stringtimeForMonitor
    #	rm -rf newimg_maglimit.cat
    #==========================================	
}

xcrossmatchwith2radius (  )
{
echo `date` "crossmatchD"  # cross match between new image and temp in XY spece.
echo $crossRedius_inner $crossRedius_outer
./xnewCrossMatchD $crossRedius_inner $crossRedius_outer $OUTPUT_geoxytran3 $Alltemplatetable $crossoutput_xy
cat $crossoutput_xy | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax && $13==1) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' ejmin=$ejmin ejmax=$ejmax | grep -v "99.000" >temp 
 mv temp $crossoutput_xy 
}
xcrossmatchwithR1Merr1 ( ) 
{
    #======================================================
    echo `date` "crossmatch"  # cross match between new image and temp in XY spece.
    echo $crossRedius $diffmag
    ./xnewCrossMatchF $crossRedius $diffmag $OUTPUT_geoxytran3 $AlltemplatetableForVariable $crossoutput_xy
    cat $crossoutput_xy | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax && $8<0.3 &&$9<1.0 && $13==2) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)}' ejmin=$ejmin ejmax=$ejmax | grep -v "99.000" >$crossoutput_mag   # new variables  $9 is the ellipticity if $9==1 it would be hot pixel
    rm $crossoutput_xy
    ./xnewCrossMatchF $crossRedius $diffmag $OUTPUT_geoxytran3 $Alltemplatetable $crossoutput_xy
    cat $crossoutput_xy | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax && $8<0.3 && $9<0.6 && $13==1) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' ejmin=$ejmin ejmax=$ejmax | grep -v "99.000" >temp  
# $9<0.4 is to filter those moving object which is overlap with some stars

    mv temp $crossoutput_xy  #new ot candidates 
    #        NumOT=`wc $crossoutput_xy | awk '{print($1)}'`

    wc $crossoutput_xy $crossoutput_mag
    head -1 $crossoutput_xy
    #        ./xcrossInnerOuterStar #outputs are xcrossInnerOuterStar.inner and xcrossInnerOuterStar.outer

    #===============================================
    #	if test ! -s $AlltemplatetableForVariable
    #	then
    #		AlltemplatetableForVariable=`echo $Alltemplatetable`
    #	fi
    #
    #	echo "To get the variable stars"
    #	./xnewCrossMatch $crossRedius_inner $diffmag xcrossInnerOuterStar.inner $AlltemplatetableForVariable output_inner_variable
    #	./xnewCrossMatch $crossRedius_outer $diffmag xcrossInnerOuterStar.outer $AlltemplatetableForVariable output_outer_variable
    #	cat output_inner_variable output_outer_variable  |  awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax && $13==2) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)}' ejmin=$ejmin ejmax=$ejmax | grep -v "99.000" >$crossoutput_mag   # new variables,magtemp-magnewimage at $12
    #        rm -rf output_inner_variable output_outer_variable 
    #
    #	#======================================================
    #	echo "To get the OT"
    #        ./xnewCrossMatch $crossRedius_inner $diffmag xcrossInnerOuterStar.inner $Alltemplatetable output_inner_ot
    #        ./xnewCrossMatch $crossRedius_outer $diffmag xcrossInnerOuterStar.outer $Alltemplatetable output_outer_ot
    #	#select out those at the edge of the image.
    #	#cp $crossoutput_xy newoutput_chb.dat
    #	cat output_inner_ot output_outer_ot | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax && $13==1) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' ejmin=$ejmin ejmax=$ejmax | grep -v "99.000" >$crossoutput_xy
    #	rm -rf output_inner_ot output_outer_ot xcrossInnerOuterStar.inner xcrossInnerOuterStar.outer
    #	date
    #	#================================================	
    #       # wc $crossoutput_xy $crossoutput_mag

}

xupdatetemp ( )
{
    echo "xupdatetemp"
    echo "xupdatetemp" >>$stringtimeForMonitor
    #                echo "Too many 1 class OT candidates"
    #                cd $HOME/iraf
    #                cp -f login.cl.old login.cl
    #                echo noao >> login.cl
    #                echo digiphot >> login.cl
    #                echo image >> login.cl
    #                echo imcoords >>login.cl
    #                echo "cd $Dir_redufile" >> login.cl
    #               # echo "imarith(\"$FITFILE\",\"-\",\"$bg\",\"$FITFILE_subbg\")" >>login.cl
    #                echo "display(image=\"$FITFILE_subbg\",frame=1)" >>login.cl #display newimage in frame 1
    #                echo logout >> login.cl
    #                cl < login.cl>xlogfile
    #                cd $HOME/iraf
    #                cp -f login.cl.old login.cl
    cd $Dir_redufile
    #                cp $FITFILE  $trimsubimage_dir  #for the trim subimage continously      

    #                if test -r noupdate.flag
    #                then
    #                        echo "have noupdate.flag"

#    dateobs=`gethead $FITFILE "D-OBS-UT"`
#    timeobs=`gethead $FITFILE "T-OBS-UT"`
    rm -rf listtime
    for ((i=0;i<$NumOT;i++))
    do
        echo "0.00  0.00 0.00  0.00" $dateobs"T"$timeobs $FITFILE >>listtime
    done
    #                        echo "making the update"
    #wc $crossoutput_xy
    paste listtime $crossoutput_xy |  awk '{if($7>0 && $8>0 && $7<3056 && $8<3056)print($1,$2,$3,$4,$7,$8,$5,$6,$9,$10,$11,$12,$13,$14,$15,$16)}' | column -t >crossoutput_skytemp
    mv crossoutput_skytemp $crossoutput_sky

    ls $crossoutput_sky >>listupdate
    nupdate=`wc listupdate | awk '{print($1)}'`
    echo "nupdate="$nupdate
    if [ $nupdate -lt 5  ]
    then
        ls $FITFILE >>xMissmatch.list
        #xtimeCal
        #continue

    else
        echo "nupdate num. is larger than 5"
        cat listupdate | tail -5 >listupdate_last5
        #       cat listupdate_last5
        ls $FITFILE >>listupdateimage.list
        ls $FITFILE >>listupdateimage.list.bak
        #                                Num_update=`wc listupdateimage.list | awk '{print($1)}'`
        if [ $nupdate -lt 50 ]
        then
            echo "Num_update is $nupdate less than  50"
            paste xChbTempBefore.cat listupdate_last5 xChbTempAfter.cat >xChbTempBatch_update.sh
            sh xChbTempBatch_update.sh
            wc matchchb.log
            sh xUpdate_refcom3d.cat.sh  #update the refcom3d.cat    
            #xtimeCal
            #continue
        else
            # it will not complete the temp any more
            dir_tempfile=`cat listtemp_dirname`
            ls $FITFILE >>xMissmatch.list
            rm -rf $dir_tempfile/noupdate.flag
            rm -rf noupdate.flag
           # xtimeCal
           # continue
        fi
    fi
    xInforMonitor
    xtimeCal
    xProcessMonitorStatUpdateTemp
    xUploadImgStatusAndKeeplog
    continue
}

xcctranOT2image ( )
{
    echo "xcctranOT2image" >>$stringtimeForMonitor
    #This part is to transform the xy of OT candidates into the Ra and Dec.
    echo `date` "cctran of OT to image"
    if test -r $imagetrans1sd
    then
        echo "imagetrans1sd exist"  
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo digiphot >> login.cl
        echo image >> login.cl
        echo imcoords >>login.cl
        echo "cd $Dir_redufile" >> login.cl
        #OT candidates
        echo "cctran(input=\"$crossoutput_xy\",output=\"$crossoutput_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.7f\",latform=\"%12.7f\" ) " >>login.cl
        echo "geoxytran(\"$crossoutput_xy\", \"$newimageOTxyThird\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo "geoxytran(\"$newimageOTxyThird\", \"$newimageOTxyFis\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#variable stars        
        echo "cctran(input=\"$crossoutput_mag\",output=\"$crossoutput_sky_mag\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.7f\",latform=\"%12.7f\" ) " >>login.cl
        echo "geoxytran(\"$crossoutput_mag\", \"$newimageOTxyThird_mag\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo "geoxytran(\"$newimageOTxyThird_mag\", \"$newimageOTxyFis_mag\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#standard stars 
        echo "geoxytran(\"$tempmatchstars_mag\", \"magtemp\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo "geoxytran(\"magtemp\", \"$tempstandmagstarFis\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        # echo "imarith(\"$FITFILE\",\"-\",\"$bg\",\"$FITFILE_subbg\")" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $Dir_redufile
        rm -rf magtemp
    else
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo digiphot >> login.cl
        echo image >> login.cl
        echo imcoords >>login.cl
        echo "cd $Dir_redufile" >> login.cl
        #OT candidates
        echo "cctran(input=\"$crossoutput_xy\",output=\"$crossoutput_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.7f\",latform=\"%12.7f\" ) " >>login.cl
        echo "geoxytran(\"$crossoutput_xy\", \"$newimageOTxyFis\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#variable stars
        echo "cctran(input=\"$crossoutput_mag\",output=\"$crossoutput_sky_mag\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.7f\",latform=\"%12.7f\" ) " >>login.cl
        echo "geoxytran(\"$crossoutput_mag\", \"$newimageOTxyFis_mag\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#standard stars
        echo "geoxytran(\"$tempmatchstars_mag\", \"$tempstandmagstarFis\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        # echo "imarith(\"$FITFILE\",\"-\",\"$bg\",\"$FITFILE_subbg\")" >>login.cl

        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $Dir_redufile
    fi


    #================================
    #this part should be deleted
    #deleted by xlp at 20150312
    cat $newimageOTxyFis | awk '{print($1+xshift0,$2+yshift0,$3,$4,$5,$6,$7,$8,$9,$10)}' xshift0=$xshift0 yshift0=$yshift0 >temp
    mv temp $newimageOTxyFis

    cat $tempstandmagstarFis | awk '{print($1+xshift0,$2+yshift0,$3)}' xshift0=$xshift0 yshift0=$yshift0 >temp
    mv temp $tempstandmagstarFis

    cat $newimageOTxyFis_mag | awk '{print($1+xshift0,$2+yshift0,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)}' xshift0=$xshift0 yshift0=$yshift0 >temp
    mv temp $newimageOTxyFis_mag

}
xcombineOTInformation ( )
{
    echo "xcombineOTInformation" >>$stringtimeForMonitor
    #===========================================================
    #In final $crossoutput_sky, the parameters are
    #ra dec ox(newIm) oy(newIm) rx(refIm) ry(refIm) flux  ***
    echo `date` "making the skyOT list"
    rm -rf listtime	
    head -1 $crossoutput_sky
    #       timeobs=`gethead $FITFILE "date-obs"`
   
    # dateobs=`gethead $FITFILE "D-OBS-UT"`
    # timeobs=`gethead $FITFILE "T-OBS-UT"`
    
    echo "NumOT:  " $NumOT
    if [ $NumOT -gt 0 ]
    then
        for ((i=0;i<$NumOT;i++))
        do
            echo $dateobs"T"$timeobs $FITFILE >>listtime
        done
        paste $crossoutput_sky $newimageOTxyFis $crossoutput_xy listtime | awk '{print($1,$2,$11,$12,$21,$22,$31,$32,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >crossoutput_skytemp
         mv crossoutput_skytemp $crossoutput_sky
    fi

    echo `date` "making the sky mag list for variable object"
    head -1 $crossoutput_sky_mag
    rm -rf listtime
    #dateobs=`gethead $FITFILE "D-OBS-UT"`
    #timeobs=`gethead $FITFILE "T-OBS-UT"`
    Num_Variable=`cat $crossoutput_sky_mag | wc -l | awk '{print($1)}'`
    echo "Num_Variable:  " $Num_Variable
    if [ $Num_Variable -gt 0 ]
    then
        for ((i=0;i<$Num_Variable;i++))
        do
            echo $dateobs"T"$timeobs $FITFILE >>listtime
        done
        echo "variable information"
        paste $crossoutput_sky_mag $newimageOTxyFis_mag $crossoutput_mag listtime | awk '{print($1,$2,$13,$14,$25,$26,$37,$38,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)}' | column -t >crossoutput_skytemp
         mv crossoutput_skytemp $crossoutput_sky_mag
         echo "final Variable obj in the file of  " $crossoutput_sky_mag
         rm listtime
    fi



}

xfilterDarkBadpixel ( )
{
    echo "xfilterDarkBadpixel" >>$stringtimeForMonitor
    #To eject the bad pixel by the crossmatch from $crossoutput_sky and badpixelFile.db
    #badpixel file from dark image is named as badpixelFile.db
    #       echo "@@@@@%%%%%%%%&&&&&&&!!!!!!!!!!!!!!!!"
    #       wc $crossoutput_sky
    echo "To eject the bad pixel"
    NumOT=`wc -l $crossoutput_xy | awk '{print($1)}'`
    if [  $NumOT -gt 0  ] 
    then
         cp $crossoutput_sky newoutput
         ./xAutoEjectBadpixel
         mv newoutputEjected $crossoutput_sky
         rm -rf newoutput
         wc $crossoutput_sky
         #	head -1 $crossoutput_sky
    fi
}


xfilterBadColumnPixel ( )
{
    echo "xfilterBadColumnPixel" >>$stringtimeForMonitor
    #To eject the bad pixel by the crossmatch from $crossoutput_sky and badpixelFile.db
    #badpixel file is named as badpixelFile.db
    #       echo "@@@@@%%%%%%%%&&&&&&&!!!!!!!!!!!!!!!!"
    #       wc $crossoutput_sky
    echo "To eject the bad column pixel"
    NumOT=`wc -l $crossoutput_xy | awk '{print($1)}'`
    if [  $NumOT -gt 0  ] 
    then
        cp $DIR_badpixlefile/Known_Columnbadpixel.cat Known_Columnbadpixel.cat
        if test -s Known_Columnbadpixel.cat
        then
            cp $crossoutput_sky newoutput
             ./xAutoEjectBadColumnpixel
             mv newoutputEjected $crossoutput_sky
            rm -rf newoutput
             wc $crossoutput_sky
             #	head -1 $crossoutput_sky
         fi
    fi
}


xfilterBadSinglePixel ( )
{
    echo "xfilterBadSinglepixel" >>$stringtimeForMonitor
    #To eject the bad pixel by the crossmatch from $crossoutput_sky and badpixelFileForSpecficCCDcolumn.db
    #badpixel file is named as badpixelFileSpecficCCDcolumn.db
    #       echo "@@@@@%%%%%%%%&&&&&&&!!!!!!!!!!!!!!!!"
    #       wc $crossoutput_sky
    echo "To eject the bad single pixel"
    NumOT=`wc -l $crossoutput_xy | awk '{print($1)}'`
    if [  $NumOT -gt 0  ] 
    then
        cp $DIR_badpixlefile/Known_Singlebadpixel.cat Known_Singlebadpixel.cat
        if test -s Known_Singlebadpixel.cat
        then
         cp $crossoutput_sky newoutput
         ./xAutoEjectBadSinglepixel
         mv newoutputEjected $crossoutput_sky
         rm -rf newoutput
         wc $crossoutput_sky
         #	head -1 $crossoutput_sky
        fi
    fi
}

xfilterBrightStars ( )
{

    #This part is also able to eject the effect by bright stars, the table is named as brightstarsFile.db
    echo "To eject the effect from bright star"
    #       cp $crossoutput_sky newoutput
    #       ./xAutoEjectBrightstar
    #       mv newoutputEjected $crossoutput_sky
    #        rm -rf newoutput
    #       wc $crossoutput_sky

}

xfilterPSF ( )
{
    echo "xfilterPSF" >>$stringtimeForMonitor
    #========================================
    #filter the ot candidates by fwhm, the one whose fwhm is smaller than 1.1 will be deleted as a hot pixel.
    echo "psf filtering"
    NumOT=`wc -l $crossoutput_xy | awk '{print($1)}'`
    if [  $NumOT -gt 0  ] 
    then
       cat $crossoutput_sky | awk '{print($3,$4, "  1 a")}' >psf.dat
      # cp $crossoutput_sky $crossoutput_sky_nopsffilter
       cd $HOME/iraf
       cp -f login.cl.old login.cl
       echo noao >> login.cl
       echo image >> login.cl
       echo digiphot >> login.cl
       echo daophot >>login.cl
       echo "cd $Dir_redufile" >> login.cl
       echo "daoedit(\"$FITFILE\", icommand=\"psf.dat\")"  >> login.cl
       echo logout >> login.cl
       cl < login.cl  >OUTPUT_PSF
       mv OUTPUT_PSF $Dir_redufile
       cp -f login.cl.old login.cl
       cd $Dir_redufile
       cat OUTPUT_PSF | grep "ERROR" >errormsg
       if test ! -s errormsg
       then 
           cat OUTPUT_PSF | sed -e '/^$/d' | grep '[1-9]' | grep -v "NOAO" | grep -v "This" | grep -v "line" | grep -v "m" >OUTPUT_PSF1
           #		cat OUTPUT_PSF1
           #		wc OUTPUT_PSF1
           #		wc $crossoutput_sky
           paste OUTPUT_PSF1 $crossoutput_sky | awk '{if($5>PSF_Critical_min && $5<PSF_Critical_max)print($8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$5,$20,$21,$22,$23)}' PSF_Critical_min=$PSF_Critical_min PSF_Critical_max=$PSF_Critical_max >temp
           mv temp $crossoutput_sky
           #		wc  $crossoutput_sky
           rm -rf errormsg
       else
           echo "Error in the psf filter"
           echo "Error in the psf filter" >>$stringtimeForMonitor
       fi
    fi
}

xcheckpsf_Variable (  )
{
    
    echo "xcheckpsf_Variable" >>$stringtimeForMonitor
    #========================================
    #check the variable candidates for fwhm, No filter is done.
    echo "psf checking for Variables"
    Num_Variable=`wc -l $crossoutput_mag | awk '{print($1)}'`
    if [  $Num_Variable -gt 0  ] 
    then
       cat $crossoutput_sky_mag | awk '{print($3,$4, "  1 a")}' >psf.dat
       cd $HOME/iraf
       cp -f login.cl.old login.cl
       echo noao >> login.cl
       echo image >> login.cl
       echo digiphot >> login.cl
       echo daophot >>login.cl
       echo "cd $Dir_redufile" >> login.cl
       echo "daoedit(\"$FITFILE\", icommand=\"psf.dat\")"  >> login.cl
       echo logout >> login.cl
       cl < login.cl  >OUTPUT_PSF
       mv OUTPUT_PSF $Dir_redufile
       cp -f login.cl.old login.cl
       cd $Dir_redufile
       cat OUTPUT_PSF | grep "ERROR" >errormsg
       if test ! -s errormsg
       then 
           cat OUTPUT_PSF | sed -e '/^$/d' | grep '[1-9]' | grep -v "NOAO" | grep -v "This" | grep -v "line" | grep -v "m" >OUTPUT_PSF1
           paste OUTPUT_PSF1 $crossoutput_sky_mag | awk '{print($8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$5,$20,$21,$22,$23,$24,$25)}'>temp
           mv temp $crossoutput_sky_mag
           rm -rf errormsg
       else
           echo "Error in the psf when checking for variables"
           echo "Error in the psf when checking for variables" >>$stringtimeForMonitor
       fi
   fi

}


xfilterCV ( )
{
    #===========================================
    #filter the ot candidates by known CV or other konw variable stars
    echo "xfilterCV" >>$stringtimeForMonitor
    NumOT=`wc -l $crossoutput_xy | awk '{print($1)}'`
    if [  $NumOT -gt 0  ] 
    then
       cp $DIR_CVfile/Known_variaStar.cat Known_variaStar.cat
       if test -r Known_variaStar.cat
       then
           echo "To eject the known CV candidates"
       #    cp $crossoutput_sky $crossoutput_sky_nocvfilter
           cp $crossoutput_sky newoutput
           ./xAutoEjectVariaStars
           mv newoutputEjected $crossoutput_sky
           wc $crossoutput_sky
           rm -rf newoutput
       else
           echo "No any known CV candidates"
           echo "No any known CV candidates" >>$stringtimeForMonitor
       fi
    fi

}

xfilterBrightbg ( )
{
    # to make the photometry with iraf to test the bg brightness of thost 1ot, 
    #to filter those which are affected heavily by bright star or birght stars.
    echo "xfilterBrightbg"
}

xGetKeywords ( )
{
    echo "xGetKeywords"
    tempset=`gethead $FITFILE "tempset" | awk '{printf("%.2f\n", $1)}'`
    tempact=`gethead $FITFILE "tempact" | awk '{printf("%.2f\n",$1)}'`
    ID_MountCamara=`gethead $FITFILE "IMAGEID"  | cut -c14-17`
    IDccdNum=`echo $FITFILE | cut -c4-5`
    ccdid=`gethead $FITFILE "CCDID"`
    datenum=`gethead $FITFILE "D-OBS-UT" | sed 's/-//g'`
    dateobs=`gethead $FITFILE "D-OBS-UT"`
    timeobs=`gethead $FITFILE "T-OBS-UT"`
    ra1=`gethead $FITFILE "RA"`
    dec1=`gethead $FITFILE "DEC" `
    ra_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$1)}'`
    dec_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$2)}'`
    echo $ID_MountCamara $ra1 $dec1 $ra_mount $dec_mount
    configfile=`echo $inprefix".properties"`
    xxdateobs=`echo $dateobs | sed 's/-//g'| cut -c3-8`
    ccdtypeID=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1)}'`
    ID_ccdtype=`gethead "CCDTYPE" $FITFILE`
    exptime=`gethead $FITFILE "EXPTIME"`
    DirData=`gethead $FITFILE "DirData"`
}

 xUploadImgStatus (  )
 {
    echo "date=$xxdateobs 
    dpmname=$ccdtypeID
    dfinfo=`df -Th /data | tail -1`
    curprocnumber=`echo $FITFILE | cut -c23-26`
    otlist=
    varilist=
    imgstatus=$MonitorParameterslog
    starlist= 
    origimage=
    cutimages= " >$configfile
    echo "curl  http://190.168.1.25/uploadAction.action -F dpmName=$ccdtypeID  -F currentDirectory=$xxdateobs -F configFile=@$configfile -F fileUpload=@$MonitorParameterslog" >xUploadImgStatus.sh
    echo "upload the image status file to the server" >>$stringtimeForMonitor
    sh xUploadImgStatus.sh
    wait
    echo $FITFILE `date` >>UploadParameterfile_forXuyangMonitor 
}






xget2sdOT ( )
{
    #===============================================
    #       ls $crossoutput_sky >>listsky
    listsky=`echo $ID_MountCamara"_"$ra_mount"_"$dec_mount".list"`
    echo $listsky
    ls $crossoutput_sky >>$listsky
    #       The output name is matchchb.log in which an object who appear for at least twice in 5 images.
    echo '================= Templatemark by CHB ================'   
    cat $listsky | tail -5 >listsky1
    RN=`wc listsky1 | awk '{print($1)}'`
    if [ $RN -eq 5 ]
    then
        paste xChbTempBefore.cat listsky1 xChbTempAfter.cat >xChbTempBatch.sh
        sh xChbTempBatch.sh
        date
        #wait
        resfinallog=`echo "res_"$ID_MountCamara"_"$inprefix"_matchchb.log"`
        if test -s matchchb.log
        then
            cp matchchb.log $resfinallog
            if test -r "resall_"$ID_MountCamara"_"$datenum".log"
            then
                cat "resall_"$ID_MountCamara"_"$datenum".log" matchchb.log >matchchb_all.log1
                mv matchchb_all.log1 "resall_"$ID_MountCamara"_"$datenum".log"
            else
                cp matchchb.log "resall_"$ID_MountCamara"_"$datenum".log"
            fi

            cp "resall_"$ID_MountCamara"_"$datenum".log" list2frame.list
            cat matchchb.log | awk '{print($1,$2,$3,$4,$5,$6,$7,$8,$14,$15,$16)}' | sed 's/T/ /' | sed 's/:/ /g' >temp1
            cat temp1 | awk '{if($13<3)print($1,$2,$3,$4,$5,$6,$7"T"$8":"$9":"$10,$8+$9/60+$10/3600,$11,$12,$13,$14)}' |tr -s '\n' | sort -n -k 5 | sort -n -k 6 | uniq | column -t >newframeOT.obj
            cp newframeOT.obj $otc2
            cat newframeOT.obj | awk '{print($5,$6,$13)}' >newframeOT.obj.tv

        else
            echo "No transient candidates in the last 5 images"
        fi
    else
        echo 'Less than 5 images in listsky1 '
    fi
}

xOnlyUploadOTAndmag ( )
{
    #if test -s fwhm_lastdata
    #then
    #   fwhmnow=`cat fwhm_lastdata | awk '{print($5)}'`
    #   if [ ` echo " $fwhmnow > $fwhm_uplimit " | bc ` -eq 1  ]  #if the fwhm >2.0, donot sent the OT file to server
    #   then
            #inprefix=`echo $crossoutput_sky | sed 's/.fit.skyOT//g'`
            configfile=`echo $inprefix".properties"`
            #xxdateobs=`echo $dateobs | sed 's/-//g'| cut -c3-8`
            #ccdtypeID=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1)}'`
            echo "date=$xxdateobs
            dpmname=$ccdtypeID
            dfinfo=`df -Th /data | tail -1`
            curprocnumber=`echo $FITFILE | cut -c23-26`
            otlist=$crossoutput_sky
            varilist=$crossoutput_sky_mag
            imagetrans=$imagetransfluxCali
            imgstatus
            starlist=
            origimage=
            cutimages= " >$configfile
            #echo "==========="
            #cat  $configfile
            #echo "==========="
            #echo $dateobs $xxdateobs
            #echo "curl  http://190.168.1.25/uploadAction.action -F dpmName=$ccdtype  -F currentDirectory=$xxdateobs -F configFile=@$configfile -F fileUpload=@$crossoutput_sky"

             echo "curl  http://190.168.1.25/uploadAction.action -F dpmName=$ccdtypeID  -F currentDirectory=$xxdateobs -F configFile=@$configfile -F fileUpload=@$crossoutput_sky -F fileUpload=@$crossoutput_sky_mag -F fileUpload=@$imagetransfluxCali" >xupload1ot.sh

             echo "upload the OT file to the server" >>$stringtimeForMonitor
             sh xupload1ot.sh
             wait
             #curl http://190.168.1.25:8080/svom/realTimeOtDstImageUpload  -F fileUpload=@$crossoutput_sky
    #   else
    #        echo "fwhm $fwhmnow in this image is larger than : " $fwhm_uplimit >>$stringtimeForMonitor
    #   fi
    #else
    #    echo "no fwhm_lastdata for this image" >>$stringtimeForMonitor
    #fi
}

xOnlyUploadMagOT ( )
{
     #prefixlog=`echo $crossoutput_sky_mag | sed 's/.fit.skymagOT//g'`
     #configfile=`echo $prefixlog"_vari.properties"`
     #xxdateobs=`echo $dateobs | sed 's/-//g'| cut -c3-8`
     #ccdtype=`echo $crossoutput_sky_mag | cut -c4-5 | awk '{print("M"$1)}'`
     echo "date=$xxdateobs
     dpmname=$ccdtype
     dfinfo=`df -Th /data | tail -1`
     curprocnumber=`echo $crossoutput_sky_mag | cut -c23-26`
     varilist=$crossoutput_sky_mag
     starlist=
     origimage=
     cutimages= " >$configfile

     echo "curl  http://190.168.1.25/uploadAction.action -F dpmName=$ccdtype  -F currentDirectory=$xxdateobs -F configFile=@$configfile -F fileUpload=@$crossoutput_sky_mag" >xupload1variable.sh
     echo "upload the variables file to the server" 
     echo "upload the variables file to the server" >>$stringtimeForMonitor

     sh xupload1variable.sh
     wait
}

xplotandUploadOT ( ) #not used any more
{
    if test ! -r listskyot.list
    then
        cp $crossoutput_sky listskyot.list
    fi
    cp $crossoutput_sky listnewskyot.list
    ./plot2frame.sh $FITFILE
    displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
    kill -9 $displayPadNum
    display -resize 300x300+0+0 plot2frame.png &
    #=================================
    #upload the pngfile to service
    #	OtMonitorpng=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_ot.png")}'`
    #	OtMonitorSkypng=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_ot_sky.png")}'`
    #        cp plot2frame.png $OtMonitorpng
    #	cp plot2frame_sky.png $OtMonitorSkypng
    #        curl http://190.168.1.25:8080/svom/realTimeOtDstImageUpload  -F fileUpload=@$OtMonitorpng
    #	curl http://190.168.1.25:8080/svom/realTimeOtDstImageUpload  -F fileUpload=@$OtMonitorSkypng
    #it is not used any more
    #=================================
    ls $crossoutput_sky >>listskyotfile
    cat listskyotfile | tail -2000 >listskyotfileHis
    cp listskyotfileHis listskyotfile

    rm -rf listskyot.list
    for file in `cat listskyotfileHis`
    do
        cat $file >>listskyot.list
    done

}

xdisplayOTandnewImg ( )  #not used any more
{
    date
    echo `date` "display temp and new image and tvmark these OTc1"
    cd $HOME/iraf
    cp -f login.cl.old login.cl
    echo noao >> login.cl
    echo digiphot >> login.cl
    echo image >> login.cl
    echo imcoords >>login.cl
    echo "cd $Dir_redufile" >> login.cl
    echo "display(image=\"$FITFILE_subbg\",frame=1)" >>login.cl #display newimage in frame 1
    echo "display(image=\"$tempsubbgfile\",frame=2)" >>login.cl #display temp file in frame 2
    echo "tvmark(frame=1,coords=\"$newimageOTxyFis\",mark=\"circle\",radii=100,color=204,label+)" >>login.cl # tvmark new OT in frame 2
    echo "tvmark(frame=2,coords=\"$crossoutput_xy\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl #tvmark new OT in frame 2
    echo "tvmark(frame=1,coords=\"$newimageOTxyFis\",mark=\"circle\",radii=3,color=204,label+)" >>login.cl # tvmark new OT in frame 2
    echo "tvmark(frame=2,coords=\"$crossoutput_xy\",mark=\"circle\",radii=3,color=204,label-)" >>login.cl #tvmark new OT in frame 2
    echo "tvmark(frame=2,coords=\"newframeOT.obj.tv\",mark=\"circle\",radii=50,color=206,label-)" >>login.cl # tvmark new OT in frame 1
    echo logout >> login.cl
    cl < login.cl>xlogfile
    cd $HOME/iraf
    cp -f login.cl.old login.cl
    cd $Dir_redufile
    date
}

xMountTrack ( )
{
    #For this part, it has not finished because it depends on the huanglei's code.
    #xaxis=decaxis
    #yaxis=raaxis
    case $ccdid in
        A | C | E | G | I | K )
            CCD_set=South;;
        B | D | F | H | J | L )
            CCD_set=North;;
    esac
    xshiftG=`cat newxyshift.cat | awk '{print(-1*$1)}'`
    yshiftG=`cat newxyshift.cat | awk '{print(-1*$2)}'`
    echo "temp relative to the new image:  xshift="$xshiftG  "  yshift=" $yshiftG 
    if [ $CCD_set == "South"  ] # south CCD
    then
        echo "South CCD"
        deltapixel=`echo $pixelscale $dec_mount | awk '{print($1/cos(($2+10)/57.29578))}'`
        if [ ` echo " $yshiftG > 0 " | bc ` -eq 1 ]
        then
            echo "To west: new image relative to temp"
            RA_guider=+
        else
            echo "To east: new image relative to temp"
            RA_guider=-
            yshiftG=`echo $yshiftG | awk '{print(-1*$1)}'`
        fi
        if [ `echo " $xshiftG > 0"  | bc ` -eq 1 ]
        then
            echo "To north: new image relative to temp"
            DEC_guider=+
        else
            echo "To south: new image relative to temp"
            DEC_guider=-
            xshiftG=`echo $xshiftG | awk '{print(-1*$1)}'`
        fi
    else # north CCD
        echo "North CCD"
        deltapixel=`echo $pixelscale $dec_mount | awk '{print($1/cos(($2-10)/57.29578))}'`
        if  [ ` echo " $yshiftG > 0 " | bc ` -eq 1 ]
        then
            echo "To east: new image relative to temp"
            RA_guider=-
        else
            echo "To west: new image relative to temp"
            RA_guider=+
            yshiftG=`echo $yshiftG | awk '{print(-1*$1)}'`
        fi

        if [ ` echo " $xshiftG > 0"  | bc ` -eq 1 ]
        then
            echo "To south: new image relative to temp"
            DEC_guider=-
        else
            echo "To north: new image relative to temp"
            DEC_guider=+
            xshiftG=`echo $xshiftG | awk '{print(-1*$1)}'`
        fi
    fi
    #	fnc=`echo $yshiftG | cut -c1-1`
    #	if [ "$fnc" = "-" ]
    #	then
    #		yshifG=`echo yshiftG | cut -c2-4 | awk '{print("0"$1)}'`
    #	fi
    #	fnc=`echo $xshiftG | cut -c1-1`
    #        if [ "$fnc" = "-" ]
    #        then
    #                xshifG=`echo xshiftG | cut -c2-4 | awk '{print("0"$1)}'`
    #        fi

    xshiftG_sky=`echo $xshiftG $pixelscale | awk '{printf("%04d\n",$1*$2)}'` # dec axis no any projection relative to the mount point (DEC)
    yshiftG_sky=`echo $yshiftG $deltapixel | awk '{printf("%04d\n",$1*$2)}'` # ra axis 
    
    #echo $RA_guider $yshiftG $DEC_guider $xshiftG
    #IDccdNum=`echo $FITFILE | cut -c4-5`

    RADECmsg_sky_tmp=`echo "d#"$IDccdNum"bias"$RA_guider$yshiftG_sky$DEC_guider$xshiftG_sky`
    datestring=`gethead $FITFILE "date-obs"  | sed 's/-//g' | cut -c3-8`
    timestring=`gethead $FITFILE "time-obs"  | sed 's/://g' | cut -c1-6`
    guidertime=`echo $datestring$timestring | awk '{print($1"%")}'`
    #	guidertime=`date +%Y%m%d%H%M%S | cut -c3-14 | awk '{print($1"%")}'`

    RADECmsg_sky=`echo $RADECmsg_sky_tmp$guidertime`
    echo "new image relative to the temp in arcsec: " $RADECmsg_sky
    echo $RADECmsg_sky >>listmsgforHuang
    echo $RADECmsg_sky >listmsgforHuang.last.cat
    cat listmsgforHuang.last.cat >>$stringtimeForMonitor
    date
    ./xsentshift & #sent the shift values to telescope controlers.  
    #rm -rf listmsgforHuang.last.cat
    cat -n allxyshift.cat >allxyshift.cat.plot
    #sh xtrack.sh $ID_MountCamara & 

    cat -n allxyrms.cat >allxyrms.cat.plot
    sh xplottrackrms.sh $ID_MountCamara &
}

xFWHMCalandFocus ( )
{
    #This part is to calculate the FWHM for those standard stars in the new image
    if test -s $tempstandmagstarFis
    then
        echo "=======Have $tempstandmagstarFis==========="
        sh xFwhmCal_standmag.sh $Dir_redufile $FITFILE $tempstandmagstarFis $OUTPUT_fwhm & 
    else
        echo "=========NO $tempstandmagstarFis======="
    fi
}

xcut2otimg ( )
{
    #======================================================
    rm -rf  $bg bak.fit  Res*  *2sd.fit
    SecondOTlist=`echo $ccdtype".lst"`
    Command_SecondOTlist=`echo  http://190.168.1.25/getCutImageList.action?dpmName=$ccdtype`
    if test -s $SecondOTlist
    then
        mv $SecondOTlist before.lst
    fi
    wget -O $SecondOTlist $Command_SecondOTlist
    wait
    #sleep 2
    if test -s $SecondOTlist
    then
        echo "===xtrim_xyf.sh====="
        if test -s before.lst
        then
            cat $SecondOTlist before.lst >new.lst
            mv new.lst $SecondOTlist
            rm -rf before.lst
        fi
        #./xtrim_xyf.sh  $SecondOTlist
        #wait
        gnome-terminal -e ./xtrim_xyf.sh  $SecondOTlist & 
    else
        echo "no $SecondOTlist exist"
    fi
}

xCopyandbakResult ( )
{
    echo "xCopyandbakResult"
    cp $FITFILE $FITFILE_subbg $resfinallog $trimsubimage_dir
    cp $FITFILE  $trimsubimageForTemp_dir
    
#    cp $imagetmp3sd $OUTPUT_new $imagetrans3sd $FITFILE $imagetrans3sd_re $Alltemplatetable $tempfile $tempsubbgfile $Accfile $tempmatchstars $sub_dir
    #cp $FITFILE $OUTPUT_geoxytran3  $lc_dir
}
xbakresult ( )
{
    date -u >time_dir
    year=`cat time_dir | awk '{print($6)}'`
    month=`cat time_dir | awk '{print($2)}'`
    day=`cat time_dir | awk '{print($3)}'`
    wholeotdirectory=`echo "/data2/workspace/resultfile/"$year$month$day"/wholeimfile"`
    resultfiles=`echo $inprefix"*"`
    skyOTfile=`echo $inprefix".fit.skyOT"`
    cp $resultfiles res*.log listskyot.list xMiss* list_match* newframeOT.obj matchchb.log matchchb_all.log $wholeotdirectory
    cp $wholeotdirectory/$skyOTfile ./
}

xInforMonitor (  )
{
    cat list_matchmatss | tail -3 >listForMonitor.dat
    cat listForMonitor.dat fwhm_lastdata | tr '\n' ' ' | awk '{print($3,$2,$4,$5,$7,$9,$10,$20,$13,$25,"fwhm")}' | column -t >>listForMonitorall.dat
    listMonitorAll=listForMonitorall.dat_`date -u +%Y%m%d`
    cp listForMonitorall.dat $listMonitorAll 
    cp $listMonitorAll $Dir_monitor
    cp allxy*.plot $Dir_monitor_allplot
    tail -1 listForMonitorall.dat >listForMonitor.dat
    # image, star_num, xshift, yshift, xrms, yrms, matchNumber(1times), Fwhm(2k), limitmag, Num_1OTc 
    #need to add a soft to upload the listFormonitor

}

xSentFwhmAndTrack (  )
{
    fwhmresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_fwhm.jpg")}'`
    trackresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_track.jpg")}'`
    limitmagresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_limitmag.jpg")}'`
    rmsresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_xyrms.jpg")}'`
    diffmagresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_diffmag.jpg")}'`
    
    mv average_fwhm.jpg $fwhmresjpg
    curl $UploadParameterfile  -F fileUpload=@$fwhmresjpg
    mv Track.jpg $trackresjpg
    curl $UploadParameterfile  -F fileUpload=@$trackresjpg
    mv Limitmag.jpg $limitmagresjpg
    curl $UploadParameterfile  -F fileUpload=@$limitmagresjpg
    mv Trackrms.jpg $rmsresjpg
    curl $UploadParameterfile  -F fileUpload=@$rmsresjpg
    mv DiffExtinc.jpg $diffmagresjpg
    curl $UploadParameterfile  -F fileUpload=@$diffmagresjpg
    
    ####./xatcopy_remoteimg5.f $fwhmrespng  $trackrespng  $limitmagrespng $rmsrespng $diffmagrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &
    



    #./xatcopy_remoteimg4.f $fwhmrespng  $trackrespng  $limitmagrespng $rmsrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &
    #./xatcopy_remoteimg3.f $fwhmrespng  $trackrespng  $limitmagrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &
    #  ./xatcopy_remoteimg2.f $fwhmrespng  $trackrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &
    #    ./xatcopy_remoteimg.f $trackrespng  $IPforMonitorAndTemp ~/webForTrack  &

}

xcheckMatchResult (   )
{
    NumOT=`wc -l $crossoutput_xy | awk '{print($1)}'`
    Num_Variable=`cat $crossoutput_sky_mag | wc -l | awk '{print($1)}'`
    NumOT_center=`cat $crossoutput_xy | awk '{if($1>500 && $1<2500 && $2>500 && $2<2500) print($1,$2)}' | wc -l | awk '{print($1)}'`
    echo "NumOT_center in crossoutput_xy is: " $NumOT_center
    echo "N1OTC_center  and N1OTC in all FoV are " $NumOT_center " and " $NumOT >>list_matchmatss
    echo $NumOT_center 
    if test -r noupdate.flag
    then
        echo "Have noupdate.flag"
        ./xFwhmCal_noMatch.sh $Dir_redufile $FITFILE 
        wait
        #xMakefalseValueFormonitor_LimitmagDiffmag
        xSentFwhmAndTrack
        xupdatetemp   #to update the tempfile
    elif [ $NumOT_center -gt $NumOT_center_max ]
    then
        ./xFwhmCal_noMatch.sh $Dir_redufile $FITFILE  
        wait
        echo "class 1 OT is: " $NumOT_center
        echo "no noupdate.flag, do the next image"
        echo "no noupdate.flag but the ot num is:"$NumOT_center >>$stringtimeForMonitor
        ls $FITFILE >>xMissmatch.list
        mv newxyshift.cat.bak newxyshift.cat

        ls $FITFILE >>listreupdate 
        Num_listreupdate=`cat listreupdate | wc -l | awk '{print($1)}'`
        if [ $Num_listreupdate > 20  ]
        then
            echo "===xuptempbyhand_new.sh==="
            ./xuptempbyhand_new.sh $ra_mount $dec_mount $CCDID  update
        fi
        
        #wait
        #xMakefalseValueFormonitor_LimitmagDiffmag
        xSentFwhmAndTrack
        xInforMonitor
        xtimeCal
        xProcessMonitorStatUpdateTemp2
        xUploadImgStatusAndKeeplog
        continue  # The reduction of this image is not good enough, give up. 
    else  #everything is ok
        if test -r listreupdate
        then
            rm listreupdate
        fi
#        if [ $NumOT == 0 ]
#        then
#            ./xFwhmCal_noMatch.sh $Dir_redufile $FITFILE 
#            wait
#            xSentFwhmAndTrack
#            xtimeCal
#            continue
#        fi
    fi
}

xCheckshiftResult (  )
{
    #there should add a code to check abs(xshiftcheck) or abs(yshiftcheck) are larger than 200, 
    #if lager, delete the newxyshift.cat 
    if test ! -r newxyshift.cat
    then
        :
    else
        xshiftcheck=`cat newxyshift.cat | awk '{print($1)}'`
        yshiftcheck=`cat newxyshift.cat | awk '{print($2)}'`
        if [ ` echo " $xshiftcheck > 200 " | bc ` -eq 1 ] ||  [ ` echo "$xshiftcheck < -200 " | bc ` -eq 1 ] || [ ` echo " $yshiftcheck > 200 " | bc ` -eq 1 ] ||  [ ` echo "$yshiftcheck < -200 " | bc ` -eq 1 ]        
        then
            rm -rf newxyshift.cat
            cat allxyshift.cat | awk '{if($1>-200 && $1<200 && $2>-200 && $2<200)print($1,$2,$3)}' >allxyshift.cat.temp
            mv allxyshift.cat.temp allxyshift.cat
        fi
    fi
}


for FITFILE in `cat listmatch`
do
   # date "+%H %M %S" >time_redu_f
    echo "================" >> $stringtimeForMonitor
   echo "xdefinefilename  " `date` >>$stringtimeForMonitor 
   xdefinefilename
    
   echo "xdeleteBeforeresult " `date` >>$stringtimeForMonitor 
    xdeleteBeforeresult
   echo "xchangehe " `date` >>$stringtimeForMonitor 
    xchangehe
   echo "xprereduction " `date` >>$stringtimeForMonitor 
    xprereduction
   echo "xGetKeywords " `date` >>$stringtimeForMonitor 
    xGetKeywords
   echo "xgetstars " `date` >>$stringtimeForMonitor 
    xgetstars
   echo "xmatchimgtemp " `date` >>$stringtimeForMonitor 
    xmatchimgtemp
    #xplotxyxymatchresult
   echo "xfluxcalibration " `date` >>$stringtimeForMonitor 
    xfluxcalibration	
   echo "xlimitmagcal " `date` >>$stringtimeForMonitor 
    xlimitmagcal
    #xlimitmagcal_magbin
   #echo "xcrossmatchwith2radius " `date` >>$stringtimeForMonitor 
   # xcrossmatchwith2radius
    echo "xcrossmatchwithR1Merr1" `date` >>$stringtimeForMonitor
    xcrossmatchwithR1Merr1
    #xCheckshiftResult  
   echo "xMountTrack " `date` >>$stringtimeForMonitor 
    xMountTrack & 
   echo "xcctranOT2image " `date` >>$stringtimeForMonitor 
    xcctranOT2image
   echo "xcheckMatchResult " `date` >>$stringtimeForMonitor 
    xcheckMatchResult
   echo "xFWHMCalandFocus " `date` >>$stringtimeForMonitor 
    xFWHMCalandFocus
   echo "xcombineOTInformation " `date` >>$stringtimeForMonitor 
    xcombineOTInformation
   # xfilterDarkBadpixel
   echo "xfilterBadColumnPixel " `date` >>$stringtimeForMonitor 
   xfilterBadColumnPixel
#   echo "xfilterBadSinglePixel " `date` >>$stringtimeForMonitor 
#   xfilterBadSinglePixel
    #xfilterBrightStars
   echo "xfilterPSF " `date` >>$stringtimeForMonitor 
    xfilterPSF
   echo "xcheckpsf_Variable " `date` >>$stringtimeForMonitor 
    xcheckpsf_Variable
    #====================
    #might not be used 
    #modified by xlp at 20140901
   # xfilterCV
   # xfilterBrightbg
   echo "xOnlyUploadOTAndmag " `date` >>$stringtimeForMonitor 
    xOnlyUploadOTAndmag
   #echo "xOnlyUploadMagOT " `date` >>$stringtimeForMonitor 
    #xOnlyUploadMagOT

   echo "xSentFwhmAndTrack " `date` >>$stringtimeForMonitor 
    xSentFwhmAndTrack
    #	xget2sdOT
    #	xplotandUploadOT	
    #	xdisplayOTandnewImg
    #====================	
    #xcut2otimg code is not used any more
    #xcut2otimg
   echo "xCopyandbakResult " `date` >>$stringtimeForMonitor 
    xCopyandbakResult		
    #xbakresult
   echo "xInforMonitor " `date` >>$stringtimeForMonitor 
    xInforMonitor
   echo "xtimeCal " `date` >>$stringtimeForMonitor 
    xtimeCal
    echo "xProcessMonitorStatObjMonitor" `date` >>$stringtimeForMonitor
    xProcessMonitorStatObjMonitor
    echo "xUploadImgStatusAndKeeplog" `date` >>$stringtimeForMonitor
    xUploadImgStatusAndKeeplog

done
