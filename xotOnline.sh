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
echo $Dir_rawdata
echo $Dir_temp
echo $Dir_redufile
rm -rf *flag ip*.dat gototemp.fit newxyshift.cat newframeOT.obj newcomlist listdark listflat allxyshift.cat
rm -rf matchchb.log matchchb_all.log xMissmatch.list list_matchmatss newimageCoord.list
rm -rf list2frame.list list_fin listnewskyot.list listOT listsky listsky1 listskyotfile listskyotfileHis listskyot.list listtemp listtime
rm -rf noupdate.flag listupdateimage.list listupdate_last5 listupdate crossoutput_skytemp xatcopy_remote.flag 
#
rm -rf *Initial*
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

rm -rf *Initial*
#==========================================================================
xwfits2fit (  )
{
echo "---------xwfits2fit-------"
echo "---------xwfits2fit-------" `date` >>$stringtimeForMonitor

fitfile_prefix=`echo $FILE | sed 's/.fits//'`
fitfile=`echo $FILE | sed 's/.fits/.fit/'`
fitfilegz=`echo $FILE | sed 's/.fits/.fit.gz/'`
#echo $fitfilegz $fitfile
echo "in xwfits2fit, begin to use iraf " `date` >>$stringtimeForMonitor
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo image >> login.cl
echo dataio >>login.cl
echo "cd $Dir_rawdata" >> login.cl
echo "wfit(iraf_fil=\"$FILE\",fits_fil=\"$fitfile_prefix\",fextn=\"fit\",extensi-,global_+,make_im+,long_he-,short_h-,bitpix=16,blockin=0,scale+,autosca+)" >>login.cl
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
mv $fitfilegz $FILE fitsbakfile
rm -rf $fitfile
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
    fwhmresjpg=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_fwhm.jpg")}'`
    mv average_fwhm.jpg $fwhmresjpg
    curl $UploadParameterfile  -F fileUpload=@$fwhmresjpg
    #./xatcopy_remoteimg.f $fwhmrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &
    touch NoTempButSentFwhm.flag

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
        comref=`cat newcomlist | head -1`
        echo $comref
        comimage=`echo $comref | sed 's/\.fit/com.fit/'`
        MonitorParameterslog=`echo $comimage | sed 's/\.fit/.fit.monitorParaLog/'`
	echo "combine last 5 images " `date` >>$stringtimeForMonitor
	./xcom_withoutshift5images.sh newcomlist $comimage 
	wait
	#rm -rf fwhm_lastdata
	./xFwhmCal_noMatch.sh $Dir_redufile $comimage 
	wait
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
	xfits2jpg &
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

xProcessMonitorStatSkyCal ( )                                                                           
  {
       echo "This case shows the SkyCal stat"
       echo "TimeObsUT=$TimeForEndObsUT Obj_Num=$Num_imgquality bgbright=-99 Fwhm=-99 S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile  RA=$ra1 DEC=$dec1 State=SkyCal TimeProcess=-99" | tr ' ' '\n' >$MonitorParameterslog
        curl $UploadParameterfile  -F fileUpload=@$MonitorParameters.log
  }

xProcessMonitorStatTempMaking ( )                                                                           
  {
       echo "This case shows Temp making"
       echo "TimeObsUT=$TimeForEndObsUT Obj_Num=-99 bgbright=-99 Fwhm=$fwhm_comimage S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$comimage  RA=$ra1 DEC=$dec1 State=TempMaking TimeProcess=-99" | tr ' ' '\n' >$MonitorParameterslog
        curl $UploadParameterfile  -F fileUpload=@$MonitorParameters.log
  }

xProcessMonitorStatTempMakingWaiting ( )                                                                           
  {
       echo "This case shows Temp making waiting"
       echo "TimeObsUT=$TimeForEndObsUT Obj_Num=-99 bgbright=-99 Fwhm=-99 S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$fitfile  RA=$ra1 DEC=$dec1 State=TempMakeWaiting TimeProcess=-99" | tr ' ' '\n' >$MonitorParameterslog
        curl $UploadParameterfile  -F fileUpload=@$MonitorParameters.log
  }
  xProcessMonitorStatTempMakingNoGoodImage (  )
  {
       echo "This case shows the combined image is not good for temp making"
       echo "TimeObsUT=$TimeForEndObsUT Obj_Num=-99 bgbright=-99 Fwhm=fwhm_comimage S2N=-99 AverLimit=-99 Extinc=-99 xshift=-99 yshift=-99 xrms=-99 yrms=-99 OC1=-99 VC1=-99 Image=$comimage  RA=$ra1 DEC=$dec1 State=BadComImage TimeProcess=-99" | tr ' ' '\n' >$MonitorParameterslog
        curl $UploadParameterfile  -F fileUpload=@$MonitorParameters.log
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
     sex $fitfile  -c  xmatchdaofind.sex -DETECT_THRESH 6 -ANALYSIS_THRESH 6 -CATALOG_NAME image.sex -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME       $bg
    rm -rf $bg
    Num_imgquality=`wc -l image.sex | awk '{print($1)}'`
    echo "source num. in Sync image is:  $Num_imgquality"
    xProcessMonitorStatSkyCal
    if [ $Num_imgquality -lt 5000 ]
    then   
        rm newimageCoord.list newimageCoord 
        echo "$fitfile is not good for Sky coordinate calibration ! "
        echo "$fitfile is not good for Sky coordinate calibration !" >> $stringtimeForMonitor
        continue
    else    
        echo "this sync image is good" >>$stringtimeForMonitor
	    cp newimageCoord newimageCoord.list
        xautoSkyCoordCali
    fi      
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
dec_flag=`echo $fitfile | cut -c19-19`
if [ $dec_flag  -ne  0  ]
then
	dec_temp=`echo $fitfile | cut -c19-21`
else
	dec_temp=`echo $fitfile | cut -c20-21`
fi
echo "DEC of $dec_temp is obtained for this $fitfile " `date` >>$stringtimeForMonitor
ra_flag=`echo $fitfile | cut -c16-16`
if [ $ra_flag -ne 0 ]
then
	ra_temp=`echo $fitfile | cut -c16-18`
else
	ra_temp=`echo $fitfile | cut -c17-18`
fi
echo "RA of $ra_temp is obtained for this $fitfile " `date` >>$stringtimeForMonitor
sethead -kr X RA=$ra_temp DEC=$dec_temp  $fitfile
echo "sethead the $ra_temp and $dec_temp to img head of $fitsfile " >>$stringtimeForMonitor  
#---------------------------------------------------

TimeForEndObsUT=`gethead $fitfile "T-END-UT"`
ID_MountCamara=`gethead  $fitfile "IMAGEID" | cut -c14-17`
ra1=`gethead $fitfile "RA"`
dec1=`gethead $fitfile "DEC" `
ra_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$1)}'`
dec_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$2)}'`
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
ID_MountCamara=`gethead $fitfile "IMAGEID"  | cut -c14-17`
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

xcheckDarkimgQuality (   )
{
    rm -rf image.sex                                                                                                                               
    xfits2jpg &
    sex $fitfile  -c  xmatchdaofind.sex -DETECT_THRESH 6 -ANALYSIS_THRESH 6 -CATALOG_NAME image.sex -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $bg  
    rm -rf $bg
    Num_imgquality=`wc -l image.sex | awk '{print($1)}'`
    tempset=`gethead $fitfile "tempset" | awk '{print($1)}'`
    tempact=`gethead $fitfile "tempact" | awk '{print($1)}'`
    Delta_temp=`echo $tempset $tempact | awk '{print($1-$2)}'`
    if [ ` echo " $Delta_temp > -5.0 " | bc ` -eq 1 ] && [ ` echo " $Delta_temp < 5.0 " | bc ` -eq 1    ]
    then
        echo "temparature is normal for dark image"
    else
        echo $fitfile "is not good for the dark making since the tempact is not as the tempset"
        echo $fitfile "is not good for the dark making since the tempact is not as the tempset" >>errordarkimg.flag
        continue
    fi
    
    echo "source num. in dark image is: " $Num_imgquality
    if [ $Num_imgquality -gt 1000   ]
    then            
    ┊   echo $fitfile "is not good for the dark making ! "
    ┊   echo $fitfile "is not good !" >>errordarkimg.flag
    ┊   continue    
    else
        echo "This dark image is good"
    fi              
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
    		 echo "imhead is not complete"  `date` >>$stringtimeForMonitor
 	fi
else
	sleep 2
fi 
xwfits2fit  #if it is a fits
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
  echo "to read the ccdtype in imhead "  `date` >>$stringtimeForMonitor
  ID_ccdtype=`gethead "CCDTYPE" $fitfile`
  MonitorParameterslog=`echo $fitfile | sed 's/\.fit/.fit.monitorParaLog/'`
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
        xcheckDarkimgQuality
          ls $fitfile >>listdark
          line_darklist=`wc -l listdark | awk '{print($1)}'`
          if [ $line_darklist -gt 10 ]
          then
		  echo "dark combination  " `date`   >>$stringtimeForMonitor
                  ./xdarkcom.sh
                  wait
                  rm -rf *_5_* listdark
                  stringtime=`date -u +%Y%m%d%H%M%S`
                  basicstring=`echo "Dark_"$stringtime".fit"`
                  cp -f Dark.fit  $basicstring
                  cp -f Dark.fit $basicstring badpixelFile.db $dir_basicimage

          else
                  echo "dark image is not enough"
          fi
  elif [ "$ID_ccdtype"x = "FLAT"x ]  # it is a flat image
  then
    #  if test -r recopy_WrongCCDtype.flag
    #  then
    #      rm recopy_WrongCCDtype.flag
    #  fi
          ls $fitfile >>listflat
          line_flatlist=`wc -l listflat | awk '{print($1)}'`
          if [ $line_flatlist -gt 10 ]
          then
                  ./xflatcom.sh
                  wait
                  rm -rf listflat *_6_*
                  stringtime=`date -u +%Y%m%d%H%M%S`
                  basicstring=`echo "Flat_"$stringtime".fit"`
                  cp -f Flat_bg.fit $basicstring
                  cp -f Flat_bg.fit $basicstring $dir_basicimage
          else
                  echo "flat image is not enough"
          fi
  else   # error image

	echo "image with wrong ccdtype"
	echo "image with wrong ccdtype"  `date` >>$stringtimeForMonitor
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
    rm -rf *Initial*.fits
	if test ! -r oldlist
	then
        	touch oldlist
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
		#diff oldlist newlist | grep  ">" | tr -d '>' | column -t >listmatch1
		#==========================
		#just for the sort the image of dark, flat, object frames
		Ndark=`cat listmatch1 | grep "_5_" | wc -l` #dark frames
                if [ $Ndark -gt 0  ]
                then
                        cat listmatch1 | grep "_5_" | head -1 >list
			cp -f list listmatch
			cat list >>oldlist
			sort oldlist >oldlist1
			mv oldlist1 oldlist
                else 
			Nflat=`cat listmatch1 | grep "_6_" | wc -l` #flat frames	
			if [ $Nflat -gt 0 ]
			then
				cat listmatch1 | grep "_6_" | head -1 >list
				cp -f list listmatch
				cat list >>oldlist
				sort oldlist >oldlist1
				mv oldlist1 oldlist
			else  # object frames
				echo "it is an object image"  `date` >> $stringtimeForMonitor
                cat listmatch1 | grep -v "_5_" | grep -v "_6_" | tail -1 >list # to reduce the new image always, but might miss some images.   it is might be _1_ for obj or _7_ for temp model 
				cp -f list listmatch
				echo "copy list to listmatch"  `date` >> $stringtimeForMonitor
				if test ! -r listreduc
				then
					touch listreduc
				fi
				cat list >>listreduc
				cat listmatch >>oldlist
				echo "begin to sort the oldlist"  `date` >> $stringtimeForMonitor
				sort oldlist >oldlist1
				echo "sort oldlist is over"  `date` >> $stringtimeForMonitor
				mv oldlist1 oldlist

	#		    	cat listmatch1  | grep "_1_" | head -1 >list  #head -1 means the image is reduced one by one, which may make the delay for the new image, if we want to make sure that the soft is always reduce the new image, head -1 should be changed to tail -1
        #                       cp -f list listmatch
        #                       cat list >>oldlist
        #                       sort oldlist >oldlist1
        #                       mv oldlist1 oldlist
			
			fi
                fi
		#cat listmatch1 | head -1 >list
		#===================================
		#cat list
#		cp -f list listmatch
#		cat list >>oldlist
#		sort oldlist >oldlist1
#		mv oldlist1 oldlist

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
#			xwfits2fit  #if it is a fits
#			#&&&&&&&&&&&&&&&&&&#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   # if it is a fit
#			#echo "---------no need to do the xwfits2fit-------"
##			fitfile=`echo $FILE | sed 's/.fits/.fit/'`
##			fitfilegz=`echo $FILE | sed 's/.fit/.fit.gz/'`
##			ls $fitfile >listmatch
##			cp -f $fitfile listmatch $Dir_redufile
##			gzip -f $fitfile
##			if test ! -r fitsbakfile
##			then
##			        mkdir fitsbakfile
##			fi
##			#rm -rf $FILE 
##			mv $fitfilegz fitsbakfile
##			cd $Dir_redufile
#	
#			#&&&&&&&&&&&&&&&&&&#@@@@@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#			ID_ccdtype=`gethead "CCDTYPE" $fitfile`
#			if [ "$ID_ccdtype"x = "DARK"x ]  #it is a dark image
#			then
#				ls $fitfile >>listdark
#				line_darklist=`wc -l listdark | awk '{print($1)}'`
#				if [ $line_darklist -gt 10 ]
#				then
#					./xdarkcom.sh
#					wait
#					rm -rf *_5_* listdark
#					stringtime=`date -u +%Y%m%d%H%M%S`
#					basicstring=`echo "Dark_"$stringtime".fit"`
#					cp -f Dark.fit  $basicstring 
#					cp -f Dark.fit $basicstring badpixelFile.db $dir_basicimage
#					
#				else
#					echo "dark image is not enough"
#				fi
#			elif [ "$ID_ccdtype"x = "FLAT"x ]  # it is a flat image
#			then
#                                ls $fitfile >>listflat
#                                line_flatlist=`wc -l listflat | awk '{print($1)}'`
#                                if [ $line_flatlist -gt 10 ]
#                                then
#                                        ./xflatcom.sh
#                                        wait
#                                        rm -rf listflat *_6_*
#					stringtime=`date -u +%Y%m%d%H%M%S`
#					basicstring=`echo "Flat_"$stringtime".fit"`
#					cp -f Flat_bg.fit $basicstring
#					cp -f Flat_bg.fit $basicstring $dir_basicimage
#                                else
#                                        echo "flat image is not enough"
#                                fi
#			else   # it is the object images
#				xcheckAndMakeTemp
#				wait
#				date
#			fi
			#&&&&&&&&&&&&&&&&&&#@@@@@#@@@@@@@@
		fi
	else
		sleep 4
        DataProcessWorkingflag=`echo $Dir_rawdata | cut -c1-5 | awk '{print($1".workingflag")}'`
        touch $DataProcessWorkingflag 
        curl $UploadParameterfile  -F fileUpload=@$DataProcessWorkingflag
	fi
	cd $Dir_rawdata
done
