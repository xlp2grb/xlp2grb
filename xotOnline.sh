#!/bin/bash
#date >time_redu_f
#echo /home/xlp/iraf/focus.online.20120815/
#cp /home/jianyan/software/xgwacsoft/OTdetect/xotmatch.soft/* ./
#cp /home/jianyan/software/xgwacsoft/xotmatch.soft.20121211/* ./
#modified by xlp at 20140124
#modified by xlp at 20140127

#===============================================================================
echo "xotOnline.sh newdata_dir"
Dir_monitor=/data2/workspace/monitor/
Dir_temp=/data2/workspace/tempfile/result
dir_basicimage=/data2/workspace/basicfile
#echo "Please input your data directory"
#echo "like this: /home/xlp/data/gwac/rawdata/20130113" 
#read Dir_rawdata
stringtimeForMonitorT=`date -u +%Y%m%d`
stringtimeForMonitor=`echo $Dir_monitor"listFormonitor_"$stringtimeForMonitorT`
Dir_rawdata=$1
Dir_redufile=`pwd`
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

fitfile_prefix=`echo $FILE | sed 's/.fits//'`
fitfile=`echo $FILE | sed 's/.fits/.fit/'`
fitfilegz=`echo $FILE | sed 's/.fits/.fit.gz/'`
#echo $fitfilegz $fitfile
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
cd $Dir_rawdata
ls $fitfile >listmatch
cp -f $fitfile listmatch $Dir_redufile
gzip -f $fitfile
if test ! -r fitsbakfile
then
	mkdir fitsbakfile
fi
#rm -rf $FILE 
mv $fitfilegz $FILE fitsbakfile
rm -rf $fitfile
#echo "--------------------"
cd $Dir_redufile


}


xMainReduction ( )
{
    if test -r NoTempButSentFwhm.flag
    then
        rm NoTempButSentFwhm.flag averagefile
    fi
	echo "------xmatch.sh-------"
	date
	echo "Begin to do the main reduction on OT extractor" >>$stringtimeForMonitor
	./xmatch.sh
    wait
}


#==========================================================================================
xsentFwhmToMonitor (  )
{
    fwhmrespng=`echo $FITFILE | cut -c4-5 | awk '{print("M"$1"_fwhm.png")}'`
    mv average_fwhm.png $fwhmrespng
    ./xatcopy_remoteimg.f $fwhmrespng $IPforMonitorAndTemp $Dir_IPforMonitorAndTemp &
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
	echo "combine last 5 images" >>$stringtimeForMonitor
	./xcom_withoutshift5images.sh newcomlist $comimage 
	wait
	rm -rf fwhm_lastdata
	./xFwhmCal_noMatch.sh $Dir_redufile $comimage 
	wait
    xsentFwhmToMonitor &
	if test ! -s fwhm_lastdata
	then
		echo "No ouptut for xFwhmCal_noMatch.sh"
		echo "No ouptut for xFwhmCal_noMatch.sh"  >>$stringtimeForMonitor
	else
		fwhm_comimage=`cat fwhm_lastdata | awk '{print($5)}'`
		NstarForfwhm=`cat fwhm_lastdata | awk '{print($4)}'`
		echo "The fwhm for combined image is:"$fwhm_comimage
		if [ `echo " $fwhm_comimage < 2.0"  | bc ` -eq 1 ] &&  [ `echo " $NstarForfwhm > 300"  | bc ` -eq 1 ]
		then
			sethead -kr X TODO=tempMaking $comimage
			rm -rf newcomlist 
			touch imcombine.flag
		        touch xatcopy_remote.flag  #make a flag
			echo "Have imcombine.flag"
			ipfile=`echo "ip_address_"$ID_MountCamara".dat"`
		        echo $ipadress $Dir_temp >$ipfile
			echo "copy the combined image to the temp making computer" >>$stringtimeForMonitor
		        ./xatcopy_remoteimg2.f $ipfile $comimage  $temp_ip $temp_dir"/"$ID_MountCamara
		        wait
			#sleep 300  #modified by xlp at 20140826
		        rm -rf imcombine.flag $comimage newcomlist listupdate 
		else 
			rm -rf imcombine.flag $comimage newcomlist listupdate
			echo "The combined image is not good, fwhm is:" $fwhm_comimage
			echo "The combined image is not good, fwhm is:" $fwhm_comimage  >>$stringtimeForMonitor
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
date
gpfile=`echo $Dir_temp"/"GPoint_catalog`
errorimage=`echo $Dir_temp"/"errorimage.flag`
if test ! -r $gpfile
then
	echo "no GPoint_catalog"
	echo "no GPoint_catalog" >>$stringtimeForMonitor
	#echo 0 0 0 0 test test1 >Point_catalog
	xCheckFirstMaking
else 
	echo "Have GPoint_catalog"
	echo "Have GPoint_catalog" >>$stringtimeForMonitor
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
	echo "have error image flag" >>$stringtimeForMonitor
            rm -rf xatcopy_remote.flag notemp.flag $errorimage newcomlist
    fi

    if test -r xatcopy_remote.flag
    then
	echo "first have xatcopy_remote.flag" >>$stringtimeForMonitor
            echo "first have xatcopy_remote.flag"
            #sleep 180 #modified by xlp at 20140826 
	ls $fitfile >>xMissmatch.list
	xfits2jpg &
	./xFwhmCal_noMatch.sh $Dir_redufile $fitfile
	wait
    xsentFwhmToMonitor &
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
		echo "copy the temp from tempfile" >>$stringtimeForMonitor
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
date
#ipadress=`ifconfig | head -2 | tail -1 | sed 's/:/ /g' | awk '{print($2)}'`
ipadress=`ifconfig | grep "inet" |  awk '{if($5=="broadcast")print($2)}'`

#-----------------------------------------------
#readme the RA DEC from the fits name and set them into the header
dec_flag=`echo $fitfile | cut -c19-19`
if [ $dec_flag  -ne  0  ]
then
	dec_temp=`echo $fitfile | cut -c19-21`
else
	dec_temp=`echo $fitfile | cut -c20-21`
fi
ra_flag=`echo $fitfile | cut -c16-16`
if [ $ra_flag -ne 0 ]
then
	ra_temp=`echo $fitfile | cut -c16-18`
else
	ra_temp=`echo $fitfile | cut -c17-18`
fi

sethead -kr X RA=$ra_temp DEC=$dec_temp  $fitfile

#---------------------------------------------------

ID_MountCamara=`gethead  $fitfile "IMAGEID" | cut -c14-17`
ra1=`gethead $fitfile "RA"`
dec1=`gethead $fitfile "DEC" `
ra_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$1)}'`
dec_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$2)}'`
echo $ra_mount $dec_mount $ID_MountCamara >newimageCoord
if test -s newimageCoord.list
then
	RaLast=`cat newimageCoord.list | awk '{print($1)}'`
#	echo $RaLast $ra_mount
	if [ "$RaLast"  != "$ra_mount"  ]
	then
		echo "New sky field"
		echo "New sky field" >>$stringtimeForMonitor
		rm -rf listsky newcomlist newxyshift.cat
		xcheckskyfield
	else
		echo "This sky field is continuing"
		echo "This sky field is continuing" >>$stringtimeForMonitor
		xcheckifcopy
	fi
	cp newimageCoord newimageCoord.list
else
	cp newimageCoord newimageCoord.list
	xcheckskyfield
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
curl http://190.168.1.25/realTimeOtDstImageUpload  -F fileUpload=@$ccdimgjpg
#./xatcopy_remoteimg.f $ccdimgjpg 190.168.1.40 ~/web & 
wait
rm -rf $ccdimgjpg
}

XtellCCDtype ( )
{
echo "====xtellCCDtype===="
 Nimhead=`imhead $FILE | wc -l | awk '{print($1)}'`
 echo $Nimhead
 if [ ` echo " $Nimhead < 50 " | bc ` -eq 1 ]
 then
     echo "imhead is not complete, waiting 1 second"
     sleep 1
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
  ID_ccdtype=`gethead "CCDTYPE" $fitfile`
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
          ls $fitfile >>listdark
          line_darklist=`wc -l listdark | awk '{print($1)}'`
          if [ $line_darklist -gt 10 ]
          then
		  echo "dark combination" >>$stringtimeForMonitor
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
	rm -rf *Initial*.fits
	if test ! -r oldlist
	then
        	touch oldlist
	fi

	date >time_redu_f
#	if test ! -r M*.fits
#	then
#		sleep 1
#		continue
#	fi	
	ls *.fits >newlist
	linenewimage=`cat newlist | wc -l`
        if [ $linenewimage -eq 0  ]
        then
		echo "Waiting new image..."
                sleep 10
                continue
        fi

	diff oldlist newlist | grep  ">" | tr -d '>' | column -t >listmatch1
	line=`cat listmatch1 | wc -l`
	if  [ "$line" -ne 0 ]
	then 
		echo "New image exits!"
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
                		cat listmatch1 | grep -v "_5_" | grep -v "_6_" | tail -1 >list # to reduce the new image always, but might miss some images.   it is might be _1_ for obj or _7_ for temp model 
				cp -f list listmatch
				if test ! -r listreduc
				then
					touch listreduc
				fi
				cat list >>listreduc
				cat listmatch1 >>oldlist
				sort oldlist >oldlist1
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
		echo "&&&&&&&&&&&&&&&&"	>>$stringtimeForMonitor
		date >>$stringtimeForMonitor
		echo $FILE >>$stringtimeForMonitor
		du -a $FILE >mass
		fitsMass=`cat mass | awk '{print($1)}'`
	
		#echo "fitsMass =" $fitsMass
		
		#if [ "$fitsMass" -lt 36490 ]
		if [ "$fitsMass" -lt 18248 ]
		then
			echo "waiting ..."
			sleep 2
			XtellCCDtype
			wait
		else
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
		sleep 1
	fi
	cd $Dir_rawdata
done

#===============================================================
