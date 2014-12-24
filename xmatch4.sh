#!/bin/bash
DIR_data=`pwd`
Alltemplatetable=refcom3d.cat
tempfile=refcom.fit
Accfile=refcom.acc
CCDsize=3056
ejmin=5
ejmax=`echo $CCDsize | awk '{print($1-ejmin)}' ejmin=$ejmin` 
crossRedius=2
#========================================================================
for FILE in `cat listmatch`
do
	date >time_redu_f

	FITFILE=$FILE
	OUTPUT=`echo $FITFILE | sed 's/\.fit/.fit.sex/'`
	OUTPUT_new=`echo $FITFILE | sed 's/\.fit/.fit.sexnew/'`	

	sample_firstTriangle=`echo $FITFILE | sed 's/\.fit/.fit.TriSam1sd.cat/'`
	sample_secTriangle=`echo $FITFILE | sed 's/\.fit/.fit.TriSam2sd.cat/'`
	sample_firstTolere=`echo $FITFILE | sed 's/\.fit/.fit.TolSam1sd.cat/'`


	imagetmp1sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp1sd/'`
	imagetmp2sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp2sd/'`
	imagetmp3sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp3sd/'`
        imagetrans1sd=`echo $FITFILE | sed 's/\.fit/.fit.trans1sd/'`
	imagetrans2sd=`echo $FITFILE | sed 's/\.fit/.fit.trans2sd/'`
	imagetrans3sd=`echo $FITFILE | sed 's/\.fit/.fit.trans3sd/'`

	inprefix=`echo $FITFILE | sed 's/\.fit//'`
#	refnew_xyflux=`echo $FITFILE | sed 's/\.fit/.fit.refnew_xyflux.cat/'`
#	CoordDiff_table=`echo $FITFILE | sed 's/\.fit/.fit.coordiff.cat/'`

	OUTPUT_geoxytran1=`echo $FITFILE | sed 's/\.fit/.fit.tran1/'`
	OUTPUT_geoxytran2=`echo $FITFILE | sed 's/\.fit/.fit.tran2/'`
	OUTPUT_geoxytran3=`echo $FITFILE | sed 's/\.fit/.fit.tran3/'`

	crossoutput_xy=`echo $FITFILE | sed 's/\.fit/.fit.tempxyOT/'`
	crossoutput_sky=`echo $FITFILE | sed 's/\.fit/.fit.skyOT/'`

#	newimageStandxyFis=`echo $FITFILE | sed 's/\.fit/.fit.newStandxy1/'`
#	newimageStandxySecond=`echo $FITFILE | sed 's/\.fit/.fit.newStandxy2/'`
	newimageOTxyFis=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT1/'`
	newimageOTxySecond=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT2/'`
	newimageOTxyThird=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT3/'`	

	OUTPUT_fwhm=`echo $FITFILE | sed 's/\.fit/.fit.fwhm/'`
	bg=`echo $FITFILE | sed 's/\.fit/.bg.fit/'`

	echo $FITFILE 
	
		sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH 1.5 -ANALYSIS_THRESH 1.5 -CATALOG_NAME $OUTPUT -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $bg 
#=========================================================================
	echo `date` "1sh match obj extracted"
        xNpixel=`gethead $FITFILE "NAXIS1"`
        yNpixel=`gethead $FITFILE "NAXIS2"`		
	cat $OUTPUT | awk '{if(($3-$5)/$6>100 && $4==0) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >allres1
	cat allres1 | awk '{if(($3-$5)/$6>100 && $4==0) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >allres0
	cp allres0 $OUTPUT_new
	echo `wc allres0`
#=========================================================================
#position match for the first time with triangles
#	matchflag=triangles
	matchflag=toleranc
        Nbstar=10 #set 10*10 regions to extract the bright stars to match each other
	Ng=2
	fitorder=2
	tempmatchstars=refcom1d.cat
#==========================================================================
	rm -rf mattmp
#==========================================================================	
	echo `date` "1th match"
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	echo noao >> login.cl
	echo image >>login.cl
	echo "cd $DIR_data" >> login.cl
	echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp\",toleranc=20, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=10, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
        echo "geomap(\"mattmp\", \"transform.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
	echo "geoxytran(\"allres1\", \"$OUTPUT_geoxytran1\",\"transform.db\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
	echo logout >> login.cl
	cl < login.cl 
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	cd $DIR_data
        mv mattmp $imagetmp1sd
        mv transform.db $imagetrans1sd
##==========================================================
##This part is used for the more triangles match
##modified by xlp at 20121205
#        cat $OUTPUT_geoxytran1 | awk '{if(($3-$5)/$6>500) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >allres0
#        cp allres0 $OUTPUT_new
#	wc $OUTPUT_new
#
#	echo `date` "2nd match"
#        cd $HOME/iraf
#        cp -f login.cl.old login.cl
#        echo noao >> login.cl
#        echo image >>login.cl
#        echo "cd $DIR_data" >> login.cl
#        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp\",toleranc=5, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=3, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
#        echo "geomap(\"mattmp\", \"transform.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
#	echo "geoxytran(\"$OUTPUT_geoxytran1\", \"$OUTPUT_geoxytran2\",\"transform.db\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#        echo logout >> login.cl
#        cl < login.cl 
#        cd $HOME/iraf
#        cp -f login.cl.old login.cl
#        cd $DIR_data
#        mv mattmp $imagetmp2sd
#        mv transform.db $imagetrans2sd
##==================================================
##position match for the second time with tolerance
#        matchflag=tolerance
#        fitorder=6
#	tempmatchstars=GwacStandall.cat
##========================================================
#	cp $OUTPUT_geoxytran2 $OUTPUT_new
##	cat $OUTPUT_geoxytran2 | awk '{if(($3-$5)/$6>100)print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >$OUTPUT_new
#	wc $OUTPUT_new
##==========================================================================
#	#ds9 &	
##==========================================================================
#	echo `date` "3 match"
#        cd $HOME/iraf
#        cp -f login.cl.old login.cl
#        echo noao >> login.cl
#        echo image >> login.cl
#        echo "cd $DIR_data" >> login.cl
#        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp1\",toleranc=2, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=5, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
#        echo "geomap(\"mattmp1\", \"transform1.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
#        echo logout >> login.cl
#        cl < login.cl 
#        cd $HOME/iraf
#        cp -f login.cl.old login.cl
#        cd $DIR_data
#        mv mattmp1 $imagetmp3sd
#        mv transform1.db $imagetrans3sd
##======================================================
## transform the xy of new image to temp.
#	echo `date` "All xytran from image to temp"
#        cd $HOME/iraf
#        cp -f login.cl.old login.cl
#        echo noao >> login.cl
#        echo image >> login.cl
#        echo "cd $DIR_data" >> login.cl
#        echo "geoxytran(\"$OUTPUT\", \"$OUTPUT_geoxytran1\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#        echo "geoxytran(\"$OUTPUT_geoxytran1\", \"$OUTPUT_geoxytran2\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#        echo "geoxytran(\"$OUTPUT_geoxytran2\", \"$OUTPUT_geoxytran3\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#	echo logout >> login.cl
#        cl < login.cl 
#        cd $HOME/iraf
#        cp -f login.cl.old login.cl
#        cd $DIR_data
##==========================================================
##	echo "+/-2 pixel" $OUTPUT_geoxytran $Alltemplatetable $crossoutput
#	echo `date` "crossmatch"
#	./CrossMatch $crossRedius $OUTPUT_geoxytran3 $Alltemplatetable $crossoutput_xy
#	cat $crossoutput_xy | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax) print($1,$2,$3,$4,$5,$6,$7,$8)}' ejmin=$ejmin ejmax=$ejmax >temp
#	mv temp $crossoutput_xy 
#	wc $crossoutput_xy
##==========================================================
##This part is to transform the xy of OT into the Ra and Dec.
#	echo `date` "cctran of OT to image and display"
#	cd $HOME/iraf
#	cp -f login.cl.old login.cl
#	echo noao >> login.cl
#	echo digiphot >> login.cl
#	echo image >> login.cl
#	echo imcoords >>login.cl
#	echo "cd $DIR_data" >> login.cl
#	echo "cctran(input=\"$crossoutput_xy\",output=\"$crossoutput_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+ ) " >>login.cl
#       echo "geoxytran(\"$crossoutput_xy\", \"$newimageOTxyFis\",\"$imagetrans3sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#        echo "geoxytran(\"$newimageOTxyFis\", \"$newimageOTxySecond\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl 
#        echo "geoxytran(\"$newimageOTxySecond\", \"$newimageOTxyThird\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#	echo "display(image=\"$tempfile\",frame=1)" >>login.cl #display temp file in frame 1
#	echo "display(image=\"$FITFILE\",frame=2)" >>login.cl #display newimage in frame 2
#	echo "tvmark(frame=1,coords=\"$crossoutput_xy\",mark=\"circle\",radii=10,color=205,label+)" >>login.cl #tvmark new OT in frame 1
#	echo "tvmark(frame=1,coords=\"$crossoutput_xy\",mark=\"circle\",radii=100,color=205,label-)" >>login.cl #tvmark new OT in frame 1
#	echo "tvmark(frame=2,coords=\"$newimageOTxyThird\",mark=\"circle\",radii=10,color=204,label+)" >>login.cl # tvmark new OT in frame 2
#	echo "tvmark(frame=2,coords=\"$newimageOTxyThird\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl # tvmark new OT in frame 2
#	echo logout >> login.cl
#        cl < login.cl >xlogfile
#	cd $HOME/iraf
#        cp -f login.cl.old login.cl
#        cd $DIR_data
##======================================================
##produce the xyshift.cat in which xshift and yshift is shown.
##which is used to distinguish which match method will be adapted, triangles or tolerance.
#	cat $imagetrans1sd | grep "shift" | awk '{print($2)}' > newxyshift.temp
#	cat $imagetrans2sd | grep "shift" | awk '{print($2)}' >> newxyshift.temp
#	cat $imagetrans3sd | grep "shift" | awk '{print($2)}' >> newxyshift.temp
#        cat newxyshift.temp |  tr '\n' '  ' | awk '{print($1+$3+$5,$2+$4+$6)}'>newxyshift.cat
#	echo >> newxyshift.cat
##	./xsentshift #sent the shift values to telescope controlers.
##===========================================================
##In $crossoutput_sky, the parameters are
##ra dec x(newIm) y(newIm) x(refIm) y(refIm) flux   
##	paste $crossoutput_sky $newimageOTxyThird $crossoutput_xy >crossoutput_skytemp
#	paste $crossoutput_sky $newimageOTxyThird $crossoutput_xy | awk '{print($1,$2,$9,$10,$17,$18,$3,$4,$5,$6,$7,$8)}' >crossoutput_skytemp
#	mv crossoutput_skytemp $crossoutput_sky
##=======================================================
##This part is to calculate the FWHM for those standard stars in the new image
##	./xFwhmCal.sh $DIR_data $FITFILE $imagetmp3sd $OUTPUT_fwhm
##	./xTrimIm.sh
##=====================================================
#	echo 'date' "OVER"
#	date >time_redu1
#	cat time_redu_f time_redu1 >time_redu2
##	cat time_redu2 | awk '{print($5)}' | sed 's/:/ /g' | tr '\n' ' ' | awk '{print(($4-$1)*3600+($5-$2)*60+($6-$3))}' >time_cal
#	cat time_redu2 | awk '{print($4)}' | sed 's/:/ /g' | tr '\n' ' ' | awk '{print(($4-$1)*3600+($5-$2)*60+($6-$3))}' >time_cal
#	time_need=`cat time_cal`
#	echo 'All were done in ' $time_need 'sec'
##======================================================
	rm -rf   *.bg*.fit bak.fit *.flux*.fit Res* 
done
