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
tempmatchstars=GwacStandall.cat
CCDsize=3056
ejmin=5
ejmax=`echo $CCDsize | awk '{print($1-ejmin)}' ejmin=$ejmin` 
#./xmknewfile.sh
#========================================================================
for FILE in `cat listsubcom`
do
	date >time_redu_f

	FITFILE=$FILE
	
        subimage=`echo $FITFILE | sed 's/\.fit/.sub.fit/'`
	tran2=`echo $FITFILE | sed 's/\.fit/.2sd.fit/'`
	OUTPUT=`echo $FITFILE | sed 's/\.fit/.fit.sex/'`
	OUTPUT_new=`echo $FITFILE | sed 's/\.fit/.fit.sexnew/'`	

#	imagetmp1sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp1sd/'`
#	imagetmp2sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp2sd/'`
#        imagetrans1sd=`echo $FITFILE | sed 's/\.fit/.fit.trans1sd/'`
	imagetrans2sd=`echo $FITFILE | sed 's/\.2sd.com.fit/.fit.trans2sd/'`
	inprefix=`echo $FITFILE | sed 's/\.2sd.com.fit//'`
	crossoutput_xy=`echo $FITFILE | sed 's/\.fit/.fit.tempxyOT/'`
	crossoutput_sky=`echo $FITFILE | sed 's/\.fit/.fit.skyOT/'`

	newimageOTxyFis=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT1/'`
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
	subOUTPUT=`echo $OUTPUT_new | sed 's/\.fit.sexnew/.sub.sex/'`
	subOUTPUT_sel=`echo $OUTPUT_new | sed 's/\.fit.sexnew/.sub.sex.sel/'`
	echo $FITFILE 
	
#=========================================================================
	echo `date` "find the stars from combined image"
        #sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH 100 -ANALYSIS_THRESH 100 -CATALOG_NAME $OUTPUT -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $bg
	sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH 30 -ANALYSIS_THRESH 30 -CATALOG_NAME $OUTPUT  -CHECKIMAGE_NAME $bg
	wc $OUTPUT
#to write a code to match the match and flux match
#consider the combined image is shifted relatvie to the temp.
#when sextractor works, some missed objects at the shifted eara will be rejected 
	echo "find stars finished"
	cat $OUTPUT | awk '{if($1>20 && $2>20 && $1<3020 && $2<3020) print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}'| sort -n -k 7 | head -10000 | awk '{print($1,$2,$3)}' > $OUTPUT_new 
        cp $tempmatchstars ref.db
        cp $OUTPUT_new obj.db
	./fluxmatch #output is refsmall_new
##This part is to subimage by temp image
#	echo `date` "flux match"
#        cat $imagetmp2sd | grep -v "#" | sed '/^$/d'| awk '{print($1,$2,$3,$4)}'| column -t >mattmp.db
#        ./flux_obj_ref
	wc refsmall_new
	cat refsmall_new | awk '{print($1,$2,$3/$6)}' >surfit.dat
#=========================================================================
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
	O2A1=`echo $O2A | awk '{print($1*0.9)}'`
	O2A=`echo $O2A1`
	echo =============O2A=$O2A,sigma=$sigma==================     
#==================================================================

        echo `date` "sub bg, flux correct,image subtraction"
        rm -rf $subbg $fluxcorr $subimage surfit.fit
        cd $HOME/iraf1
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
	echo utilities >> login.cl
        echo "cd $DIR_data" >> login.cl
	echo "imarith( \"$FITFILE\",\"-\",\"$bg\",\"$subbg\")" >> login.cl
	echo "surfit(input=\"surfit.dat\",image=\"surfit.fit\",functio=\"polynomial\",xorder=4,yorder=4,xterms=\"full\",weighti=\"uniform\",xmin=1,xmax=3056,ymin=1,ymax=3056,ncols=3056,nlines=3056)" >>login.cl
#	echo "surfit(input=\"surfit.log\",image=\"surfit.fit\",functio=\"polynomial\",xorder=4,yorder=4,xterms=\"full\",weighti=\"uniform\",xmin=1,xmax=3056,ymin=1,ymax=3056)" >>login.cl
	echo "imarith( \"$subbg\",\"*\", \"surfit.fit\",\"$fluxcorr\")" >> login.cl
#	echo "imarith( \"$subbg\",\"*\", \"$O2A\",\"$fluxcorr\")" >> login.cl
        echo "imarith( \"$fluxcorr\",\"-\",\"$tempsubbgfile\",\"$subimage\")" >> login.cl
	echo "display(image=\"$subimage\",frame=3)" >>login.cl #display newimage in frame 3
        echo logout >> login.cl
        cl < login.cl 
        cd $HOME/iraf1
        cp -f login.cl.old login.cl
        cd $DIR_data
	sleep 10	
	echo `date` "To get the OT from subimage"
        sex $subimage  -c  xmatchdaofind.sex -DETECT_MINAREA 6 -DETECT_THRESH 4 -ANALYSIS_THRESH 4 -CATALOG_NAME $subOUTPUT
	#==========================================================
	wc $subOUTPUT
        xNpixel=`gethead $FITFILE "NAXIS1"`
        yNpixel=`gethead $FITFILE "NAXIS2"`

	echo $xNpixel $yNpixel $xNpixel $yNpixel >input_ref.naxis
#        cat $imagetrans1sd | grep "shift" | awk '{print($2)}' >>input_ref.naxis
	
#needed to modification,to calculate the max and min among the shift among those images in the listcom
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
	cp subobj.db $GwacOT
#	./gmatch_1
#	cat nomatch_c.db | column -t |  sort  >$GwacOT
	#===================================================
        #modified at 20140829 by xlp
        #Increase the code to analyze the psf of this OT candidates.
	cat $GwacOT | awk '{print($1,$2, "  1 a")}' >psf.dat
        cd $HOME/iraf1
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo digiphot >> login.cl
        echo daophot >>login.cl
        echo "cd $DIR_data" >> login.cl
        echo "daoedit(\"$subimage\", icommand=\"psf.dat\")"  >> login.cl
        echo logout >> login.cl
        cl < login.cl  >OUTPUT_PSF
        mv OUTPUT_PSF $DIR_data
        cp -f login.cl.old login.cl
        cd $DIR_data
	cat OUTPUT_PSF | grep "ERROR" >errormsg
        if test ! -s errormsg
        then
    	cat OUTPUT_PSF | sed -e '/^$/d' | grep '[1-9]' | grep -v "NOAO" | grep -v "This" | grep -v "line" | grep -v "m" >OUTPUT_PSF1
	paste OUTPUT_PSF1 $GwacOT | awk '{if($5>1)print($8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}' >temp  #FWHM>1 && other parameters
        mv temp $GwacOT
        rm -rf psf.dat OUTPUT_PSF OUTPUT_PSF1
	else
		echo "Error in psf filter"
	fi
	#===================================================
	wc $GwacOT
	echo $imagetrans2sd
        cd $HOME/iraf1
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo digiphot >> login.cl
        echo image >> login.cl
        echo imcoords >>login.cl
        echo "cd $DIR_data" >> login.cl
	echo "cctran(input=\"$GwacOT\",output=\"$GwacOT_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"hours\",latunits=\"hours\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.2h\",latform=\"%12.2h\" ) " >>login.cl
	echo "geoxytran(\"$GwacOT\", \"$newimageGwacOTxyFis\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf1
        cp -f login.cl.old login.cl
        cd $DIR_data

      	echo `date` "making the skyOT list"
	rm -rf listtime
        timeobs=`gethead $FITFILE "date-obs"`       
        NumOT=`cat $GwacOT | wc -l`
        for ((i=0;i<$NumOT;i++))
        do
               echo $timeobs $FITFILE >>listtime
        done

	cat $GwacOT_sky | awk '{print($1,$2)}' >radec
	cat radec | awk '{printf("%s_%s\n",$1,$2)}' >radecstring
	cat radecstring | head -1
	echo "#tempxc tempyc radecstring ra dec(J2000) newxc newyc flux flags background threshold mag_aper magerr ellipticity class_star date image " >$GwacOT_sky_paste
#	paste $GwacOT radecstring radec listtime $newimageGwacOTxyFis | awk '{print($1,$2,$11,$12,$13,$16,$17,$3,$4,$5,$6,$7,$8,$9,$10,$14,$15)}'| column -t >>$GwacOT_sky_paste
	
#eject some objects at the edge of the image
	paste $GwacOT radecstring radec listtime $newimageGwacOTxyFis | awk '{if($1>10 && $2>10 && $1<3046 && $2<3046 ) print($1,$2,$11,$12,$13,$16,$17,$3,$4,$5,$6,$7,$8,$9,$10,$14,$15)}'| column -t >>$GwacOT_sky_paste

        cd $HOME/iraf1
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo digiphot >> login.cl
        echo image >> login.cl
        echo imcoords >>login.cl
        echo "cd $DIR_data" >> login.cl
        echo "display(image=\"$subimage\",frame=3)" >>login.cl #display newimage in frame 3
        echo "tvmark(frame=3,coords=\"$GwacOT_sky_paste\",mark=\"circle\",radii=20,color=205,label+,txsize=5)" >>login.cl # tvmark new OT in frame 3
        echo logout >> login.cl
#        cl < login.cl >>xlogfile
	cl < login.cl
        cd $HOME/iraf1
        cp -f login.cl.old login.cl
        cd $DIR_data

#=====================================================
	date >time_redu1
	cat time_redu_f time_redu1 >time_redu2
#	cat time_redu2 | awk '{print($5)}' | sed 's/:/ /g' | tr '\n' ' ' | awk '{print(($4-$1)*3600+($5-$2)*60+($6-$3))}' >time_cal
	cat time_redu2 | awk '{print($4)}' | sed 's/:/ /g' | tr '\n' ' ' | awk '{print(($4-$1)*3600+($5-$2)*60+($6-$3))}' >time_cal
	time_need=`cat time_cal`
	echo `date`', All were done in ' $time_need 'sec'
#======================================================
	rm -rf bak.fit Res* *.flux*.fit   *2sd*.fit  *.bg.fit *.bgsub.fit 
#	rm -rf  $FITFILE
#=================================================
	echo "****************image subtraction finished*********************"
done
