#!/bin/bash

DIR_data=`pwd`
FITFILE=$1
echo $FITFILE 
OUTPUT=`echo $FITFILE | sed 's/\.fit/.fit.sex/'`
sex $FITFILE  -c  xmatchdaofind.sex -DETECT_THRESH 100 -ANALYSIS_THRESH 100 -CATALOG_NAME $OUTPUT -CHECKIMAGE_TYPE BACKGROUND -CHECKIMAGE_NAME $bg
rm -rf $bg
sigma=`cat $OUTPUT | head -1 | awk '{print($6)}'`
photaper=`echo 1.273,2,4,6,7,8,9,10`
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo image >>login.cl
echo apphot >>login.cl
echo "cd $DIR_data" >> login.cl
echo $OUTPUT
echo "centerpars(cbox=5)" >>login.cl
echo "datapars(fwhmpsf=\"1.6\",emissio+,sigma=\"$sigma\",readnoi=10,epadu=1.3)" >>login.cl
echo "fitskypars(annulus=15,dannulu=5)" >>login.cl
echo "photpars(apertur=\"$photaper\")" >>login.cl
echo "phot(image=\"$FITFILE\",coords=\"$coordsfile\",output=\"phot.res\",interac-,verbose-,verify-)" >>login.cl
echo logout >> login.cl
cl < login.cl >xlogfile
cd $HOME/iraf
cp -f login.cl.old login.cl
cd $DIR_data

#===========================================
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo image >>login.cl
echo apphot >>login.cl
echo "cd $DIR_data" >> login.cl
echo $OUTPUT
echo "txdump(textfile=\"phot.res\",fields=\"xc,yc,mag\",expr+,headers- )" >>login.cl
echo logout >> login.cl
cl < login.cl >xphotres
mv xphotres $DIR_data
cd $HOME/iraf
cp -f login.cl.old login.cl
cd $DIR_data
cat -n xphotres | awk '{print($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$4/$11)}' >xphotres_addflux
gnuplot PlotPercenty.gn
