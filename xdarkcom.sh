#!/bin/bash
DIR_data=`pwd`
gain=1.3
rdnoise=10
rm -rf Dark*.fit
#ls dark*.fit >listdark
#============================
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo imred >>login.cl
echo ccdred >>login.cl
echo "cd $DIR_data" >> login.cl
echo "darkcombine(input=\"@listdark\", output=\"Dark.fit\",combine=\"median\",reject=\"minmax\",ccdtyp=\" \",process-,rdnoise=$rdnoise,gain=$gain,)" >>login.cl
#echo "display(image=\"Dark.fit\",frame=1)" >>login.cl
echo logout >> login.cl
cl < login.cl >xlogfile 
cd $HOME/iraf
cp -f login.cl.old login.cl
cd $DIR_data
rm -rf badpixelFile.db
sex Dark.fit  -c  xmatchdaofind.sex -DETECT_THRESH 5 -ANALYSIS_THRESH 5 -CATALOG_NAME badpixelFile.db
cat badpixelFile.db | grep -v "99.0000" >temp
mv temp badpixelFile.db
wc badpixelFile.db
bgflux=`cat badpixelFile.db | head -1 | awk '{print($5)}'`
if [ `echo "$bgflux > 5000.0 " | bc ` -eq 1  ]
then
    echo "Dark image is not correct"
    rm Dark.fit badpixelFile.db
fi    
#cd $HOME/iraf
#cp -f login.cl.old login.cl
#echo noao >> login.cl
#echo imred >>login.cl
#echo ccdred >>login.cl
#echo "cd $DIR_data" >> login.cl
#echo "tvmark(frame=1,coords=\"badpixelFile.db\",mark=\"circle\",radii=20,color=204,label-)" >>login.cl
#echo logout >> login.cl
#cl < login.cl >xlogfile
#cd $HOME/iraf
#cp -f login.cl.old login.cl
#cd $DIR_data

