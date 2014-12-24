ls *.mag.1 >list
for magfile in `cat list`
do
	parafile=`echo $magfile |  sed 's/\.mag.1/.magf/'`
	sh xTxdump.sh $magfile $parafile
done
