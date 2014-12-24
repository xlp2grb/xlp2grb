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
Alltemplatetable=refcom3d.cat
tempfile=refcom.fit
tempsubbgfile=refcom_subbg.fit
Accfile=refcom.acc
CCDsize=3056
ejmin=5
ejmax=`echo $CCDsize | awk '{print($1-ejmin)}' ejmin=$ejmin` 
crossRedius=2
darkname=Dark.fit
#./xmknewfile.sh
#========================================================================
for FILE in `cat listmatch`
do
	date >time_redu_f

	FITFILE=$FILE
        tran1=`echo $FITFILE | sed 's/\.fit/.1sd.fit/'`
        tran2=`echo $FITFILE | sed 's/\.fit/.2sd.fit/'`
        subimage=`echo $FITFILE | sed 's/\.fit/.sub.fit/'`

	OUTPUT=`echo $FITFILE | sed 's/\.fit/.fit.sex/'`
	OUTPUT_new=`echo $FITFILE | sed 's/\.fit/.fit.sexnew/'`	

	imagetmp1sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp1sd/'`
	imagetmp2sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp2sd/'`
        imagetrans1sd=`echo $FITFILE | sed 's/\.fit/.fit.trans1sd/'`
	imagetrans2sd=`echo $FITFILE | sed 's/\.fit/.fit.trans2sd/'`

	inprefix=`echo $FITFILE | sed 's/\.fit//'`
#	refnew_xyflux=`echo $FITFILE | sed 's/\.fit/.fit.refnew_xyflux.cat/'`
#	CoordDiff_table=`echo $FITFILE | sed 's/\.fit/.fit.coordiff.cat/'`

	OUTPUT_geoxytran1=`echo $FITFILE | sed 's/\.fit/.fit.tran1/'`
	OUTPUT_geoxytran2=`echo $FITFILE | sed 's/\.fit/.fit.tran2/'`

	crossoutput_xy=`echo $FITFILE | sed 's/\.fit/.fit.tempxyOT/'`
	crossoutput_sky=`echo $FITFILE | sed 's/\.fit/.fit.skyOT/'`

	newimageOTxyFis=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT1/'`
	newimageOTxySecond=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT2/'`
	OTtable3frameHave=`echo $FITFILE | sed 's/\.fit/.fit.skyOT.3frameHave/'`
	OTtable3frameNoAll=`cat $FITFILE | sed 's/\.fit/.fit.skyOT.3frameNotAllHave/'`

	OUTPUT_fwhm=`echo $FITFILE | sed 's/\.fit/.fit.fwhm/'`
	bg=`echo $FITFILE | sed 's/\.fit/.bg.fit/'`
	GwacOT=`echo $FITFILE | sed 's/\.fit/.fit.subOT.db/'`
	newimageGwacOTxyFis=`echo $FITFILE | sed 's/\.fit/.fit.subnewxyOT1/'`
	GwacOT_sky=`echo $FITFILE | sed 's/\.fit/.fit.sub_skyOT.db/'`
	GwacOT_sky_paste=`echo $FITFILE | sed 's/\.fit/.fit.sub_skyxyOT.db/'`
	subbg=`echo $OUTPUT_new | sed 's/\.fit.sexnew/.bgsub.fit/'`
	fluxcorr=`echo $OUTPUT_new | sed 's/\.fit.sexnew/.fluxcorr.fit/'`
#	subimage=`echo $OUTPUT_new | sed 's/\.fit.sexnew/.sub.fit/'`
	subOUTPUT=`echo $OUTPUT_new | sed 's/\.fit.sexnew/.sub.sex/'`
	subOUTPUT_sel=`echo $OUTPUT_new | sed 's/\.fit.sexnew/.sub.sex.sel/'`
	echo $FITFILE 
	
	./xdarkcorr.sh $FITFILE $darkname

	sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH 1.5 -ANALYSIS_THRESH 1.5 -CATALOG_NAME $OUTPUT -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $bg 
#=========================================================================
#	echo `date` "1sh match obj extracted"
        xNpixel=`gethead $FITFILE "NAXIS1"`
        yNpixel=`gethead $FITFILE "NAXIS2"`		
	cat $OUTPUT | awk '{if(($3-$5)/$6>30 && $4==0) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >allres1
	cat allres1 | sort -n -k 7 | head -2000 | awk '{print($1,$2,$3)}' > $OUTPUT_new
#========================================================
	echo `date` "The second match will be going on"
        matchflag=tolerance
        #Nbstar=30 #set several regions to extract the bright stars to match each other
        fitorder=6
	tempmatchstars=GwacStandall.cat

#=======================================================
	echo `date` "2th match"
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
        mv mattmp1 $imagetmp2sd
        mv transform1.db $imagetrans2sd
        if test -r $imagetrans2sd
        then
		echo `cat $imagetrans2sd | grep "shift"`
                echo `cat $imagetrans2sd | grep "rms"`
        else

		echo "2th match is failed"
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
#        echo "geoxytran(\"$OUTPUT\", \"$OUTPUT_geoxytran1\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#        echo "geoxytran(\"$OUTPUT_geoxytran1\", \"$OUTPUT_geoxytran2\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
	echo "geoxytran(\"$OUTPUT\", \"$OUTPUT_geoxytran2\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
	echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
#======================================================
#	echo "+/-2 pixel" $OUTPUT_geoxytran $Alltemplatetable $crossoutput
	echo `date` "crossmatch"
	./CrossMatch $crossRedius $OUTPUT_geoxytran2 $Alltemplatetable $crossoutput_xy
	cat $crossoutput_xy | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' ejmin=$ejmin ejmax=$ejmax >temp
	mv temp $crossoutput_xy 
	NumOT=`wc $crossoutput_xy | awk '{print($1)}'`
	wc $crossoutput_xy
#======================================================
	if [ $NumOT -gt 500 ] 
	then 
		echo "The Num. of possile OT is too many, might be caused by the wrough xyxymatch "
		ls $FITFILE >>xMissmatch.list
	else
	{
	#==========================================================
	#This part is to transform the xy of OT into the Ra and Dec.
	echo `date` "cctran of OT to image and display"
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	echo noao >> login.cl
	echo digiphot >> login.cl
	echo image >> login.cl
	echo imcoords >>login.cl
	echo "cd $DIR_data" >> login.cl
#        echo "cctran(input=\"$crossoutput_xy\",output=\"$crossoutput_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"hours\",latunits=\"hours\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.2h\",latform=\"%12.2h\" ) " >>login.cl
        echo "cctran(input=\"$crossoutput_xy\",output=\"$crossoutput_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.7f\",latform=\"%12.7f\" ) " >>login.cl
       echo "geoxytran(\"$crossoutput_xy\", \"$newimageOTxyFis\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#        echo "geoxytran(\"$newimageOTxyFis\", \"$newimageOTxySecond\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#       echo "display(image=\"$tempfile\",frame=1)" >>login.cl #display temp file in frame 1
#       echo "display(image=\"$FITFILE\",frame=2)" >>login.cl #display newimage in frame 2
#       echo "tvmark(frame=1,coords=\"$crossoutput_xy\",mark=\"circle\",radii=10,color=205,label+)" >>login.cl #tvmark new OT in frame 1
#       echo "tvmark(frame=1,coords=\"$crossoutput_xy\",mark=\"circle\",radii=100,color=205,label-)" >>login.cl #tvmark new OT in frame 1
#       echo "tvmark(frame=2,coords=\"$newimageOTxySecond\",mark=\"circle\",radii=10,color=204,label+)" >>login.cl # tvmark new OT in frame 2
#       echo "tvmark(frame=2,coords=\"$newimageOTxySecond\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl # tvmark new OT in frame 2
#	echo "cctran(input=\"$GwacOT\",output=\"$GwacOT_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.6f\",latform=\"%12.6f\" ) " >>login.cl
#	echo "display(image=\"$subimage\",frame=3)" >>login.cl #display newimage in frame 3
#	echo "tvmark(frame=3,coords=\"$GwacOT\",mark=\"circle\",radii=10,color=204,label-)" >>login.cl # tvmark new OT in frame 3
#	echo "tvmark(frame=3,coords=\"$GwacOT\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl # tvmark new OT in frame 3
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

        #cat $crossoutput_sky | awk '{print($1,$2)}' >radec
        #cat radec | awk '{printf("%s_%s\n",$1,$2)}' >radecstring
        #echo "#tempxc tempyc radecstring ra dec(J2000) newxc newyc flux flags background threshold mag_aper magerr ellipticity class_star date image " >crossoutput_skytemp
        #paste $crossoutput_xy radecstring radec listtime $newimageOTxyFis | awk '{print($1,$2,$11,$12,$13,$16,$17,$3,$4,$5,$6,$7,$8,$9,$10,$14,$15)}'| column -t >>crossoutput_skytemp

  	
	paste $crossoutput_sky $newimageOTxyFis $crossoutput_xy listtime | awk '{print($1,$2,$11,$12,$21,$22,$31,$32,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >crossoutput_skytemp
	mv crossoutput_skytemp $crossoutput_sky
	ls $crossoutput_sky >>listsky
	./xcrossotForlast3frames.sh  #output is named $fitsfile.3frameHave and $fitsfile.3frameNoHave
	RN=`wc $OTtable3frameHave | awk '{print($1/3)}'`
	echo $RN "candidates for last three images"
 #      wc $OTtable3frameHave
	cat $OTtable3frameHave | awk '{print($5,$6)}' >temp3framecoord_ref
	cat $OTtable3frameHave | awk '{print($3,$4)}' >temp3framecoord_new
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
	echo "tvmark(frame=1,coords=\"$newimageOTxyFis\",mark=\"circle\",radii=10,color=204,label-)" >>login.cl # tvmark new OT in frame 2
	echo "tvmark(frame=1,coords=\"temp3framecoord_new\",mark=\"circle\",radii=100,color=205,label+)" >>login.cl # tvmark new OT in frame 2
      	echo "tvmark(frame=2,coords=\"$crossoutput_xy\",mark=\"circle\",radii=10,color=204,label+)" >>login.cl #tvmark new OT in frame 1
#        echo "tvmark(frame=1,coords=\"$crossoutput_xy\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl #tvmark new OT in frame 1
#        echo "tvmark(frame=3,coords=\"temp3framecoord_ref\",mark=\"circle\",radii=100,color=204,label+)" >>login.cl #tvmark new OT in frame 1
      # echo "tvmark(frame=2,coords=\"$newimageOTxyFis\",mark=\"circle\",radii=10,color=204,label+)" >>login.cl # tvmark new OT in frame 2
        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data

#======================================================
	
	cat *3frameHave >list3frame.list
	
	if test -r listskyot.list
	then
		echo "===="		
	
#		cat listskyot.list.all $crossoutput_sky >listskyot.list
#		cp listskyot.list listskyot.list.all
	else
		cp $crossoutput_sky listskyot.list
#		cp listskyot.list listskyot.list.all
	fi
	cp $crossoutput_sky listnewskyot.list
	displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
        kill -9 $displayPadNum
	gnuplot plot3frame.gn
#	display plot3frame.png &
        display -resize 1012x1012+0+0  plot3frame.png &
	ls $crossoutput_sky >>listskyotfile
	cat listskyotfile | tail -20 >listskyotfileHis
	cp listskyotfileHis listskyotfile

	rm -rf listskyot.list	
	for file in `cat listskyotfileHis`
	do
		cat $file >>listskyot.list
	done
#	cat listskyot.list.all $crossoutput_sky | uniq >listskyot.list 
#	cp listskyot.list listskyot.list.all
	
#=======================================================
#produce the xyshift.cat in which xshift and yshift is shown.
#which is used to distinguish which match method will be adapted, triangles or tolerance.
	echo `date` "Producing the xyshift for the guider "
#	cat $imagetrans1sd $imagetrans2sd | grep "shift" | awk '{print($2)}' | tr '\n' '  ' > newxyshift.cat
	cat  $imagetrans2sd | grep "shift" | awk '{print($2)}' | tr '\n' '  ' > newxyshift.cat
	echo >> newxyshift.cat
	cat newxyshift.cat  >>xyshiftall.cat
#	cat $imagetrans1sd $imagetrans2sd | grep "rms" | awk '{print($2)}' | tr '\n' '  '
#	./xsentshift #sent the shift values to telescope controlers.
#======================================================
#This part is to calculate the FWHM for those standard stars in the new image
#	echo `date` "Calculating the mean FWHM for this image"
	./xFwhmCal_single.sh $DIR_data $FITFILE $imagetmp2sd $OUTPUT_fwhm 
#	./xFwhmCal.sh $DIR_data $FITFILE refsmall_new $OUTPUT_fwhm
	ls $crossoutput_sky >listOT
	echo `date` "Trim the subimage around the OT from reference and new images"
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
	cp $Alltemplatetable $tempfile $tempsubbgfile $Accfile $tempmatchstars $sub_dir
	mv  $imagetmp2sd $OUTPUT_new $bg $imagetrans2sd $FITFILE $sub_dir
#=======================================================
	date -u >time_dir
	year=`cat time_dir | awk '{print($6)}'`
	month=`cat time_dir | awk '{print($2)}'`
	day=`cat time_dir | awk '{print($3)}'`
	wholeotdirectory=`echo "$HOME/workspace/resultfile/"$year$month$day"/wholeimfile"`
	resultfiles=`echo $inprefix"*"`
	skyOTfile=`echo $inprefix".fit.skyOT"`
	cp $resultfiles $wholeotdirectory 
	gzip $FITFILE
#       cp $wholeotdirectory/$skyOTfile ./
#=================================================
	}
	fi
	echo "***************Cataloge reduction finished**********************"
done
