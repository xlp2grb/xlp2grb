#!/bin/bash
#Author:xlp at 20130402
#this code is for the xyxymatch by tolerence and the shift information is used from the last successful matched image.
#named as newxyshift.cat

        FITFILE=$1
        OUTPUT_new=`echo $FITFILE | sed 's/\.fit/.fit.sexnew/'`
        imagetmp2sd=`echo $FITFILE | sed 's/\.fit/.fit.mattmp2sd/'`
        imagetrans2sd=`echo $FITFILE | sed 's/\.fit/.fit.trans2sd/'`
        inprefix=`echo $FITFILE | sed 's/\.fit//'`
        echo $FITFILE 
	DIR_data=`pwd`

         xNpixel=`gethead $FITFILE "NAXIS1"`
         yNpixel=`gethead $FITFILE "NAXIS2"`

         xshift=`cat newxyshift.cat | awk '{print($1)}'`
         yshift=`cat newxyshift.cat | awk '{print($2)}'`
         cp $OUTPUT_new OUTPUT_new
         cat $OUTPUT_new | awk '{print($1-xshift,$2-yshift,$3)}' xshift=$xshift yshift=$yshift >output_new_temp
         mv output_new_temp $OUTPUT_new
         echo `date` "2th match again"
         mv $imagetrans2sd trans2sd.bak
         mv $imagetmp2sd temp2sd.bak
         rm -rf mattmp1 transform1.db $imagetrans2sd $imagetmp2sd
#========================================         
	 matchflag=tolerance
         fitorder=6
         tempmatchstars=GwacStandall.cat
#=======================================
         cd $HOME/iraf
         cp -f login.cl.old login.cl
         echo noao >> login.cl
         echo image >> login.cl
         echo "cd $DIR_data" >> login.cl
         echo "xyxymatch(\"$OUTPUT_new\",\"$tempmatchstars\", \"mattmp1\",toleranc=25, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=5, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
         echo "geomap(\"mattmp1\", \"transform1.db\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$yNpixel,fitgeom=\"general\", functio=\"polynomial\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", maxiter=5,reject=2.5,inter-)" >>login.cl
         echo logout >> login.cl
         cl < login.cl >xlogfile
         cd $HOME/iraf
         cp -f login.cl.old login.cl
         cd $DIR_data
         echo "2match again finished"
#         mv mattmp1 $imagetmp2sd
         sed -n '1,15p' mattmp1 >$imagetmp2sd
         sed -n '16,1000p' mattmp1 | awk '{print($1,$2,$3+xshift,$4+yshift,$5,$6)}' xshift=$xshift yshift=$yshift >>$imagetmp2sd
	rm -rf mattmp1
         mv transform1.db $imagetrans2sd

         if test -r $imagetrans2sd
         then
                 echo "reconstruct the file of trans2sd"
                 xshift1=`cat $imagetrans2sd | grep "xshift" | awk '{print($2)}'`
                 yshift1=`cat $imagetrans2sd | grep "yshift" | awk '{print($2)}'`
		 echo $xshift1 $yshift1
                 xxshift=`echo $xshift $xshift1 | awk '{print($1+$2)}'`
                 yyshift=`echo $yshift $yshift1 | awk '{print($1+$2)}'`
                 sed -n '1,8p' $imagetrans2sd >newfile1
                 echo "  xshift          "$xxshift >>newfile1
                 echo "  yshift          "$yyshift >>newfile1
                 sed -n '11,25p' $imagetrans2sd >>newfile1
                 echo "                          "$xxshift $yyshift >>newfile1
                 sed -n '27,100p' $imagetrans2sd >>newfile1
                 mv newfile1 $imagetrans2sd
                 echo `cat $imagetrans2sd | grep "shift"`
                 echo `cat $imagetrans2sd | grep "rms"`
         fi
