DIR_data=`pwd`
raH=$1
decH=$2
Accfile=refcom.acc
skycoor -d $raH $decH >radecfile
rm -rf xyfile
cd $HOME/iraf
cp -f login.cl.old login.cl
echo noao >> login.cl
echo digiphot >> login.cl
echo image >> login.cl
echo imcoords >>login.cl
echo "cd $DIR_data" >> login.cl
echo "cctran(input=\"radecfile\",output=\"xyfile\", database=\"$Accfile\",solutions=\"first\", geometry=\"geometric\",forward-,lngunits=\"degrees\",latunits=\"degrees\",projection=\"tan\",xcolumn=1,ycolumn=2, lngform=\"%12.9f\",latform=\"%12.9f\",min_sigdigits=7) " >>login.cl
echo logout >> login.cl
cl < login.cl >>xlogfile
cd $HOME/iraf
cp -f login.cl.old login.cl
cd $DIR_data
paste xyfile radecfile  | column -t >xy_radecfile
echo $raH $decH >>xy_radecfile
cat xy_radecfile | tr '\n' '  '  >tempfile
echo >>tempfile
mv tempfile xy_radecfile
cat xy_radecfile
