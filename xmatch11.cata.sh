#!/bin/bash
#Author: xlp at 20130101
#Version: V1.0
#function: to match the newimage to the refcom.fit with xyxymatch
#input newimage 
#output *tempxyOT *skyOT
#This codes includes the catalog match and image subtraction
#image match is only donw with 1 times.
# modified by xlp at 20130110
#update the codes about the flux match for subimage
#update the codes about the FWHM calculation for xFhmwCal.sh
# modifed by xlp at 20130113
#rm -rf listsky*
DIR_data=`pwd`
sub_dir=$HOME/workspace/redufile/subfile/
lc_dir=$HOME/workspace/redufile/getlc
Alltemplatetable=refcom3d.cat
tempfile=refcom.fit
tempsubbgfile=refcom_subbg.fit
Accfile=refcom.acc
CCDsize=3056
ejmin=15
ejmax=`echo $CCDsize | awk '{print($1-ejmin)}' ejmin=$ejmin` 
crossRedius=2
darkname=Dark.fit
flatname=Flat_bg.fit

Nf=0
rm -rf matchchb.log matchchb_all.log
rm -rf list2frame.list list_fin listnewskyot.list listOT listsky listsky1 listskyotfile listskyotfileHis listskyot.list listtemp listtime 

xmknewfile.sh  # build a new directory for results
#========================================================================
for FILE in `cat listmatch`
do
	date >time_redu_f

	FITFILE=$FILE

	OUTPUT=`echo $FITFILE | sed 's/\.fit/.fit.sex/'`	# output of SourceExtractor
	OUTPUT_new=`echo $FITFILE | sed 's/\.fit/.fit.sexnew/'`	# Catalog for the bright source. Output from $OUTPUT. Input for the xyxymatch
	OUTPUT_new1=`echo $FITFILE | sed 's/\.fit/.fit.sexnew1/'`
	imagetmp1sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp1sd/'`
	imagetmp2sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp2sd/'`	# output of the xyxymatch, input for geomap	
	imagetrans1sd=`echo $FITFILE | sed 's/\.fit/.fit.trans1sd/'`
	imagetrans2sd=`echo $FITFILE | sed 's/\.fit/.fit.trans2sd/'`	# output of the geomap,
	inprefix=`echo $FITFILE | sed 's/\.fit//'`			# inprefix of the fit. it was used in the iraf.geomap and iraf.geoxytran
	OUTPUT_geoxytran2=`echo $FITFILE | sed 's/\.fit/.fit.tran2/'`	# Catalog in the temp frame relatively to the $OUTPUT. Output for the geoxytran 
	crossoutput_xy=`echo $FITFILE | sed 's/\.fit/.fit.tempxyOT/'`	# Output of the Crossmatch in the temp frame. This code is writed by CHB. It is also the input for cctran.
	crossoutput_sky=`echo $FITFILE | sed 's/\.fit/.fit.skyOT/'`	# Output of the iraf.cctran. The input for this process is $crossoutput_xy. Catalog in which RA DEC are included, 
	newimageOTxyFis=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT1/'`  # Output of the iraf.geoxytran. The input for this process is $crossoutput_xy. Catalog in which xc,yc are includec in the new image frame.
	OUTPUT_fwhm=`echo $FITFILE | sed 's/\.fit/.fit.fwhm/'`			# Output of the FWHM caculation code xFwhmCal_single.sh. 
	bg=`echo $FITFILE | sed 's/\.fit/.bg.fit/'`				# Output of the SourceExtractor. Background image for the new image. 

	echo $FITFILE 
	
	./xdarkcorr.sh $FITFILE $darkname                     #only doing the dark correction
#	./xdarkflatcoor.sh $FITFILE $darkname $flatname       #do the dark and flat correction simultaneously.

#	To get the source from the image by Source Extractor "sex"
	sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH 1.5 -ANALYSIS_THRESH 1.5 -CATALOG_NAME $OUTPUT -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $bg 
#=========================================================================
#	echo `date` "1sh match obj extracted"
        xNpixel=`gethead $FITFILE "NAXIS1"`
        yNpixel=`gethead $FITFILE "NAXIS2"`		
	cat $OUTPUT | awk '{if(($3-$5)/$6>30 && $4==0) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >allres1
	cat allres1 | sort -n -k 7 | head -2000 | awk '{print($1,$2,$3)}' > $OUTPUT_new
#========================================================
	echo `date` "The first tolerance match will be going on"
        matchflag=tolerance
        #Nbstar=30 #set several regions to extract the bright stars to match each other
        fitorder=6
	tempmatchstars=GwacStandall.cat

#=======================================================
	echo `date` "First tolerance match"
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl
        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"$imagetmp2sd\",toleranc=30, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=7, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
        echo "geomap(\"$imagetmp2sd\", \"$imagetrans2sd\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$yNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", maxiter=5,reject=2.5,inter-)" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile

        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
#        mv mattmp1 $imagetmp2sd
#        mv transform1.db $imagetrans2sd
#	cp $imagetrans2sd trans2sd.bak1
        if test -r $imagetrans2sd
        then
		xrms=`cat $imagetrans2sd | grep "rms" | tr '\n' ' ' | awk '{print($2)}'`
		yrms=`cat $imagetrans2sd | grep "rms" | tr '\n' ' ' | awk '{print($4)}'`
		echo "%%%%%%%%%%%%%%%%"
		echo `cat $imagetrans2sd | grep "shift"`
		echo $xrms $yrms
	#	to check wether the match is good enough or not by rms at X-axis and Y-axis.
	##	if [ ` echo " $xrms < 0.2 " | bc ` -eq 1   -o  $yrms -lt 0.2  ]
		if [ ` echo " $xrms > 0.2 " | bc ` -eq 1 ] # if good enough
		then
#============================
			./xmatch11.cat.tr.sh
#==========================================================				
#with in the information about the newxyshift from the last image to do the xyxymatch
			if test -r newxyshift.cat # shift information from the last image for which the match is successful. 
			then
			xshift=`cat newxyshift.cat | awk '{print($1)}'`
			yshift=`cat newxyshift.cat | awk '{print($2)}'`	
			#cp $OUTPUT_new OUTPUT_new
			cat $OUTPUT_new | awk '{print($1-xshift,$2-yshift,$3)}' xshift=$xshift yshift=$yshift >output_new_temp     # adding  shifts before match.
			cp output_new_temp $OUTPUT_new
			echo `date` " Tolerance match again"
#			mv $imagetrans2sd trans2sd.bak
#			mv $imagetmp2sd temp2sd.bak
			rm -rf mattmp1 transform1.db $imagetmp2sd $imagetrans2sd
		        cd $HOME/iraf
	        	cp -f login.cl.old login.cl
		        echo noao >> login.cl
		        echo image >> login.cl
		        echo "cd $DIR_data" >> login.cl
		        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp1\",toleranc=20, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=7, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
		        echo "geomap(\"mattmp1\", \"transform1.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$yNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", maxiter=5,reject=2.5,inter-)" >>login.cl
		        echo logout >> login.cl
		        cl < login.cl >xlogfile
			cd $HOME/iraf
		        cp -f login.cl.old login.cl
		        cd $DIR_data
		        echo " Tolerance match again finished"
#			mv mattmp1 $imagetmp2sd
# to rebuild a file for $imagetrans2sd, the information in which incouds rms and shift for this image relative to the temp file.
			sed -n '1,15p' mattmp1 >$imagetmp2sd
			sed -n '16,1000p' mattmp1 | awk '{print($1,$2,$3+xshift,$4+yshift,$5,$6)}' xshift=$xshift yshift=$yshift >>$imagetmp2sd
			rm -rf mattmp1
		        mv transform1.db $imagetrans2sd
		   	
			if test -r $imagetrans2sd
			then
				xrms=`cat $imagetrans2sd | grep "rms" | tr '\n' ' ' | awk '{print($2)}'`
                		yrms=`cat $imagetrans2sd | grep "rms" | tr '\n' ' ' | awk '{print($4)}'`
				echo `cat $imagetrans2sd | grep "shift"`
                        	echo `cat $imagetrans2sd | grep "rms"`
				if [ ` echo " $xrms < 0.2 " | bc ` -eq 1 ]
				then	
					echo "reconstruct the file of trans2sd"
					xshift1=`cat $imagetrans2sd | grep "xshift" | awk '{print($2)}'`
					yshift1=`cat $imagetrans2sd | grep "yshift" | awk '{print($2)}'`
					xxshift=`echo $xshift $xshift1 | awk '{print($1+$2)}'`
					yyshift=`echo $yshift $yshift1 | awk '{print($1+$2)}'`
					sed -n '1,8p' $imagetrans2sd >newfile1
					echo "	xshift		"$xxshift >>newfile1
					echo "	yshift		"$yyshift >>newfile1
					sed -n '11,25p' $imagetrans2sd >>newfile1
					echo "				"$xxshift $yyshift >>newfile1
					sed -n '27,100p' $imagetrans2sd >>newfile1
					mv newfile1 $imagetrans2sd
					echo "&&&&&&&&&&&&&&&&&&"
					echo `cat $imagetrans2sd | grep "shift"`
					echo `cat $imagetrans2sd | grep "rms"`
				else
					echo "image match faild"
#					ls $FITFILE >listmatch.temp
#					./xmatch11.cat.tr.sh
			#		mv mattmp1 $imagetmp2sd
			#	        mv transform1.db $imagetrans2sd
	
				fi
			fi
			fi
		   else
                        echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"  
                        echo `cat $imagetrans2sd | grep "shift"`
                        echo `cat $imagetrans2sd | grep "rms"`

#			echo "------------NO newxyshift.cat-----------"
#			ls $FITFILE >listmatch.temp
#			./xmatch11.cat.tr.sh
#			 mv mattmp1 $imagetmp2sd
#                         mv transform1.db $imagetrans2sd
	 	   fi
        else

		echo " Tolerence match is failed"
	        exit 1

        fi
	
#======================================================
# transform the xy of new image to temp.
	echo `date` "All xytran from image to temp"
	rm -rf $OUTPUT_geoxytran2
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl
	echo "geoxytran(\"$OUTPUT\", \"$OUTPUT_geoxytran2\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
	echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
#======================================================
#	echo "+/-2 pixel" $OUTPUT_geoxytran $Alltemplatetable $crossoutput
	echo `date` "crossmatch"  # cross match between new image and temp in XY spece.
	./CrossMatch $crossRedius $OUTPUT_geoxytran2 $Alltemplatetable $crossoutput_xy
#select out those at the edge of the image.
	cat $crossoutput_xy | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' ejmin=$ejmin ejmax=$ejmax | grep -v "99.000" >temp 
	mv temp $crossoutput_xy 
	NumOT=`wc $crossoutput_xy | awk '{print($1)}'`
	wc $crossoutput_xy
#======================================================
	if [ $NumOT -gt 3000 ]  # this might be coused by the missed crossmatch. if the case, this image would be deleted.
	then 
		echo "The Num. of possile OT is too many, might be caused by the wrough xyxymatch "
		ls $FITFILE >>xMissmatch.list
		rm -rf $OUTPUT_geoxytran2 $imagetmp2sd
	else # cross match might be successful.
	{
	#==========================================================
	#This part is to transform the xy of OT candidates into the Ra and Dec.
	echo `date` "cctran of OT to image and display"
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	echo noao >> login.cl
	echo digiphot >> login.cl
	echo image >> login.cl
	echo imcoords >>login.cl
	echo "cd $DIR_data" >> login.cl
        echo "cctran(input=\"$crossoutput_xy\",output=\"$crossoutput_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.7f\",latform=\"%12.7f\" ) " >>login.cl
       echo "geoxytran(\"$crossoutput_xy\", \"$newimageOTxyFis\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
	echo logout >> login.cl
        cl < login.cl >xlogfile
	cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
#===========================================================
#In final $crossoutput_sky, the parameters are
#ra dec ox(newIm) oy(newIm) rx(refIm) ry(refIm) flux  ***
	echo `date` "making the skyOT list"
	rm -rf listtime
	timeobs=`gethead $FITFILE "date-obs"`
	
	for ((i=0;i<$NumOT;i++))
	do
		echo $timeobs $FITFILE >>listtime
	done

	paste $crossoutput_sky $newimageOTxyFis $crossoutput_xy listtime | awk '{print($1,$2,$11,$12,$21,$22,$31,$32,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >crossoutput_skytemp
	mv crossoutput_skytemp $crossoutput_sky

#=================================
#To eject the bad pixel by the crossmatch from $crossoutput_sky and badpixelFile.db
#badpixel file is named as badpixelFile.db
	wc $crossoutput_sky
	echo "To eject the bad pixel"
	cp $crossoutput_sky newoutput
	./xAutoEjectBadpixel
	mv newoutputEjected $crossoutput_sky
	rm -rf newoutput
	wc $crossoutput_sky

##This part is also able to eject the effect by bright stars, the table is named as brightstarsFile.db
#	echo "To eject the effect from bright star"
#	cp $crossoutput_sky newoutput
#	./xAutoEjectBrightstar
#	mv newoutputEjected $crossoutput_sky
#        rm -rf newoutput
#	wc $crossoutput_sky

#===============================================
	ls $crossoutput_sky >>listsky

#	The output name is matchchb.log in which an object who appear for at least twice in 5 images.
	echo '================= Templatemark by CHB ================'	
	cat listsky | tail -5 >listsky1
	RN=`wc listsky1 | awk '{print($1)}'`
	if [ $RN -eq 5 ]
	then
		paste xChbTempBefore.log listsky1 xChbTempAfter.log >xChbTempBatch.sh
		sh xChbTempBatch.sh
		RN1=`wc matchchb.log | awk '{print($1)}'`
		if [ $RN1 -gt 0 ]
		then
			echo "@@@@@@@@@@@@@@@@"
			echo "The possible optical transients from matchchb.log are :"
			echo "Time, image, RA, DEC,xi,yi, mag, merr"
#			cat matchchb.log | awk '{print($7,$8,$1,$2,$3,$4,$14,$15)}'
			cat matchchb.log |  awk '{print($5,$6)}' >temp2framecoord_ref
			cat matchchb.log | awk '{print($3,$4)}' >temp2framecoord_new
			echo "@@@@@@@@@@@@@@@@"
			if test -r matchchb_all.log
			then
				cat matchchb_all.log matchchb.log >matchchb_all.log1
				mv matchchb_all.log1 matchchb_all.log
			else
				cp matchchb.log matchchb_all.log
			fi
			
			cp matchchb_all.log list2frame.list
			#cp matchchb.log newframeOT.obj
			wc matchchb.log
			cat matchchb.log | awk '{print($1,$2,$3,$4,$5,$6,$7,$8,$14,$15,$16)}' | sed 's/T/ /' | sed 's/:/ /g' >temp1
			cat temp1 | awk '{if($13<3)print($1,$2,$3,$4,$5,$6,$7"T"$8":"$9":"$9,$8+$9/60+$10/3600,$11,$12,$13,$14)}' |tr -s '\n' | sort -n -k 5 | sort -n -k 6 | uniq | column -t >newframeOT.obj
			xlc_new1 #output is newStableStar.cat and newVarableStar.cat
			sort -n -r -k 15 newVarableStar.cat >temp1
			mv temp1 newVarableStar.cat
			wc newVarableStar.cat

			
		else
			echo "@@@@@@@@@@@@ No transient candidates in the last 5 images @@@@@@@@@@@@@@@@@@"
		fi
	else
		echo '***************The files in listsky1 are less than 5 ****************'
	fi

#===============================================

	echo "=============="
#	cat list2frame.list | awk '{printf("%f %f %s %s %f %f \n ",$5,$6,$7,$8,$14,$15)}' |tr -s '\n' | sort -n -k 1 | sort -n -k 2 | uniq | column -t>updaterefcom3d.cat

#	cat newframeOT.obj | awk '{print($7,$8,$1,$2,$3,$4)}' 
	echo "=============="
	if test -r listskyot.list
	then
		echo "===="		
	else
		cp $crossoutput_sky listskyot.list
	fi
	cp $crossoutput_sky listnewskyot.list
	displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
	
	gnuplot plot2frame.gn  # it includs listnewskyot.list listskyot.list list2frame.list newframeOT.obj
        kill -9 $displayPadNum
#	display plot3frame.png &
#        display -resize 1012x1012+0+0  plot3frame.png &
#	display -resize 1012x1012+0+0  plot2frame.png &
	display plot2frame.png &
	ls $crossoutput_sky >>listskyotfile
	cat listskyotfile | tail -40 >listskyotfileHis
	cp listskyotfileHis listskyotfile

	rm -rf listskyot.list	
	for file in `cat listskyotfileHis`
	do
		cat $file >>listskyot.list
	done
#	cat listskyot.list.all $crossoutput_sky | uniq >listskyot.list 
#	cp listskyot.list listskyot.list.all

#=================================================
        echo `date` "display temp and new image and tvmark these OT"
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo digiphot >> login.cl
        echo image >> login.cl
        echo imcoords >>login.cl
        echo "cd $DIR_data" >> login.cl
        echo "display(image=\"$FITFILE\",frame=1)" >>login.cl #display newimage in frame 1
        echo "display(image=\"$tempfile\",frame=2)" >>login.cl #display temp file in frame 2
        echo "tvmark(frame=1,coords=\"$newimageOTxyFis\",mark=\"circle\",radii=10,color=205,label-)" >>login.cl # tvmark new OT in frame 1
#        echo "tvmark(frame=1,coords=\"temp2framecoord_new\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl # tvmark new OT in frame 1
#	echo "tvmark(frame=1,coords=\"temp2framecoord_new\",mark=\"circle\",radii=20,color=204,label-)" >>login.cl # tvmark new OT in frame 1
#        echo "tvmark(frame=2,coords=\"temp2framecoord_ref\",mark=\"circle\",radii=100,color=205,label-)" >>login.cl # tvmark new OT in frame 2
#	echo "tvmark(frame=2,coords=\"temp2framecoord_ref\",mark=\"circle\",radii=20,color=205,label-)" >>login.cl # tvmark new OT in frame 2
#        echo "tvmark(frame=2,coords=\"$crossoutput_xy\",mark=\"circle\",radii=10,color=204,label-)" >>login.cl #tvmark new OT in frame 2

#        echo "tvmark(frame=1,coords=\"$crossoutput_xy\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl #tvmark new OT in frame 2
#        echo "tvmark(frame=3,coords=\"temp3framecoord_ref\",mark=\"circle\",radii=100,color=204,label+)" >>login.cl #tvmark new OT in frame 3
#      # echo "tvmark(frame=2,coords=\"$newimageOTxyFis\",mark=\"circle\",radii=10,color=204,label+)" >>login.cl # tvmark new OT in frame 2
#        echo logout >> login.cl
#        cl < login.cl >xlogfile
#        cd $HOME/iraf
#        cp -f login.cl.old login.cl
#        cd $DIR_data


	
#=======================================================
#produce the xyshift.cat in which xshift and yshift are shown.
#which is used to distinguish which match method will be adapted, triangles or tolerance.
	echo `date` "Producing the xyshift for the guider "
	if test -r newxyshift.trcat #output from xmatch5sigma.tr.sh
	then
		echo "newxyshift.trcat exist"
		mv newxyshift.trcat newxyshift.cat
	else
		echo "newxyshift.trcat does not exist"
		cat  $imagetrans2sd | grep "shift" | awk '{print($2)}' | tr '\n' '  ' > newxyshift.cat
		echo >> newxyshift.cat
	fi
	cat newxyshift.cat  >>xyshiftall.cat
# =======================================================
#For this part, it has not finished because it depends on the huanglei's code.
#	cat $imagetrans1sd $imagetrans2sd | grep "rms" | awk '{print($2)}' | tr '\n' '  ' 
#	./xsentshift #sent the shift values to telescope controlers.  
#======================================================
#This part is to calculate the FWHM for those standard stars in the new image
#	echo `date` "Calculating the mean FWHM for this image"
	./xFwhmCal_single.sh $DIR_data $FITFILE $imagetmp2sd $OUTPUT_fwhm 
	ls $crossoutput_sky >listOT

#======================================================
# This part might not be correct, so it is not used right now. It should be checked later.
#	echo `date` "Trim the subimage around the OT from reference and new images"
#	./xTrimIm.sh & 
#=====================================================
	date >time_redu1
	cat time_redu_f time_redu1 >time_redu2
#	cat time_redu2 | awk '{print($5)}' | sed 's/:/ /g' | tr '\n' ' ' | awk '{print(($4-$1)*3600+($5-$2)*60+($6-$3))}' >time_cal
	cat time_redu2 | awk '{print($4)}' | sed 's/:/ /g' | tr '\n' ' ' | awk '{print(($4-$1)*3600+($5-$2)*60+($6-$3))}' >time_cal
	time_need=`cat time_cal`
	echo `date`', All were done in ' $time_need 'sec'
#======================================================
	rm -rf  bak.fit  Res* 
#	rm -rf *2sd.fit $FITFILE 

#	cp $Alltemplatetable $tempfile $tempsubbgfile $Accfile $tempmatchstars $sub_dir
#	mv  $imagetmp2sd $OUTPUT_new $bg $imagetrans2sd $FITFILE $sub_dir
	mv $FITFILE $imagetrans2sd  $lc_dir
	rm -rf $bg
#=======================================================
	date -u >time_dir
	year=`cat time_dir | awk '{print($6)}'`
	month=`cat time_dir | awk '{print($2)}'`
	day=`cat time_dir | awk '{print($3)}'`
	wholeotdirectory=`echo "$HOME/workspace/resultfile/"$year$month$day"/wholeimfile"`
	resultfiles=`echo $inprefix"*"`
	skyOTfile=`echo $inprefix".fit.skyOT"`
#	cp $resultfiles $wholeotdirectory 
#	gzip $FITFILE
#       cp $wholeotdirectory/$skyOTfile ./
#=================================================
	}
	fi
	echo "***************Cataloge reduction finished**********************"
done
