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
DIR_data=`pwd`
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
#	cat $OUTPUT | awk '{if(($3-$5)/$6>30 && $4==0) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >allres1
	cat $OUTPUT | sort -n -k 7 | head -3000 | awk '{print($1,$2,$3)}' > $OUTPUT_new
#	cp $OUTPUT_geoxytran1	$OUTPUT_new
#	cat allres1 | awk '{if(($3-$5)/$6>30 && $4==0) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >allres0
#	cp allres1 allres0
#	echo `wc allres0`
#==========================================================================
##position match for the first time with triangles
#	matchflag=triangles
##	matchflag=tolerance
#        Nbstar=10 #set 10*10 regions to extract the bright stars to match each other
#	Ng=2
#	fitorder=2
#	tempmatchstars=refcom1d.cat
##==========================================================================
#        xNb=`echo $xNpixel $Nbstar | awk '{print(int($1/$2))}'`
#	yNb=`echo $yNpixel $Nbstar | awk '{print(int($1/$2))}'`
#        for((i=$Ng;i<($Nbstar-$Ng);i++))
#        do
#	{
#                for((j=$Ng;j<($Nbstar-$Ng);j++))
#                do
#			cat allres0 | awk '{if( (xnb*i)<$1 && $1<=(xnb*(i+1))  &&    (ynb*j)<$2 && $2<=(ynb*(j+1))) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' i=$i j=$j xnb=$xNb ynb=$yNb | sort -n -r -k 3 | head -3 | column -t >Res$i$j
##                        cat allres0 | awk '{if( (nb*i)<$1 && $1<=(nb*(i+1)) &&    (nb*j)<$2 && $2<=(nb*(j+1))) print($1,$2,$3,$4,$5,$6,$7)}' i=$i j=$j nb=$Nb |sort -n -k 3 | tail -5 | column -t >Res$i$j
#                done
#	} &
#	wait
#	done
#        cat Res* >$OUTPUT_new
#	wc $OUTPUT_new
##	cp $OUTPUT_new sample_tr.cat
##	cp  $OUTPUT_new $sample_firstTriangle
#	rm -rf mattmp
#	
##	echo $matchflag, $Nbstar, $Ng, $fitorder, $tempmatchstars,$xNpixel, $yNpixel 
##==========================================================================	
#	echo `date` "1th match"
#	cd $HOME/iraf
#	cp -f login.cl.old login.cl
#	echo noao >> login.cl
#	echo image >>login.cl
#	echo "cd $DIR_data" >> login.cl
#	echo $OUTPUT_new $tempmatchstars
#	echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp\",toleranc=20, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=10, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
#        echo "geomap(\"mattmp\", \"transform.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", maxiter=2, reject=2.5, inter-)" >>login.cl
#	echo "geoxytran(\"allres1\", \"$OUTPUT_geoxytran1\",\"transform.db\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#	echo logout >> login.cl
#	cl < login.cl >xlogfile 
#	
#	cd $HOME/iraf
#	cp -f login.cl.old login.cl
#	cd $DIR_data
#        mv mattmp $imagetmp1sd
#        mv transform.db $imagetrans1sd
#	if test -r $OUTPUT_geoxytran1
#	then 
#		wc $OUTPUT_geoxytran1
#		echo `cat $imagetrans1sd | grep "shift"`
#		echo `cat $imagetrans1sd | grep "rms"`
#	else 
#		echo " 1sh match is failed" 
#	#	exit 1
#	fi
#	
#	cp allres0 $OUTPUT_geoxytran1
#========================================================
	echo `date` "The second match will be going on"
        matchflag=tolerance
        Nbstar=30 #set several regions to extract the bright stars to match each other
        fitorder=4
	tempmatchstars=GwacStandall.cat
	echo "##################"	
#	Npixel=`gethead $FITFILE "NAXIS1"`
#        Nb=`echo $xNpixel $Nbstar | awk '{print(int($1/$2))}'`
#	echo $Nb $Nbstar $xNpixel
##	cat  $OUTPUT_geoxytran1 |  awk '{if(($3-$5)/$6>50 ) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' >allres2
##	cat  $OUTPUT_geoxytran1 |  sort -n -k 7 | head -3000 >allres2
##	mv allres2 $OUTPUT_geoxytran1
#	wc $OUTPUT_geoxytran1
#        for((i=0;i<$Nbstar;i++))
#        do
#	{
#                for((j=0;j<$Nbstar;j++))
#                do
#                        cat $OUTPUT_geoxytran1 | awk '{if( (nb*i)<$1 && $1<=(nb*(i+1)) &&    (nb*j)<$2 && $2<=(nb*(j+1))) print($1,$2,$3)}' i=$i j=$j nb=$Nb |sort -n -r -k 3 | head -5 | column -t >Res$i$j
#                done
#	} 
#        done
#        cat Res* >$OUTPUT_new #for second geomap with tolerence
#        rm -rf Res*
#
#
#	wc $OUTPUT_new
	cp $OUTPUT_new 2thmatch.txt

#=======================================================
	echo `date` "2th match"
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl
        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp1\",toleranc=20, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=3, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
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
#This part is to subimage by temp image
	echo `date` "flux match"
        cat $imagetmp2sd | grep -v "#" | sed '/^$/d'| awk '{print($1,$2,$3,$4)}'| column -t >mattmp.db
        cp $tempmatchstars ref.db
        cp $OUTPUT_new obj.db
        ./flux_obj_ref
	wc refsmall_new
	echo `date` "flux 2 sigma delete"
#        cat -n refsmall_new | column -t >refsmall_new1
	for((i=0;i<5;i++))
	do
        {	
		wc refsmall_new | awk '{print($1)}' >flux_res
        	cat refsmall_new | awk 'BEGIN{total=0}{total=total+$3/$6}END{print total }' >>flux_res
        	cat flux_res | tr '\n' ' ' >flux_res1
        	O2A=`cat flux_res1 | awk '{print($2/$1)}'` #模板流量比目标图像流量高O2A倍
		cat refsmall_new | awk 'BEGIN{total=0}{total=total+($3/$6-ave)**2}END{print total }' ave=$O2A >>flux_res
        	sigma=`cat flux_res | tr '\n' ' '  | awk '{print(sqrt($3/$1))}'`
		cat refsmall_new | awk '{if(($3/$6-ave)<(2*sigma) && ($3/$6-ave)>(-2*sigma)) print($1,$2,$3,$4,$5,$6)}' ave=$O2A sigma=$sigma >>refsmall_new_2th
		mv refsmall_new_2th refsmall_new
	}
	done
		wc refsmall_new
	echo =============O2A=$O2A,sigma=$sigma==================     
#==================================================================

        echo `date` "All geotran from image to temp and then imarith"
        rm -rf $subbg $tran2 $fluxcorr $subimage  
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl

	echo "imarith( \"$FITFILE\",\"-\",\"$bg\",\"$subbg\")" >> login.cl
	echo "geotran(\"$subbg\", \"$tran2\", \"$imagetrans2sd\", \"$inprefix\")" >>login.cl
	echo "imarith( \"$tran2\",\"*\", \"$O2A\",\"$fluxcorr\")" >> login.cl
        echo "imarith( \"$fluxcorr\",\"-\",\"$tempsubbgfile\",\"$subimage\")" >> login.cl
        echo logout >> login.cl
        cl < login.cl  >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
	echo `date` "To get the OT from subimage"
	
        sex $subimage  -c  xmatchdaofind.sex -DETECT_MINAREA 4 -DETECT_THRESH 3 -ANALYSIS_THRESH 3 -CATALOG_NAME $subOUTPUT
	#==========================================================
	echo $xNpixel $yNpixel $xNpixel $yNpixel >input_ref.naxis
#        cat $imagetrans1sd | grep "shift" | awk '{print($2)}' >>input_ref.naxis
	cat $imagetrans2sd | grep "shift" | awk '{print($2)}' >> input_ref.naxis
        cat input_ref.naxis | tr '\n' ' ' >input_ref.naxis1
        mv input_ref.naxis1 input_ref.naxis
        xi=`cat input_ref.naxis | awk '{print($1)}'`
        yi=`cat input_ref.naxis | awk '{print($2)}'`
        xr=`cat input_ref.naxis | awk '{print($3)}'`
        yr=`cat input_ref.naxis | awk '{print($4)}'`
#        xshift=`cat input_ref.naxis | awk '{print($5+$7)}'`
#        yshift=`cat input_ref.naxis | awk '{print($6+$8)}'`
	xshift=`cat input_ref.naxis | awk '{print($5)}'`
        yshift=`cat input_ref.naxis | awk '{print($6)}'`
        cat $subOUTPUT  | awk '{if(($1-xshift)>0 && ($2-yshift)>0 && $1<(xr-xshift) && $2<(yr-yshift) && $3>0) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' xshift=$xshift yshift=$yshift xr=$xr yr=$yr | column -t >$subOUTPUT_sel
	#compare the $subOUTPUT_sel and $refalldata.db to detect the OT candidate, 
	#derive the obs-time,imagename, and xy, RA DEC  for all OT candiates
	#put these information into a file with a name of Single_GwacOT_c.db
	#need to rewrite the code of gmatch.c 
	cat $subOUTPUT_sel | awk '{printf("%.3f %.3f %.3f %d %.3f %.3f %.3f %.3f %.3f %.3f\n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' | column -t >subobj.db
#	cp subobj.db $GwacOT
	./gmatch_1
	cat nomatch_c.db | column -t |  sort  >$GwacOT
	wc $GwacOT
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo digiphot >> login.cl
        echo image >> login.cl
        echo imcoords >>login.cl
        echo "cd $DIR_data" >> login.cl
	echo "cctran(input=\"$GwacOT\",output=\"$GwacOT_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.6f\",latform=\"%12.6f\" ) " >>login.cl
	echo "geoxytran(\"$GwacOT\", \"$newimageGwacOTxyFis\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo "display(image=\"$subimage\",frame=3)" >>login.cl #display newimage in frame 3
        echo "tvmark(frame=3,coords=\"$GwacOT\",mark=\"circle\",radii=100,color=205,label-)" >>login.cl # tvmark new OT in frame 3
##       echo "tvmark(frame=3,coords=\"$GwacOT\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl # tvmark new OT in frame 3
        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
	cat $GwacOT_sky | awk '{print($1,$2)}' >radec
	paste radec $GwacOT | column -t >$GwacOT_sky_paste
#======================================================
#	echo "+/-2 pixel" $OUTPUT_geoxytran $Alltemplatetable $crossoutput
	echo `date` "crossmatch"
	./CrossMatch $crossRedius $OUTPUT_geoxytran2 $Alltemplatetable $crossoutput_xy
	cat $crossoutput_xy | awk '{if($1>ejmin && $1<ejmax && $2>ejmin && $2<ejmax) print($1,$2,$3,$4,$5,$6,$7,$8)}' ejmin=$ejmin ejmax=$ejmax >temp
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
        echo "cctran(input=\"$crossoutput_xy\",output=\"$crossoutput_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.6f\",latform=\"%12.6f\" ) " >>login.cl
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
	
	paste $crossoutput_sky $newimageOTxyFis $crossoutput_xy listtime | awk '{print($1,$2,$9,$10,$17,$18,$25,$26,$3,$4,$5,$6,$7,$8)}' | column -t >crossoutput_skytemp
	mv crossoutput_skytemp $crossoutput_sky
	ls $crossoutput_sky >>listsky
	./xcrossotForlast3frames.sh  #output is named $fitsfile.3frameHave and $fitsfile.3frameNoHave
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
        echo "display(image=\"$tempfile\",frame=1)" >>login.cl #display temp file in frame 1
#      	echo "display(image=\"$FITFILE\",frame=2)" >>login.cl #display newimage in frame 2
      	echo "tvmark(frame=1,coords=\"$crossoutput_xy\",mark=\"circle\",radii=10,color=204,label+)" >>login.cl #tvmark new OT in frame 1
        echo "tvmark(frame=1,coords=\"$crossoutput_xy\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl #tvmark new OT in frame 1
       echo "tvmark(frame=3,coords=\"temp3framecoord_ref\",mark=\"circle\",radii=50,color=205,label+)" >>login.cl #tvmark new OT in frame 1
       # echo "tvmark(frame=2,coords=\"$newimageOTxyFis\",mark=\"circle\",radii=10,color=204,label+)" >>login.cl # tvmark new OT in frame 2
       # echo "tvmark(frame=2,coords=\"$newimageOTxyFis\",mark=\"circle\",radii=100,color=204,label-)" >>login.cl # tvmark new OT in frame 2
#	echo "tvmark(frame=2,coords=\"temp3framecoord_new\",mark=\"circle\",radii=5,color=205,label+)" >>login.cl # tvmark new OT in frame 2
        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data


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
	echo `date` "Calculating the mean FWHM for this image"
	#./xFwhmCal.sh $DIR_data $FITFILE $imagetmp2sd $OUTPUT_fwhm 
	./xFwhmCal.sh $DIR_data $FITFILE refsmall_new $OUTPUT_fwhm
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
	rm -rf   *.bg*.fit bak.fit *.flux*.fit Res* 
#	rm -rf *2sd.fit $FITFILE 
#=======================================================
#	date -u >time_dir
#	year=`cat time_dir | awk '{print($6)}'`
#	month=`cat time_dir | awk '{print($2)}'`
#	day=`cat time_dir | awk '{print($3)}'`
#	wholeotdirectory=`echo "$HOME/workspace/resultfile/"$year$month$day"/wholeimfile"`
#	resultfiles=`echo $inprefix"*"`
#	skyOTfile=`echo $inprefix".fit.skyOT"`
#	mv $resultfiles $wholeotdirectory 
#	cp $wholeotdirectory/$skyOTfile ./
#=================================================
	}
	fi
	echo "*************************************"
done
