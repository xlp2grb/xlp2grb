#!/bin/bash
#author: xlp
#20140226
#to trim the subimage from subimage with the coords in RC3
DIR_data=`pwd`
CCDsize=3056
CCDsize_Big=`echo $CCDsize | awk '{print($1-1)}'`
tsize=50
filename=$1
fitfile=refcom.fit
echo $filename

xtrimOTsubimage ( )
{
	ra=`cat new.log | awk '{print($10)}'`
	dec=`cat new.log | awk '{print($11)}'`
	rc3name=`cat new.log | awk '{print($9)}'`
	xim=`cat new.log | awk '{print($1)}'`
	yim=`cat new.log | awk '{print($2)}'`
	imsubname=`echo $rc3name"_OT_X"$xim"Y_"$yim".fit"`
	#echo $imsubname $refsubname
	xmin=`echo  $xim | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
	xmax=`echo  $xim | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
	ymin=`echo  $yim | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
	ymax=`echo  $yim | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
	
	if [ $(echo "$xmin < 0"|bc) = 1 ]
	then
	        xshift=`echo $xmin | awk '{print($1-0)}'`
	        xmin=1
	fi
	if [ $(echo "$xmax >= $CCDsize" |bc) = 1 ]
	then
	#       xshift=`echo $xmax | awk '{print($1-ccdsize_big)}' ccdsize_big=$CCDsize_Big`
	        xmax=$CCDsize_Big
	fi
	
	if [ $(echo "$ymin < 0" |bc) = 1 ]
	then
	        yshift=`echo $ymin | awk '{print($1-0)}'`
	        ymin=1
	fi
	
	if [ $(echo "$ymax >= $CCDsize" |bc) = 1 ]
	then
	#       yshift=`echo $ymax | awk '{print($1-ccdsize_big)}' ccdsize_big=$CCDsize_Big`
	        ymax=$CCDsize_Big
	fi
	#echo $imsubname $xmin $xmax $ymin $ymax $xshift $yshift
	xot_sub=`echo $xim $xmin $xshift | awk '{print($1-$2+$3)}'`
	yot_sub=`echo $yim $ymin $yshift | awk '{print($1-$2+$3)}'`
	imtrimregion=`echo "["$xmin":"$xmax","$ymin":"$ymax"]"`
	
	cd $HOME/iraf3
	cp -f login.cl.old login.cl
	echo noao >> login.cl
	echo imred >> login.cl
	echo ccdred >>login.cl
	echo "cd $DIR_data" >> login.cl
	echo "ccdpro(images=\"$fitfile\",output=\"$imsubname\",trim+,zerocor-,darkcor-,flatcor-,trimsec=\"$imtrimregion\") " >>login.cl
	echo logout >> login.cl
	#cl < login.cl
	cl < login.cl >xlogfile
	cd $HOME/iraf3
	cp -f login.cl.old login.cl
	
	cd $DIR_data
}

cp $filename newlist
NumOT=`wc matchchb.log | awk '{print($1)}'`
for ((i=0;i<$NumOT;i++))
do
        cat newlist | head -1 >new.log
        sed -n '2,2000p' newlist >temp
        mv temp newlist
        xtrimOTsubimage
done
rm -rf temp newlist
