echo `date` "display temp and new image and tvmark these OTc1"
DIR_data=`pwd`
magfile=$1
resfile=$2
stringPerameters=`echo "flux,stdev,area"`
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo digiphot >> login.cl
echo image >> login.cl
echo imcoords >>login.cl
echo "cd $DIR_data" >> login.cl
echo "txdump(textfile=\"$magfile\",fields=\"$stringPerameters\",expr+)" >>login.cl
echo logout >> login.cl
cl < login.cl >$resfile
cd $HOME/iraf
cp -f login.cl.old login.cl
cp $resfile $DIR_data
cd $DIR_data

