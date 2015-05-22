#!/bin/bash
#date >time_redu_f
#echo /home/xlp/iraf/focus.online.20120815/
#cp /home/jianyan/software/xgwacsoft/OTdetect/xotmatch.soft/* ./
#cp /home/jianyan/software/xgwacsoft/xotmatch.soft.20121211/* ./
#modified by xlp at 20140124
#modified by xlp at 20140127

#===============================================================================
echo "xotOnline.sh newdata_dir"
UploadParameterfile=`echo http://190.168.1.25/gwacFileReceive`
Dir_monitor=/data2/workspace/monitor
Dir_temp=/data2/workspace/tempfile/result
dir_basicimage=/data2/workspace/basicfile
#echo "Please input your data directory"
#echo "like this: /home/xlp/data/gwac/rawdata/20130113" 
#read Dir_rawdata
stringtimeForMonitorT=`date -u +%Y%m%d`
stringtimeForMonitor=`echo $Dir_monitor"/reduc_"$stringtimeForMonitorT".log"`
Dir_rawdata=$1
Dir_redufile=/data2/workspace/redufile/matchfile
temp_dir=/home/gwac/newfile  #for the temp maker computer
temp_ip=`echo 190.168.1.40` #(ip for temp builder at xinglong)
IPforMonitorAndTemp=`echo 190.168.1.40`
Dir_IPforMonitorAndTemp=/home/gwac/webForFwhm
ObjInitialImage=1000  #The critical number for object number in the initial image 
BgBrightInitialImage=100  #The critical number for background brightness in the initial image
Nstar_skycali=5000  #The critical number of objects for astronomy.
echo $Dir_rawdata
echo $Dir_temp
echo $Dir_redufile
rm -rf *flag ip*.dat gototemp.fit newxyshift.cat newframeOT.obj newcomlist listdark listflat allxyshift.cat
rm -rf matchchb.log matchchb_all.log xMissmatch.list list_matchmatss newimageCoord.list
rm -rf list2frame.list list_fin listnewskyot.list listOT listsky listsky1 listskyotfile listskyotfileHis listskyot.list listtemp listtime
rm -rf noupdate.flag listupdateimage.list listupdate_last5 listupdate crossoutput_skytemp xatcopy_remote.flag 
#
#rm -rf *Initial*
#=================================================================================
./xmknewfile.sh
#=================================================================================
cd $Dir_rawdata
if test ! -r oldlist
then
	touch oldlist
else
        echo "oldlist exist"
fi

#rm -rf *Initial*
#==========================================================================
xwfits2fit (  )
{
echo "---------xwfits2fit-------"
echo "---------xwfits2fit-------" `date` >>$stringtimeForMonitor

fitfile=`echo $FILE | sed 's/.fits/.fit/'`
fitfilegz=`echo $FILE | sed 's/.fits/.fit.gz/'`
inprefix=`echo $FILE | sed 's/.fits//'`
rm -rf Newimage.fits
cp $FILE Newimage.fits
#echo $fitfilegz $fitfile
echo "in xwfits2fit, begin to use iraf " `date` >>$stringtimeForMonitor
echo $Dir_rawdata
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo image >> login.cl
echo dataio >>login.cl
echo "cd $Dir_rawdata" >> login.cl
#echo "wfit(iraf_fil=\"$FILE\",fits_fil=\"$inprefix\",fextn=\"fit\",extensi-,global_+,make_im+,long_he-,short_h-,bitpix=16,blockin=0,scale+,autosca+)" >>login.cl
echo "wfit(iraf_fil=\"Newimage.fits\",fits_fil=\"$inprefix\",fextn=\"fit\",extensi-,global_+,make_im+,long_he-,short_h-,bitpix=16,blockin=0,scale+,autosca+)" >>login.cl
echo logout >>login.cl
cl < login.cl >xlogfile
#cl <login.cl
cd $HOME/iraf
cp -f login.cl.old login.cl
echo "xwfits2fit using iraf is finished " `date` >>$stringtimeForMonitor
cd $Dir_rawdata
ls $fitfile >listmatch
cp -f $fitfile listmatch time_redu_f $Dir_redufile
gzip -f $fitfile
echo "gzip the $fitfile " `date` >>$stringtimeForMonitor
if test ! -r fitsbakfile
then
	mkdir fitsbakfile
fi
#rm -rf $FILE 
#mv $fitfilegz $FILE fitsbakfile
mv $fitfilegz fitsbakfile
#rm -rf $fitfile
#echo "--------------------"
cd $Dir_redufile
echo "xwfis2fit is finished " `date` >>$stringtimeForMonitor

}


xMainReduction ( )
{
    if test -r NoTempButSentFwhm.flag
    then
        rm NoTempButSentFwhm.flag 
        #rm NoTempButSentFwhm.flag averagefile
    fi
	echo "------xmatch.sh-------"
	echo "Begin to do the main reduction on OT extractor" `date` >>$stringtimeForMonitor
	./xmatch.sh
    wait
}


#==========================================================================================
xsentFwhmToMonitor (  )
{
    fwhmresjpg=`echo $fitfile | cut -c4-5 | awk '{print("M"$1"_fwhm.jpg")}'`
    mv average_fwhm.jpg $fwhmresjpg
    curl $UploadParameterfile  -F fileUpload=@$fwhmresjpg
    #./xatcopy_remoteimg.f $fwhmrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &
    touch NoTempButSentFwhm.flag

}

xReadObjAndBgbrightAndEllipFromFile (  )
{
    if test -r ObjAndBgbrightAndEllipFile
    then
        Nstar_ini=`cat ObjAndBgbrightAndEllipFile | awk '{print($1)}'`
        bgbrightness=`cat ObjAndBgbrightAndEllipFile | awk '{print($2)}'` 
        avellip=`cat ObjAndBgbrightAndEllipFile | awk '{print($3)}'`
    else
        Nstar_ini=-99
        bgbrightness=-99
        avellip=-99
    fi
    if test -r fwhm_lastdata
    then
        fwhmnow=`cat fwhm_lastdata | awk '{print($5)}'`
    else
        fwhmnow=-99
    fi
}

xcheckcombine ( )
{
echo "---xcheckcombine---"
date
ls $fitfile >>newcomlist
line_newcomlist=`cat newcomlist | wc -l`
if [ $line_newcomlist -lt 5 ]
then
        echo "the number of new image is" $line_newcomlist
	touch notemp.flag
else
#	echo `date` "---------to combine the 5 images-------"
        comref=`cat newcomlist | tail -5  | head -1`
        echo $comref
        comimage=`echo $comref | sed 's/\.fit/com.fit/'`
        MonitorParameterslog=`echo $comimage | sed 's/\.fit/.fit.monitorParaLog/'`
	echo "combine last 5 images " `date` >>$stringtimeForMonitor
	./xcom_withoutshift5images.sh newcomlist $comimage 
	wait
	#rm -rf fwhm_lastdata
	sh xFwhmCal_noMatch.sh $Dir_redufile $comimage 
	wait
    xReadObjAndBgbrightAndEllipFromFile
    #xsentFwhmToMonitor &  #modified by xlp at 20150130
	if test ! -s fwhm_lastdata
	then
		echo "No ouptut for xFwhmCal_noMatch.sh"
		echo "No ouptut for xFwhmCal_noMatch.sh "  `date` >>$stringtimeForMonitor
	else
		fwhm_comimage=`cat fwhm_lastdata | awk '{print($5)}'`
		NstarForfwhm=`cat fwhm_lastdata | awk '{print($4)}'`
		echo "The fwhm for combined image is:"$fwhm_comimage
		echo "The fwhm for combined image is: "$fwhm_comimage >>$stringtimeForMonitor
		if [ `echo " $fwhm_comimage < 1.8"  | bc ` -eq 1 ] &&  [ `echo " $NstarForfwhm > 300"  | bc ` -eq 1 ]
		then
			sethead -kr X TODO=tempMaking $comimage
			rm -rf newcomlist 
			touch imcombine.flag
		        touch xatcopy_remote.flag  #make a flag
			echo "Have imcombine.flag"
			ipfile=`echo "ip_address_"$ID_MountCamara".dat"`
		        echo $ipadress $Dir_temp >$ipfile
			echo "copy the combined image to the temp making computer "  `date`  >>$stringtimeForMonitor
		        ./xatcopy_remoteimg2.f $ipfile $comimage  $temp_ip $temp_dir"/"$ID_MountCamara
		        wait
                echo "copy finished to the temp making computer"  `date` >>$stringtimeForMonitor
			#sleep 300  #modified by xlp at 20140826
		        rm -rf imcombine.flag $comimage newcomlist listupdate 
                xProcessMonitorStatTempMaking
		else 
            xProcessMonitorStatTempMakingNoGoodImage
			rm -rf imcombine.flag $comimage newcomlist listupdate
			echo "The combined image is not good, fwhm is:" $fwhm_comimage
			echo "The combined image is not good, fwhm is:" $fwhm_comimage  ` date `>>$stringtimeForMonitor
		fi
	fi
fi
}

#=================================================================================

xcheckskyfield ( )
{
#if test -r xatcopy_remote.flag
#then
#	echo "first have xatcopy_remote.flag"
#	continue
#fi

echo "-------------xcheckskyfield---------------"
echo "-------------xcheckskyfield---------------"  `date` >>$stringtimeForMonitor

date
gpfile=`echo $Dir_temp"/"GPoint_catalog`
errorimage=`echo $Dir_temp"/"errorimage.flag`
if test ! -r $gpfile
then
	echo "no GPoint_catalog"
	echo "no GPoint_catalog" `date` >>$stringtimeForMonitor
	#echo 0 0 0 0 test test1 >Point_catalog
	xCheckFirstMaking
else 
	echo "Have GPoint_catalog"
	echo "Have GPoint_catalog " `date` >>$stringtimeForMonitor
#	cp $gpfile $Dir_redufile
	cat $gpfile | grep -v "^_" | awk '{if($3!="_")print($1,$2,$3,$4,$5,$6)}'>temp
	cp temp $gpfile
	mv temp GPoint_catalog 
	ls newimageCoord GPoint_catalog	
	./xcheck_skyfield # The output is named as xcheckResult
	if [ -s xcheckResult ] ## this case for the temp is ready but not be copied., this file exists and is not emipy
	then	
		xcopytemp
	else 
		xCheckFirstMaking		
	fi
fi
}

xCheckFirstMaking ( )
{
    xfits2jpg & 
	if test -r $errorimage
    then
	echo "have error image flag  "  `date` >>$stringtimeForMonitor
            rm -rf xatcopy_remote.flag notemp.flag $errorimage newcomlist
    fi

    if test -r xatcopy_remote.flag
    then
	echo "first have xatcopy_remote.flag" `date`  >>$stringtimeForMonitor
            echo "first have xatcopy_remote.flag"
            #sleep 180 #modified by xlp at 20140826 
	ls $fitfile >>xMissmatch.list
	./xFwhmCal_noMatch.sh $Dir_redufile $fitfile
	wait
    xProcessMonitorStatTempMakingWaiting
    #xsentFwhmToMonitor &
#            continue
    else
            xcheckcombine
#            wait
    fi

}


#===============================
xcheckifcopy ( )
{
echo "---xcheckifcopy---"
date
if test -s xcheckResult
then
    ra1_xcheckresult=`cat xcheckResult | awk '{print($1)}'`
    dec1_xcheckresult=`cat xcheckResult | awk '{print($2)}'`
    idCama_xcheckresult=`cat xcheckResult | awk '{print($3)}'`
	ra_sky_xcheckresult=`cat xcheckResult | awk '{print($4)}'`
	dec_sky_xcheckresult=`cat xcheckResult | awk '{print($5)}'`
    if [ "$ra_mount" != "$ra1_xcheckresult" ]  ||  [ "$dec_mount" != "$dec1_xcheckresult" ] || [ "$ID_MountCamara" != "$idCama_xcheckresult" ]
    then
        xcheckskyfield
        rm -rf noupdate.flag
    else
	    sethead -kr X RAsky=$dec_sky_xcheckresult DECsky=$dec_sky_xcheckresult $fitfile	
	    xcopytemp
    fi
else
        xcheckskyfield
fi
}

#===========================================
xcopytemp (  )
{
		echo "---xcopytemp---"
		echo "copy the temp from tempfile "  `date` >>$stringtimeForMonitor
		date
                rm -rf xatcopy_remote.flag  notemp.flag
#                echo " ---- The recent temp file is for the new image ---- "
                tempfilename=`cat xcheckResult | awk '{print($9"_"$8)}'`
                tempfilenamefinal=`echo $Dir_temp"/"$tempfilename`
#                echo $tempfilenamefinal
                echo $tempfilenamefinal >listtemp_dirname  #this file for the update the file xUpdate_refcom3d.cat.sh 
#		echo "begin copy"
		date
                cp -fr $tempfilenamefinal/* $Dir_redufile
                wait
#		echo "copy finish"
#		date
#                echo "----- Copy the temp from $tempfilenamefinal to $Dir_redufile -----"
                xMainReduction
                wait


}


#=================================================================================
xcheckAndMakeTemp_ready (  )
{
    echo "=======xcheckAndMakeTemp_ready========"
    #xfits2jpg &
    echo "xcheckAndMakeTemp_ready" >>$stringtimeForMonitor
    RaLast=`cat newimageCoord.list | awk '{print($1)}'`
    cp newimageCoord newimageCoord.list
    echo "Ra for last image is:  " $RaLast >>$stringtimeForMonitor 
    if [ "$RaLast"  != "$ra_mount"  ]
    then
    	echo "New sky field"
    	echo "New sky field"  `date`  >>$stringtimeForMonitor
    	rm -rf listsky newcomlist newxyshift.cat xatcopy_remote.flag
    	xcheckskyfield
    else
    	echo "This sky field is continuing"
    	echo "This sky field is continuing " `date` >>$stringtimeForMonitor
    	xcheckifcopy
    fi

}

xProcessMonitorStatInitialImage (  )
{
    echo "=====xProcessMonitorStatInitialImage====="
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=$Nstar_ini bgbright=$bgbrightness Fwhm=-99 S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile RA=-99 DEC=-99 State=InitialImage TimeProcess=-99 ellipticity=-99 tempset=$tempset tempact=$tempact" | tr ' ' '\n' >$MonitorParameterslog
    xUploadImgStatus
    wait
    #curl $UploadParameterfile  -F fileUpload=@$MonitorParameterslog

}

xProcessMonitorStatInstruCaliImage (  )
{
    echo "=====xProcessMonitorStatInstruCaliImage====="
    CCDImageType=$1
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=$Nstar_ini bgbright=$bgbrightness Fwhm=-99 S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile RA=$ra_mount DEC=$dec_mount State=$CCDImageType TimeProcess=-99 ellipticity=-99 tempset=$tempset tempact=$tempact" | tr ' ' '\n' >$MonitorParameterslog
    xUploadImgStatus
    wait
    #curl $UploadParameterfile  -F fileUpload=@$MonitorParameterslog

}


xProcessMonitorStatBadTempatureControl (  )
{
    echo "=====xProcessMonitorStatBadTempatureControl====="
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=$Nstar_ini bgbright=$bgbrightness Fwhm=-99 S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile RA=$ra_mount DEC=$dec_mount State=BadTempatureControl TimeProcess=-99 ellipticity=-99 tempset=$tempset tempact=$tempact" | tr ' ' '\n' >$MonitorParameterslog
    xUploadImgStatus
    wait
    #curl $UploadParameterfile  -F fileUpload=@$MonitorParameterslog
}

xProcessMonitorStatSkyCalBadImage (  )
{
    echo "====xProcessMonitorStatSkyCalBadImage===="
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=$Nstar_ini bgbright=$bgbrightness Fwhm=$fwhmnow S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile RA=$ra_mount DEC=$dec_mount State=SkyCalBadImage TimeProcess=-99 ellipticity=$avellip tempset=$tempset tempact=$tempact" | tr ' ' '\n'
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=$Nstar_ini bgbright=$bgbrightness Fwhm=$fwhmnow S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile RA=$ra_mount DEC=$dec_mount State=SkyCalBadImage TimeProcess=-99 ellipticity=$avellip tempset=$tempset tempact=$tempact" | tr ' ' '\n' >$MonitorParameterslog
    xUploadImgStatus
    wait
    #curl $UploadParameterfile  -F fileUpload=@$MonitorParameterslog
    
}


xProcessMonitorStatSkyCal ( )                                                                           
  {
    echo "====xProcessMonitorStatSkyCal===="
    echo "This case shows the SkyCal stat"
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=$Nstar_ini bgbright=$bgbrightness Fwhm=$fwhmnow S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile RA=$ra_mount DEC=$dec_mount State=SkyCal TimeProcess=-99 ellipticity=$avellip tempset=$tempset tempact=$tempact"  | tr ' ' '\n' 
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=$Nstar_ini bgbright=$bgbrightness Fwhm=$fwhmnow S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile RA=$ra_mount DEC=$dec_mount State=SkyCal TimeProcess=-99 ellipticity=$avellip tempset=$tempset tempact=$tempact" | tr ' ' '\n' >$MonitorParameterslog
    xUploadImgStatus
    wait
    #curl $UploadParameterfile  -F fileUpload=@$MonitorParameterslog
  }

xProcessMonitorStatTempMaking ( )                                                                           
  {
    echo "This case shows Temp making"
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=$Nstar_ini bgbright=$bgbrightness Fwhm=$fwhm_comimage S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$comimage RA=$ra_mount DEC=$dec_mount State=TempMaking TimeProcess=-99 ellipticity=$avellip tempset=$tempset tempact=$tempact" | tr ' ' '\n' >$MonitorParameterslog
    xUploadImgStatus
    wait
    #  curl $UploadParameterfile  -F fileUpload=@$MonitorParameterslog
  }

xProcessMonitorStatTempMakingWaiting ( )                                                                           
  {
    echo "This case shows Temp making waiting"
    echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=-99 bgbright=-99 Fwhm=-99 S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile RA=$ra_mont DEC=$dec_mount State=TempMakeWaiting TimeProcess=-99 ellipticity=-99 tempset=$tempset tempact=$tempact" | tr ' ' '\n' >$MonitorParameterslog
    xUploadImgStatus 
    wait
   #     curl $UploadParameterfile  -F fileUpload=@$MonitorParameterslog
  }
  xProcessMonitorStatTempMakingNoGoodImage (  )
  {
      echo "This case shows the combined image is not good for temp making"
      echo "DateObsUT=$dateobs TimeObsUT=$timeobs Obj_Num=$Nstar_ini bgbright=$bgbrightness Fwhm=$fwhm_comimage S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$comimage RA=$ra_mount DEC=$dec_mount State=BadComImage TimeProcess=-99 ellipticity=$avellip tempset=$tempset tempact=$tempact" | tr ' ' '\n' >$MonitorParameterslog
    xUploadImgStatus
    wait
     # curl $UploadParameterfile  -F fileUpload=@$MonitorParameterslog
  }

  xautoSkyCoordCali (  )
{
    echo "xautoSkyCoordCali"
    ./xatcopy_remoteimg.f $fitfile 190.168.1.40 ~/newfile/SkyC &
    wait
    touch xmkSkyCoordCalibration.flag
    
    continue
}

xcheckfirstimagequality (  )
{
    echo "xcheckfirstimagequality"

    echo "xcheckfirstimagequality" >>$stringtimeForMonitor
    xfits2jpg  &
     rm -rf image.sex errorSkyCoordCali.flag errorSkyCoordCali_no2CCDworking.flag xmkSkyCoordCalibration.flag
#     sex $fitfile  -c  xmatchdaofind.sex -DETECT_THRESH 6 -ANALYSIS_THRESH 6 -CATALOG_NAME image.sex -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME       $bg
#    rm -rf $bg
#    Nstar_ini=`wc -l image.sex | awk '{print($1)}'`
#    echo "source num. in Sync image is:  $Nstar_ini"
#
    sh xFwhmCal_noMatchForSkyCali.sh $Dir_redufile $fitfile 
    wait
    xReadObjAndBgbrightAndEllipFromFile
    wait

    echo "Nstar in this skycali image is : $Nstar_ini"
    if [ $Nstar_ini -lt $Nstar_skycali ]
    then   
        rm newimageCoord.list newimageCoord 
        echo "$fitfile is not good for Sky coordinate calibration ! "
        echo "$fitfile is not good for Sky coordinate calibration !" >> $stringtimeForMonitor
        xProcessMonitorStatSkyCalBadImage
        continue
    else    
        echo "this sync image is good" >>$stringtimeForMonitor
	    cp newimageCoord newimageCoord.list
        xProcessMonitorStatSkyCal
        xautoSkyCoordCali
    fi      
}

xcheckInitialImage (  )
{
    echo "====xcheckInitialImage===="
    echo "====xcheckInitialImage====" >>$stringtimeForMonitor
    InitialImagMonitorlog=`echo $fitfile | cut -c2-3 | awk '{print("M"$1"_initialimageMonitor.log")}'`
    cp $fitfile $Dir_redufile
    cd $Dir_redufile
    xfits2jpg  &
    rm -rf image.sex
    sex $fitfile  -c  xmatchdaofind.sex -DETECT_THRESH 6 -ANALYSIS_THRESH 6 -CATALOG_NAME image.sex -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME       $bg
    rm -rf $bg
    obj_intialimgquality=`wc -l image.sex | awk '{print($1)}'`
    echo "source num. in initial image is:  $obj_initialimgquality"
    if [ $obj_intialimgquality -gt $ObjInitialImage ]
    then   
        echo "Object number of initial image is not right"
        bgbright_initialimgquality=`cat image.sex | head -1 | awk '{print($5)}'`
        echo "Background brightness of initial image is $bgbright_initialimgquality"
        if [ $bgbright_initialimgquality -gt $BgBrightInitialImage  ]
        then
            echo "Background brightness of initial image is normal"
        else
            echo "Background brightness of initial image is not right"
        fi
    else
        echo "Object number in the initial image is not right"
    fi
#    xProcessMonitorStatInitialImage
    echo $obj_intialimgquality $bgbright_initialimgquality $ObjInitialImage $BgBrightInitialImage >$InitialImagMonitorlog
    curl $UploadParameterfile  -F fileUpload=@$InitialImagMonitorlog
    cd $Dir_rawdata
    mv *Initial* fitsbakfile
#    cd $Dir_redufile
#    continue
}

xcheckAndMakeTemp (  )
{
# to tell the temp for this image exist or not.
# if not, to build it immediatelly,then build a flag file, including the information about this image.
# if yes, copy it to the Dir_rawdata
# to make a flag file to tell weather the temp is ready or not
# if no flag file, break to do the next temp 
# The parameters to check is use the head of ra and dec for mount in the image
# To build the temp, sent the image and ip list to the Temp service automatically.
echo "-----------xcheckAndMakeTemp-------------"
echo "-----------xcheckAndMakeTemp-------------" `date` >>$stringtimeForMonitor
#ipadress=`ifconfig | head -2 | tail -1 | sed 's/:/ /g' | awk '{print($2)}'`
ipadress=`ifconfig | grep "inet" |  awk '{if($5=="broadcast")print($2)}'`
echo "get the $ipadress" `date` >>$stringtimeForMonitor
#-----------------------------------------------

#readme the RA DEC from the fits name and set them into the header
#dec_flag=`echo $fitfile | cut -c19-19`
#if [ $dec_flag  -ne  0  ]
#then
#	dec_temp=`echo $fitfile | cut -c19-21`
#else
#	dec_temp=`echo $fitfile | cut -c20-21`
#fi
#echo "DEC of $dec_temp is obtained for this $fitfile " `date` >>$stringtimeForMonitor
#ra_flag=`echo $fitfile | cut -c16-16`
#if [ $ra_flag -ne 0 ]
#then
#	ra_temp=`echo $fitfile | cut -c16-18`
#else
#	ra_temp=`echo $fitfile | cut -c17-18`
#fi
#echo "RA of $ra_temp is obtained for this $fitfile " `date` >>$stringtimeForMonitor
#sethead -kr X RA=$ra_temp DEC=$dec_temp  $fitfile
#echo "sethead the $ra_temp and $dec_temp to img head of $fitsfile " >>$stringtimeForMonitor  

#---------------------------------------------------
#ID_MountCamara=`gethead  $fitfile "IMAGEID" | cut -c14-17`
#ra1=`gethead $fitfile "RA"`
#dec1=`gethead $fitfile "DEC" `
#ra_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$1)}'`
#dec_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$2)}'`

echo $ra_mount $dec_mount $ID_MountCamara >newimageCoord
echo "ra_mount dec_mount and ID_MountCamara are: "$ra_mount $dec_mount $ID_MountCamara `date` >>$stringtimeForMonitor

if test -s newimageCoord.list
then
    if test ! -r xmkSkyCoordCalibration.flag 
    then
        xcheckAndMakeTemp_ready #all the prepering work is done, to copy the temp and do the xmatch.sh
    else
        if test -r errorSkyCoordCali.flag  #Sky coordinate calibration is failed, need to send one more image for sky coordinate calibration.
        then
            rm xmkSkyCoordCalibration_Waiting.lst xmkSkyCoordCalibration.flag 
            xcheckfirstimagequality
        elif test -r errorSkyCoordCali_no2CCDworking.flag 
        then
            echo "There are some CCDs on this mount are not working" >>$stringtimeForMonitor
            rm -rf xmkSkyCoordCalibration_Waiting.lst xmkSkyCoordCalibration.flag errorSkyCoordCali.flag 
            xcheckAndMakeTemp_ready
        else
             ls $fitfile >>xmkSkyCoordCalibration_Waiting.lst
             Num_waiting_skyC=`cat xmkSkyCoordCalibration_Waiting.lst | wc -l | awk '{print($1)}'`
             echo "The number for the waiting skyC is: "$Num_waiting_skyC
             if [ $Num_waiting_skyC -gt 40 ]  #waiting for 10 minites
             then
                 rm -rf xmkSkyCoordCalibration.flag xmkSkyCoordCalibration_Waiting.lst
                 rm -rf xmkSkyCoordCalibration.flag xmkSkyCoordCalibration_Waiting.lst >>$stringtimeForMonitor
                 xcheckAndMakeTemp_ready
             else 
                 echo "Waiting for the Sync making"
                 echo $fitfile "The Num is $Num_waiting_skyC , waiting for Sky coordinate calibration " >>$stringtimeForMonitor
                 continue
             fi
        fi
    fi
else  #no newimageCoord.list, it is means that this is the first normal image for this observation epoch.
    xcheckfirstimagequality
fi


}
xfits2jpg ( )
{

echo "=======xfits2jpg======"
ccdimgjpg=`echo $fitfile | cut -c4-5 | awk '{print("M"$1"_ccdimg.jpg")}'`
#skyfield_num=`echo $fitfile | cut -c16-26 | awk '{print("M"$1)}'`
#echo $fitfile $ccdimgjpg $skyfield_num
#python fits_cut_to_png.py $fitfile $ccdimgjpg 1528 1528 1528  $skyfield_num &
python fits_cut_to_png.py $fitfile $ccdimgjpg 1528 1528 1528 "" &
wait
convert -resize 50% $ccdimgjpg temp.jpg
mv temp.jpg $ccdimgjpg
#curl http://190.168.1.25/realTimeOtDstImageUpload  -F fileUpload=@$ccdimgjpg
curl $UploadParameterfile  -F fileUpload=@$ccdimgjpg
#./xatcopy_remoteimg.f $ccdimgjpg 190.168.1.40 ~/web & 
wait
rm -rf $ccdimgjpg
}

xcheckimgQuality (   )
{
    echo "===xcheckimgQuality==="
    #$1 is Dark, Bias, Flat or  WongCCDtype,Darkcom
    #However, Bias is not ready for the mini-gwac system right now at 20150507
    ImageType=$1
    
    if [ "$ImageType" == "Bias" ]
    then
        Nstar_ini_criMax=1000
        Nstar_ini_criMin=1
        bgbrightness_criMax=2000
        bgbrightness_criMin=200
        listInstruCali=`echo listbias`
    fi

    if [ "$ImageType" == "Dark" ]
    then
        Nstar_ini_criMax=1000
        Nstar_ini_criMin=1
        bgbrightness_criMax=2000
        bgbrightness_criMin=200
        listInstruCali=`echo listdark`
    fi
    
    if [ "$ImageType" == "Darkcom" ]
    then
        Nstar_ini_criMax=1000
        Nstar_ini_criMin=1
        bgbrightness_criMax=2000
        bgbrightness_criMin=200
        listInstruCali=`echo listdarkcom`
    fi
    
    if [ "$ImageType" == "Flat" ]
    then
        Nstar_ini_criMax=30000
        Nstar_ini_criMin=2000
        bgbrightness_criMax=35000
        bgbrightness_criMin=10000
        listInstruCali=`echo listflat`
    fi
    
    if [ "$ImageType" == "Flatcom" ]
    then
        Nstar_ini_criMax=30000
        Nstar_ini_criMin=2000
        bgbrightness_criMax=35000
        bgbrightness_criMin=10000
        listInstruCali=`echo listflatcom`
    fi
    
    

    if [ "$ImageType" == "WongCCDtype" ]
    then
        Nstar_ini_criMax=0
        Nstar_ini_criMin=100000
        bgbrightness_criMax=0
        bgbrightness_criMin=100000
        listInstruCali=`echo listwrongCCDtype`
    fi

    rm -rf image.sex                                                                                                                               
    xfits2jpg &
    sex $fitfile  -c  xmatchdaofind.sex -DETECT_THRESH 6 -ANALYSIS_THRESH 6 -CATALOG_NAME image.sex -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $bg  
    rm -rf $bg
    Nstar_ini=`wc -l image.sex | awk '{print($1)}'`
    Delta_temp=`echo $tempset $tempact | awk '{printf("%.0f\n",$1-$2)}'`
    if [ ` echo " $Delta_temp > -5.0 " | bc ` -eq 1 ] && [ ` echo " $Delta_temp < 5.0 " | bc ` -eq 1 ] 
    then
        echo "temparature is normal for $ImageType image"
        echo "source num. in $fitfile is: " $Nstar_ini
        rm -rf newbgbrightres.cat
        cat image.sex | awk '{print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' >newbgbright.cat           
        ./xavbgbright
        if test ! -r newbgbrightres.cat
        then
            echo "no result of bg brightness"
            continue
        else
            bgbrightness=`cat newbgbrightres.cat | awk '{printf("%.0f\n", $1)}'`
            echo "bg brightness is : " $bgbrightness
            rm newbgbrightres.cat
        fi

        if [ ` echo " $Nstar_ini > $Nstar_ini_criMin " | bc ` -eq 1 ] && [ ` echo " $Nstar_ini < $Nstar_ini_criMax " | bc ` -eq 1 ]  && [ ` echo " $bgbrightness > $bgbrightness_criMin " | bc ` -eq 1 ] && [ ` echo " $bgbrightness < $bgbrightness_criMax " | bc ` -eq 1 ]
        then 
            echo "This $ImageType image is good" 
            ls $fitfile >>$listInstruCali
            xProcessMonitorStatInstruCaliImage  $ImageType
        else
            echo $fitfile "is not good for the $ImageType making ! "
            echo $fitfile "is not good !" >>$stringtimeForMonitor
            rm $fitfile
            continue    
        fi              
    else
        echo $fitfile "is not good for the $ImageType making since the tempact is not as the tempset"
        echo $fitfile "is not good for the $ImageType making since the tempact is not as the tempset" >>$stringtimeForMonitor
        rm $fitfile 
        xProcessMonitorStatBadTempatureControl 
        continue
    fi
    
}

xGetKeywords (  )
{
    echo "xGetKeywords"
    tempset=`gethead $fitfile "tempset" | awk '{printf("%.2f\n",$1)}'`
    tempact=`gethead $fitfile "tempact" | awk '{printf("%.2f\n",$1)}'`
    
    ID_MountCamara=`gethead $fitfile "IMAGEID"  | cut -c14-17`
    IDccdNum=`echo $fitfile | cut -c4-5`
    ccdid=`gethead $fitfile "CCDID"`
    
    datenum=`gethead $fitfile "D-OBS-UT" | sed 's/-//g'`
    dateobs=`gethead $fitfile "D-OBS-UT"`
    timeobs=`gethead $fitfile "T-OBS-UT"`
    
    ra1=`gethead $fitfile "RA"`
    dec1=`gethead $fitfile "DEC" `
    #ra_mount=`skycoor -d $ra1 $dec1 | awk '{print($1)}'`
    #dec_mount=`skycoor -d $ra1 $dec1 | awk '{print($2)}'`
    ra_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$1)}'`
    dec_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$2)}'`
    echo $ID_MountCamara $ra1 $dec1 $ra_mount $dec_mount
    
    echo "to read the ccdtype in imhead "  `date` >>$stringtimeForMonitor
    ID_ccdtype=`gethead "CCDTYPE" $fitfile`

    #=======================================
    #define some filename
    inprefix=`echo $fitfile | sed 's/.fit//'`
    configfile=`echo $inprefix".properties"`
    xxdateobs=`echo $dateobs | sed 's/-//g'| cut -c3-8`
    ccdtypeID=`echo $fitfile | cut -c4-5 | awk '{print("M"$1)}'`
}

xUploadImgStatus (  )
{
	echo $xxdateobs  $ccdtypeID $MonitorParameterslog $configfile
    echo "date=$xxdateobs 
    dpmname=$ccdtypeID
    dfinfo=`df -Th /data | tail -1`
    curprocnumber=`echo $fitfile | cut -c23-26`
    otlist=
    varilist=
    imgstatus=$MonitorParameterslog
    starlist= 
    origimage=
    cutimages= " >$configfile
    echo "curl  http://190.168.1.25/uploadAction.action -F dpmName=$ccdtypeID  -F currentDirectory=$xxdateobs -F configFile=@$configfile -F fileUpload=@$MonitorParameterslog" 
    echo "curl  http://190.168.1.25/uploadAction.action -F dpmName=$ccdtypeID  -F currentDirectory=$xxdateobs -F configFile=@$configfile -F fileUpload=@$MonitorParameterslog" >xUploadImgStatus.sh
    echo "upload the image status file to the server" >>$stringtimeForMonitor
    sh xUploadImgStatus.sh
    wait
}


XtellCCDtype ( )
{
echo "====xtellCCDtype===="
echo `date` "lsof to read the imhead " `lsof $FILE` >>$stringtimeForMonitor
lsof $FILE >lsof.cat
if test ! -s lsof.cat
then
	Nimhead=`imhead $FILE | wc -l | awk '{print($1)}'`
	if [ ` echo " $Nimhead < 50 " | bc ` -eq 1 ]
	then
     	echo "imhead is not complete"
    	echo "No lsof.cat, imhead is not complete"  `date` >>$stringtimeForMonitor
    else
        echo "No lsof.cat "  `date` >>$stringtimeForMonitor
 	fi
else
	sleep 2
    echo "Have lsof.cat, sleep 2"  `date` >>$stringtimeForMonitor
fi 
xwfits2fit  #if it is a fits
wait
xGetKeywords
wait
  #&&&&&&&&&&&&&&&&&&#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   # if it is a fit
  #echo "---------no need to do the xwfits2fit-------"
# fitfile=`echo $FILE | sed 's/.fits/.fit/'`
# fitfilegz=`echo $FILE | sed 's/.fit/.fit.gz/'`
# ls $fitfile >listmatch
# cp -f $fitfile listmatch $Dir_redufile
# gzip -f $fitfile
# if test ! -r fitsbakfile
# then
#         mkdir fitsbakfile
# fi
# #rm -rf $FILE 
# mv $fitfilegz fitsbakfile
# cd $Dir_redufile
  #&&&&&&&&&&&&&&&&&&#@@@@@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  MonitorParameterslog=`echo $fitfile | sed 's/\.fit/.fit.monitorParaLog/'`
  echo $MonitorParameterslog
  if  [ "$ID_ccdtype"x = "OBJECT"x ] # it is an object image
  then 
    #  if test -r recopy_WrongCCDtype.flag
    #  then
    #      rm recopy_WrongCCDtype.flag
    #  fi
	  xcheckAndMakeTemp
  elif  [ "$ID_ccdtype"x = "DARK"x ]  #it is a dark image
  then
    #  if test -r recopy_WrongCCDtype.flag
    #  then
    #      rm recopy_WrongCCDtype.flag
    #  fi
        xcheckimgQuality Dark
      #  ls $fitfile >>listdark
        line_darklist=`wc -l listdark | awk '{print($1)}'`
        if [ $line_darklist -gt 10 ]
        then
		echo "dark combination  " `date`   >>$stringtimeForMonitor
                ./xdarkcom.sh
                wait
                rm -rf *_5_* listdark
                if test -r Dark.fit
                then
                    xcheckimgQuality Darkcom
                    if test -s listdarkcom
                    then
                        stringtime=`date -u +%Y%m%d%H%M%S`
                        basicstring=`echo "Dark_"$stringtime".fit"`
                        cp -f Dark.fit  $basicstring
                        cp -f Dark.fit $basicstring badpixelFile.db $dir_basicimage
                    else
                        echo "Dark.fit is not good enough"
                    fi
                else
                    echo "No Dark.fit"
                fi

          else
                  echo "dark image is not enough"
          fi
  elif [ "$ID_ccdtype"x = "FLAT"x ]  # it is a flat image
  then
    #  if test -r recopy_WrongCCDtype.flag
    #  then
    #      rm recopy_WrongCCDtype.flag
    #  fi
        xcheckimgQuality Flat
       #   ls $fitfile >>listflat
          line_flatlist=`wc -l listflat | awk '{print($1)}'`
          if [ $line_flatlist -gt 10 ]
          then
                ./xflatcom.sh
                wait
                if test -r Flat.fit
                then
                    xcheckimgQuality Flatcom
                    if test -s listflatcom
                    then
                        rm -rf listflat *_6_*
                        stringtime=`date -u +%Y%m%d%H%M%S`
                        basicstring=`echo "Flat_"$stringtime".fit"`
                        cp -f Flat_bg.fit $basicstring
                        cp -f Flat_bg.fit $basicstring $dir_basicimage
                    else
                        echo "Flat.fit is not good for flat correction"
                    fi
                else
                    echo "No Flat.fit"
                fi
          else
                  echo "flat image is not enough"
          fi
  else   # error image

	echo "image with wrong ccdtype"
	echo "image with wrong ccdtype"  `date` >>$stringtimeForMonitor
    xcheckimgQuality WongCCDtype
    #if test ! -r recopy_WrongCCDtype.flag
    #then
    #    rm -rf $fitfile 
    #    rm $Dir_rawdata/$fitfilegz 
    #    mv $Dir_rawdata/$FILE $Dir_rawdata
    #    touch recopy_WrongCCDtype.flag
    #    XtellCCDtype
    #else  #recopy_WrongCCDtype.flag exist
    #    rm recopy_WrongCCDtype.flag
    #fi
  fi
}

#=======================================================================================

while :
do
	echo "&&&&&&&&&&&&&&&&  " `date`	>>$stringtimeForMonitor
    cd $Dir_rawdata
    #rm -rf *Initial*.fits
	if test ! -r oldlist
	then
        	touch oldlist
	fi
    if test ! -r fitsbakfile
    then
        mkdir fitsbakfile

    fi

#	if test ! -r M*.fits
#	then
#		sleep 1
#		continue
#	fi	
	ls *.fits >newlist
	linenewimage=`cat newlist | wc -l`
        if [ $linenewimage -eq 0  ]
        then
		#echo "Waiting new image..."
                sleep 2
                continue
        fi

	diff oldlist newlist | grep  ">" | tr -d '>' | column -t >listmatch1
	line=`cat listmatch1 | wc -l`
	if  [ "$line" -ne 0 ]
	then 
		echo "New image exits! " `date` >>$stringtimeForMonitor
		date "+%H %M %S" >time_redu_f
		#just for the sort the image of dark, flat, object frames
        Ninitimage=`cat listmatch1 | grep "Initial" | wc -l`
        if [ $Ninitimage -gt 0  ]
        then
            cat listmatch1 | grep "Initial" | tail -1 > list
            fitfile=`cat list`
            xcheckInitialImage
            continue
        fi
		#Ndark=`cat listmatch1 | grep "_5_" | wc -l` #dark frames
        #if [ $Ndark -gt 0  ]
        #then
        #    cat listmatch1 | grep "_5_" | head -1 >list
		#	cp -f list listmatch
		#	cat list >>oldlist
		#	sort oldlist >oldlist1
		#	mv oldlist1 oldlist
        #        else 
		#	Nflat=`cat listmatch1 | grep "_6_" | wc -l` #flat frames	
		#	if [ $Nflat -gt 0 ]
		#	then
		#		cat listmatch1 | grep "_6_" | head -1 >list
		#		cp -f list listmatch
		#		cat list >>oldlist
		#		sort oldlist >oldlist1
		#		mv oldlist1 oldlist
		#	else  # object frames
		#		echo "it is an object image"  `date` >> $stringtimeForMonitor
        #        cat listmatch1 | grep -v "_5_" | grep -v "_6_" | tail -1 >list # to reduce the new image always, but might miss some images.   it is might be _1_ for obj or _7_ for temp model 
		#		cp -f list listmatch
		#		echo "copy list to listmatch"  `date` >> $stringtimeForMonitor
		#		if test ! -r listreduc
		#		then
		#			touch listreduc
		#		fi
		#		cat list >>listreduc
		#		cat listmatch >>oldlist
		#		echo "begin to sort the oldlist"  `date` >> $stringtimeForMonitor
		#		sort oldlist >oldlist1
		#		echo "sort oldlist is over"  `date` >> $stringtimeForMonitor
		#		mv oldlist1 oldlist
		#	fi
        #        fi
		cat listmatch1 | head -1 >list
		#cat list
		cp -f list listmatch
		cat list >>oldlist
		sort oldlist >oldlist1
		mv oldlist1 oldlist

		FILE=`cat list`
		echo $FILE
		echo $FILE  ` date` >>$stringtimeForMonitor
		du -a $FILE >mass
		echo "get the mass of $FILE"  ` date` >>$stringtimeForMonitor
		fitsMass=`cat mass | awk '{print($1)}'`
		echo "get the fitsmass value : $fitsmass "  ` date` >>$stringtimeForMonitor
		
		#echo "fitsMass =" $fitsMass
		
		#if [ "$fitsMass" -lt 36490 ]
        
		if [ "$fitsMass" -lt 18248 ]
		then
			echo "waiting ..."
			sleep 2
            echo "Waiting,  the fitsmass of this fits is: " $fitsMass `date` >>$stringtimeForMonitor
			XtellCCDtype
			wait
		else
			echo "to get the xtellccdtype" `date` >>$stringtimeForMonitor
			XtellCCDtype
			wait
		fi
	else
		sleep 10
        DataProcessWorkingflag=`echo $Dir_rawdata | cut -c7-11 | awk '{print($1".workingflag")}'`
        touch $DataProcessWorkingflag 
        curl $UploadParameterfile  -F fileUpload=@$DataProcessWorkingflag
	fi
	cd $Dir_rawdata
done
