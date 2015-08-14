#!/bin/bash
#Author: xlp at 20150804
#do the combination for 5 images which have not been shifted well.
#the combination file is named with the name of the 3th image in those 5 images.
#comlist=listcom
DIR_data=`pwd`
comlist=$1
comimage=$2
echo $comlist
#comref=`cat $comlist | head -1`
#echo $comref
#comimage=`echo $comref | sed 's/\.fit/.com.fit/'`
#echo $comimage
rdnoise=10
gain=1.3

rm -rf newcomlistwithshift


ximcombine ( )
{
if test -r $comimage
then
        rm -rf $comimage
fi
#-----------------------------------------
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo digiphot >> login.cl
echo daophot >>login.cl
echo "cd $DIR_data" >> login.cl
echo flpr >> login.cl
echo "imcombine(\"@newcomlistwithshift\",\"$comimage\", reject=\"crreject\",combine=\"average\",scale=\"exposure\",weight=\"exposure\",rdnoise=$rdnoise,gain=$gain)" >>login.cl
echo logout >>login.cl
cl < login.cl >xlogfile
#----------------------------------------------
cd $DIR_data
#mv $comimage gototemp.fit

echo "=============="$comimage" finished====================="
}

xtransImageToTemp (  )
{
        echo `date` "All geotran from image to temp"
	if test ! -s $imagetrans3sd
	then
		continue
	fi
        rm -rf $tran2  
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl
	    echo "geotran(\"$fitfile\", \"$tran2\", \"$imagetrans3sd\", \"$inprefix\")" >>login.cl
        echo logout >> login.cl
        cl < login.cl >xlogfile 
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
        ls $tran2	
	    echo "***image transformaton finished***"
#	echo `date` "test if the new image number is larger than N. if yes, making the combination"mZ
	ls $tran2 >>newcomlistwithshift
    cat newcomlistwithshift
#	line=`cat newcomlistwithshift | wc -l | awk '{print($1)}'`
 #   if [ $line -lt 5 ]
#	then
#		echo "the number of new image is" $line
#	else
#	fi

}


xmatchTwoImage ( )
{
    toleranceradius=10	
    matchflag=tolerance	
	fitorder=4
	

    echo `date` "First tolerance match"
    rm -rf $imagetmp3sd $imagetrans3sd
    cd $HOME/iraf
    cp -f login.cl.old login.cl
    echo noao >> login.cl
    echo image >> login.cl
    echo "cd $DIR_data" >> login.cl
    echo "xyxymatch(\"image.sex\",\"tempForCombine.sex\", \"$imagetmp3sd\",toleranc=$toleranceradius, xcolumn=1,ycolumn=2,xrcolum=1,yrcolum=2,separation=7, matchin=\"$matchflag\", inter-,verbo-) " >>login.cl
    echo "geomap(\"$imagetmp3sd\", \"$imagetrans3sd\", transfo=\"$inprefix\", verbos-, xmin=1, xmax=$xNpixel, ymin=1, ymax=$yNpixel,fitgeom=\"general\", functio=\"legendre\",xxorder=$fitorder,xyorder=$fitorder,xxterms=\"half\",yxorder=$fitorder,yyorder=$fitorder,yxterms=\"half\", maxiter=5,reject=3,inter-)" >>login.cl
    echo logout >> login.cl
    cl < login.cl >xlogfile
    cd $HOME/iraf
    cp -f login.cl.old login.cl
    cd $DIR_data
    xrms=`cat $imagetrans3sd | grep "xrms" | awk '{print($2)}'`
    yrms=`cat $imagetrans3sd | grep "yrms" | awk '{print($2)}'`
    xxshift=`cat $imagetrans3sd | grep "xshift" | awk '{print($2)}'`
    yyshift=`cat $imagetrans3sd | grep "yshift" | awk '{print($2)}'`
    if test -r $imagetrans3sd
    then
        #echo "First xyxymatch with tolerance is finished!"
        xrms=`cat $imagetrans3sd | grep "xrms"  | awk '{print($2)}'`
        yrms=`cat $imagetrans3sd | grep "yrms"  | awk '{print($2)}'`
        echo `cat $imagetrans3sd | grep "shift"`
        echo $xrms $yrms
        Ntemp3sd=`cat $imagetmp3sd | wc -l | awk '{print($1)}'`
        #============================
        #	to check wether the match is good enough or not by rms at X-axis and Y-axis.
        if [ ` echo " $xrms > 0.13 " | bc ` -eq 1 ] || [ ` echo " $yrms > 0.13 " | bc ` -eq 1 ] || [ ` echo " $Ntemp3sd < 100.0 " | bc ` -eq 1 ] # if not good enough
        then
		echo "match failed"
		continue
	else
		echo "xyxymatch is successful"
		xtransImageToTemp
	fi
    else
	echo "No $imagetrans3sd"
    fi
}

xmakeTemp ( )
{
	firstimage=`head -1 $comlist`
	bgimage=`echo $firstimage | sed 's/\.fit/.bg.fit/'`
    ls xmatchdaofind.sex
	 sex $firstimage  -c  xmatchdaofind.sex -DETECT_THRESH 20 -ANALYSIS_THRESH 20 -CATALOG_NAME image.sex -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME  $bgimage
	rm -rf $bgimage
    cat image.sex | awk '{if($4==0)print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' >tempForCombine.sex
	rm image.sex
    #ls $firstimage >newcomlistwithshift
}

xgetstarsForOtherImages ( )
{
	sed -n '2,20p' $comlist >listtemp
	for fitfile in `cat listtemp`
	do
        echo $fitfile
		bgimage=`echo $fitfile | sed 's/\.fit/.bg.fit/'`
                imagetmp3sd=`echo $fitfile | sed 's/\.fit/.fit.mattemp3sd/'`
                imagetrans3sd=`echo $fitfile | sed 's/\.fit/.fit.trans3sd/'`
                inprefix=`echo $fitfile | sed 's/\.fit//'`
		        tran2=`echo $fitfile | sed 's/\.fit/.2sd.fit/'`             
		xNpixel=`gethead $fitfile "NAXIS1"`
                yNpixel=`gethead $fitfile "NAXIS2"`	
    ls xmatchdaofind.sex

		sex $fitfile  -c  xmatchdaofind.sex -DETECT_THRESH 25 -ANALYSIS_THRESH 25 -CATALOG_NAME image.sex -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME  $bgimage
		rm -rf $bgimage
        cat image.sex | awk '{if($4==0)print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)}' >temp
        mv temp image.sex
        cp image.sex newimage.sex
		xmatchTwoImage
		wait
		rm -rf image.sex
	done
		ximcombine
}


xmakeTemp
xgetstarsForOtherImages


