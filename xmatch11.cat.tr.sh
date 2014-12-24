#!/bin/bash
DIR_data=`pwd`
Alltemplatetable=refcom3d.cat
tempfile=refcom.fit
Accfile=refcom.acc
#========================================================================
for FILE in `cat listmatch.temp`
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
	#imagetrans2sd=`echo $FITFILE | sed 's/\.fit/.fit.trans2sd/'`
	
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
	echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp\",toleranc=100, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=5, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
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
        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp\",toleranc=20, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=5, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
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
        cat $imagetrans1sd | grep "shift" | awk '{print($2)}' |  tr '\n' '  ' > newxyshift.cat
        echo >> newxyshift.cat
	echo "The shift in xy is"
	cat newxyshift.cat
#========================================================	
#	rm -rf   *.bg*.fit bak.fit *.flux*.fit Res*
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
        echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp1\",toleranc=10, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=5, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
        echo "geomap(\"mattmp1\", \"transform1.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
        #echo "geomap(\"mattmp1\", \"transform1.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$xNpixel,fitgeom=\"general\", functio=\"legendre\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", inter-)" >>login.cl
	####echo "geoxytran(\"$OUTPUT_geoxytran2\", \"$OUTPUT_geoxytran3\",\"transform1.db\", transfo=\"$inprefix\",geometr=\"geometric\",directi=\"backward\",xcolumn=1,ycolumn=2,calctyp=\"double\",min_sig=7)" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile

        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
        mv mattmp1 $imagetmp2sd
        mv transform1.db $imagetrans2sd
#	mv $OUTPUT_geoxytran3 $OUTPUT_geoxytran2
	mv $OUTPUT_geoxytran2 $OUTPUT
        echo `cat $imagetrans2sd | grep "shift"`
        echo `cat $imagetrans2sd | grep "rms"`
	echo "xmatch11.cat.tr.sh is finished"
done
#========================================================	
