DIR_data=$1

imtrimregion=[1550:1750,2000:2200]

ximstat ()
{
cd $HOME/iraf3
cp -f login.cl.old login.cl
echo noao >> login.cl
echo imred >> login.cl
echo ccdred >>login.cl
echo "cd $DIR_data" >> login.cl
echo "imstat(images=\"$imsubname\") " >>login.cl
echo logout >> login.cl
cl < login.cl >outputimstat
cd $HOME/iraf3
cp -f login.cl.old login.cl
mv outputimstat $DIR_data
cd $DIR_data
meanvalue=`cat outputimstat | tail -1 | awk '{print($3)}'`
z1=`echo $meanvalue | awk '{print($1-300)}'`
z2=`echo $meanvalue | awk '{print($1+500)}'`
echo $meanvalue $z1 $z2
}

trimsub ()
{
cd $HOME/iraf3
cp -f login.cl.old login.cl
echo noao >> login.cl
echo imred >> login.cl
echo ccdred >>login.cl
echo "cd $DIR_data" >> login.cl
echo "ccdpro(images=\"$FILE\",output=\"$imsubname\",trim+,zerocor-,darkcor-,flatcor-,trimsec=\"$imtrimregion\") " >>login.cl
echo logout >> login.cl
#cl < login.cl
cl < login.cl >xlogfile
cd $HOME/iraf3
cp -f login.cl.old login.cl
cd $DIR_data
if test -r $imsubname
then
	ximstat
	wait
        ds9  -fits $imsubname -scale limits  $z1 $z2 -zoom to fit -geometry 500x500 -saveimage jpeg 50 $imsubnamePNG -exit
        wait
	if test -r $imsubnamePNG
	then
		mv $imsubnamePNG pngfile
	fi
fi

mv $imsubname trimfile
}

cd $DIR_data
for FILE in `cat list`
do
	echo $FILE
	imsubname=`echo $FILE | sed 's/.fits/_trim.fit/'`
	imsubnamePNG=`echo $FILE | sed 's/.fits/_trim.png/'`
	trimsub
done
convert -delay 20 *.png -loop 0 C1212.gif
echo "finished!!!"
