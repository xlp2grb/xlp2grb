#!/bin/bash
DIR_data=`pwd`
Alltemplatetable=refcom3d.cat
tempfile=refcom.fit
Accfile=refcom.acc
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
	refnew_xyflux=`echo $FITFILE | sed 's/\.fit/.fit.refnew_xyflux.cat/'`
	CoordDiff_table=`echo $FITFILE | sed 's/\.fit/.fit.coordiff.cat/'`

	OUTPUT_geoxytran1=`echo $FITFILE | sed 's/\.fit/.fit.tran1/'`
	OUTPUT_geoxytran2=`echo $FITFILE | sed 's/\.fit/.fit.tran2/'`
	OUTPUT_geoxytran3=`echo $FITFILE | sed 's/\.fit/.fit.tran3/'`

	crossoutput_xy=`echo $FITFILE | sed 's/\.fit/.fit.tempxyOT/'`
	crossoutput_sky=`echo $FITFILE | sed 's/\.fit/.fit.skyOT/'`

	newimageStandxyFis=`echo $FITFILE | sed 's/\.fit/.fit.newStandxy1/'`
	newimageStandxySecond=`echo $FITFILE | sed 's/\.fit/.fit.newStandxy2/'`
	newimageOTxyFis=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT1/'`
	newimageOTxySecond=`echo $FITFILE | sed 's/\.fit/.fit.newxyOT2/'`	

	
	OUTPUT_fwhm=`echo $FITFILE | sed 's/\.fit/.fit.fwhm/'`

	
	
	bg=`echo $FITFILE | sed 's/\.fit/.bg.fit/'`

	echo $FITFILE 

	sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH 1.5 -ANALYSIS_THRESH 1.5 -CATALOG_NAME $OUTPUT -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $bg 

#=========================================================================

        xNpixel=`gethead $FITFILE "NAXIS1"`
        yNpixel=`gethead $FITFILE "NAXIS2"`		
#	Npixel=`gethead $FITFILE "NAXIS1"`
	cat $OUTPUT | awk '{if(($3-$5)/$6>20) print($1,$2,$3,$4,$5,$6,$7)}' | column -t >allres0
#	echo `wc allres0`
#==========================================================================
#position match for the first time with triangles
	matchflag=triangles
        Nbstar=10 #set 10*10 regions to extract the bright stars to match each other
	Ng=2
	fitorder=2
	tempmatchstars=refcom1d.cat

#	if test -r xyshift.cat_new 
#	then
#       	xshift=`cat xyshift.cat_new | awk '{print($1)}'`
#       	yshift=`cat xyshift.cat_new | awk '{print($2)}'`
#       	echo $xshift $yshift
#	if [ $(echo "${xshift#-} < 1"|bc) = 1 ]
#		then if	[ $(echo "${yshift#-} < 1"|bc) = 1 ]
#			then
#       			matchflag=tolerance
#       			Nbstar=20 #set 10*10 regions to extract the bright stars to match each other
#       			Ng=0
#       			fitorder=5
#       			tempmatchstars=refcom2d.cat
#		     fi	
#		fi
#	fi
#==========================================================================
        xNb=`echo $xNpixel $Nbstar | awk '{print(int($1/$2))}'`
	yNb=`echo $yNpixel $Nbstar | awk '{print(int($1/$2))}'`
        for((i=$Ng;i<($Nbstar-$Ng);i++))
        do
                for((j=$Ng;j<($Nbstar-$Ng);j++))
                do
			cat allres0 | awk '{if( (xnb*i)<$1 && $1<=(xnb*(i+1))  &&    (ynb*j)<$2 && $2<=(ynb*(j+1))) print($1,$2,$3)}' i=$i j=$j xnb=$xNb ynb=$yNb | sort -n -r -k 3 | head -5 | column -t >Res$i$j
#                        cat allres0 | awk '{if( (nb*i)<$1 && $1<=(nb*(i+1)) &&    (nb*j)<$2 && $2<=(nb*(j+1))) print($1,$2,$3,$4,$5,$6,$7)}' i=$i j=$j nb=$Nb |sort -n -k 3 | tail -5 | column -t >Res$i$j
                done
	done

        cat Res* >$OUTPUT_new
#	cp $OUTPUT_new sample_tr.cat
	cp  $OUTPUT_new $sample_firstTriangle
	rm -rf mattmp
	
	echo $matchflag, $Nbstar, $Ng, $fitorder, $tempmatchstars,$xNpixel, $yNpixel 
#==========================================================================	
	
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	echo noao >> login.cl
	echo image >>login.cl
	echo "cd $DIR_data" >> login.cl
	echo $OUTPUT_new $tempmatchstars
	echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp\",toleranc=30, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=5, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
        echo "geomap(\"mattmp\", \"transform.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
	echo "geoxytran(\"$OUTPUT\", \"$OUTPUT_geoxytran1\",\"transform.db\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl 
	echo logout >> login.cl
	cl < login.cl >xlogfile
	
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	cd $DIR_data
        mv mattmp $imagetmp1sd
        mv transform.db $imagetrans1sd
#	mv mattmp mattmp1sd.tri
#	mv transform.db transform1sd.tri
#	rm -rf mattmp transform.db
#==========================================================
#This part is used for the more triangles match
#modified by xlp at 20121205
        cat $OUTPUT_geoxytran1 | awk '{if(($3-$5)/$6>20) print($1,$2,$3,$4,$5,$6,$7)}' | column -t >allres0
	        xNb=`echo $xNpixel $Nbstar | awk '{print(int($1/$2))}'`
        yNb=`echo $yNpixel $Nbstar | awk '{print(int($1/$2))}'`
        for((i=$Ng;i<($Nbstar-$Ng);i++))
        do
                for((j=$Ng;j<($Nbstar-$Ng);j++))
                do
                        cat allres0 | awk '{if( (xnb*i)<$1 && $1<=(xnb*(i+1))  &&    (ynb*j)<$2 && $2<=(ynb*(j+1))) print($1,$2,$3)}' i=$i j=$j xnb=$xNb ynb=$yNb | sort -n -r -k 3 | head -5 | column -t >Res$i$j
#                        cat allres0 | awk '{if( (nb*i)<$1 && $1<=(nb*(i+1)) &&    (nb*j)<$2 && $2<=(nb*(j+1))) print($1,$2,$3,$4,$5,$6,$7)}' i=$i j=$j nb=$Nb |sort -n -k 3 | tail -5 | column -t >Res$i$j
                done
        done

        cat Res* >$OUTPUT_new
#        cp $OUTPUT_new sample_tr.cat1
	cp $OUTPUT_new $sample_secTriangle
        rm -rf mattmp

        echo $matchflag, $Nbstar, $Ng, $fitorder, $tempmatchstars,$xNpixel, $yNpixel 


        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >>login.cl
        echo "cd $DIR_data" >> login.cl
        echo $OUTPUT_new $tempmatchstars
        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp\",toleranc=5, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=5, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
        echo "geomap(\"mattmp\", \"transform.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
        echo "geoxytran(\"$OUTPUT_geoxytran1\", \"$OUTPUT_geoxytran2\",\"transform.db\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile

        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
        mv mattmp $imagetmp2sd
        mv transform.db $imagetrans2sd

#==========================================================
#produce the xyshift.cat in which xshift and yshift is shown.
#which is used to distinguish which match method will be adapted, triangles or tolerance.
        cat $imagetrans1sd | grep "shift" | awk '{print($2)}' |  tr '\n' '  ' > xyshift.cat_new
        echo >> xyshift.cat_new
        cat xyshift.cat_all xyshift.cat_new  >xyshift.cat_all_temp
        mv xyshift.cat_all_temp xyshift.cat_all
#========================================================	
	rm -rf   *.bg*.fit bak.fit *.flux*.fit Res*
#========================================================
#
#position match for the second time with tolerance
#
#	echo "The second match will be going on"
        matchflag=tolerance
        Nbstar=30 #set several regions to extract the bright stars to match each other
        Ng=0
        fitorder=6
#        tempmatchstars=refcom2d.cat
	tempmatchstars=GwacStandall.cat
#========================================================
#        cat $OUTPUT_geoxytran | awk '{if(($3-$5)/$6>15)print($1,$2,$3,$4,$5,$6,$7)}' | column -t >allres0	
	# cat $OUTPUT_geoxytran | awk '{if(($3-$5)/$6>5)print($1,$2,$3)}' | column -t >allres0
	cat $OUTPUT_geoxytran2 | awk '{if(($3-$5)/$6>5)print($1,$2,$3)}' | column -t >$OUTPUT_new
#	cp allres0 $OUTPUT_new
#	cp $OUTPUT_new sample_tol.cat
	cp $OUTPUT_new  $sample_firstTolere
#	xNb=`echo $xNpixel $Nbstar | awk '{print(int($1/$2))}'`
#        yNb=`echo $yNpixel $Nbstar | awk '{print(int($1/$2))}'`
#        for((i=$Ng;i<($Nbstar-$Ng);i++))
#        do
#                for((j=$Ng;j<($Nbstar-$Ng);j++))
#                do
#                        cat allres0 | awk '{if( (xnb*i)<$1 && $1<=(xnb*(i+1))  &&    (ynb*j)<$2 && $2<=(ynb*(j+1))) print($1,$2,$3)}' i=$i j=$j xnb=$xNb ynb=$yNb | sort -n -r -k 3 | head -3 | column -t >Res$i$j
#                done
#        done
#
#        cat Res* >$OUTPUT_new
#        rm -rf mattmp Res*
#==========================================================================
#	cp $OUTPUT_new firstshift.cat
#	./xmatchWithTolerance.sh
     
#==========================================================================
	#ds9 &	
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl

        #position match for the first time with triangles
#        echo $OUTPUT_new $tempmatchstars
        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp1\",toleranc=3, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=5, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
        echo "geomap(\"mattmp1\", \"transform1.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
        #echo "geomap(\"mattmp1\", \"transform1.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"legendre\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
	echo "geoxytran(\"$OUTPUT_geoxytran2\", \"$OUTPUT_geoxytran3\",\"transform1.db\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile

        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
        mv mattmp1 $imagetmp3sd
        mv transform1.db $imagetrans3sd
#=======================================================
	cat $imagetmp2sd | grep -v "#" | sed '/^$/d'| awk '{print($1,$2,"1 a")}'| column -t >newimageStandxyRef.db
#=======================================================	
#This part is to calculate the FWHM for those standard stars in the new image
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo digiphot >> login.cl
        echo daophot >>login.cl
        echo "cd $DIR_data" >> login.cl
	echo "daoedit(\"$FITFILE\", icommand=\"newimageStandxyRef.db\")"  >> login.cl	
	echo logout >> login.cl
	cl < login.cl  >OUTPUT_PSF
	mv OUTPUT_PSF $DIR_data
	cp -f login.cl.old login.cl
	cd $DIR_data
	cat OUTPUT_PSF | sed -e '/^$/d' | grep '[1-9]' | grep -v "NOAO" | grep -v "This" | grep -v "line" | grep -v "m" | awk '{print($1,$2,$5,"0 0 0")}' | column -t >$OUTPUT_fwhm 
	ls $OUTPUT_fwhm >list_fin
	./xfwhmave
	cat averagefile_new | column -t | grep -v "nan" >temfile
	cat -n averagefile temfile | column -t >averagefile_fin
	tail -1 averagefile_fin  >fwhm_lastdata
	cat averagefile_fin | awk '{print($2,$3,$4,$5,$6)}' | column -t >averagefile
	
	#./sentfwhm #send the massage to focusor system (huanglei's computer)
	
	displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
	kill -9 $displayPadNum
	gnuplot plot.fwhm.gn
#	display average_fwhm.png &

#======================================================
##	cd $DIR_data
#        cat $imagetmp2sd | grep -v "#" | sed '/^$/d'| awk '{print($1,$2,$3,$4)}'| column -t >mattmp.db
#	cat mattmp.db | awk '{print($3,$4,$1-$3,$2-$4)}' >$CoordDiff_table #xi,yi,xr-xi,yr-yi
##        cp $tempmatchstars ref.db
#	cat $tempmatchstars | awk '{print($1,$2,$3)}' > ref.db	
#        cp $OUTPUT_new obj.db
#        ./diffmatch # to produce the difference between new image and ref image. The result file is named as diffmatch.cat
#	mv diffmatch.cat $refnew_xyflux
#==========================================================
#	cp $CoordDiff_table CoordDiff.cat
#	echo "+/-2 pixel" $OUTPUT_geoxytran $Alltemplatetable $crossoutput
	./CrossMatch 2 $OUTPUT_geoxytran3 $Alltemplatetable $crossoutput_xy
#	cat $crossoutput_xy 
	wc $crossoutput_xy
#==========================================================
#This part is to transform the xy of OT into the Ra and Dec.
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	echo noao >> login.cl
	echo digiphot >> login.cl
	echo image >> login.cl
	echo imcoords >>login.cl
	echo "cd $DIR_data" >> login.cl
	echo "cctran(input=\"$crossoutput_xy\",output=\"$crossoutput_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+,lngform=\"%12.6f\",latform=\"%12.6f\" ) " >>login.cl
#	echo "cctran(input=\"$crossoutput_xy\",output=\"$crossoutput_sky\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2,min_sigdigits=7,forward+ ) " >>login.cl
	echo logout >> login.cl
	cl < login.cl >xlogfile
	cd $HOME/iraf
	cp -f login.cl.old login.cl
	cd $DIR_data
#	cp $crossoutput_sky $crossoutput_xy
#======================================================	
#This part is to make the coord transfer from temp to new image
#It also makes the display these new OT in the new image to get a show.
	cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
	echo "cd $DIR_data" >> login.cl
       echo "geoxytran(\"$crossoutput_xy\", \"$newimageOTxyFis\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo "geoxytran(\"$newimageOTxyFis\", \"$newimageOTxySecond\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl 
#        echo "geoxytran(\"newimageStandxyRef.db\", \"$newimageStandxyFis\",\"$imagetrans2sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
#	echo "geoxytran(\"$newimageStandxyFis\", \"$newimageStandxySecond\",\"$imagetrans1sd\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"forward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
	echo "display(image=\"$tempfile\",frame=1)" >>login.cl #display temp file in frame 1
	echo "display(image=\"$FITFILE\",frame=2)" >>login.cl #display newimage in frame 2
	echo "tvmark(frame=1,coords=\"$crossoutput_xy\",mark=\"circle\",radii=10,color=205)" >>login.cl #tvmark new OT in frame 1
	echo "tvmark(frame=2,coords=\"$newimageOTxySecond\",mark=\"circle\",radii=10,color=204)" >>login.cl # tvmark new OT in frame 2
	echo logout >> login.cl
        cl < login.cl >xlogfile
	cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data

#produce the xyshift.cat in which xshift and yshift is shown.
#which is used to distinguish which match method will be adapted, triangles or tolerance.
#	cat $imagetrans1sd | grep "shift" | awk '{print($2)}' |  tr '\n' '  ' > xyshift.cat_new
#	echo >> xyshift.cat_new	
#	cat xyshift.cat_all xyshift.cat_new  >xyshift.cat_all_temp
#	mv xyshift.cat_all_temp xyshift.cat_all
#=======================================================
#	rm -rf   *.bg*.fit bak.fit *.flux*.fit Res*
#======================================================
	date >time_redu1
	cat time_redu_f time_redu1 >time_redu2
	#cat time_redu2 | awk '{print($5)}' | sed 's/:/ /g' | tr '\n' ' ' | awk '{print(($4-$1)*3600+($5-$2)*60+($6-$3))}' >time_cal
	cat time_redu2 | awk '{print($4)}' | sed 's/:/ /g' | tr '\n' ' ' | awk '{print(($4-$1)*3600+($5-$2)*60+($6-$3))}' >time_cal
	time_need=`cat time_cal`
	echo 'All were done in ' $time_need 'sec'

done
#========================================================	
