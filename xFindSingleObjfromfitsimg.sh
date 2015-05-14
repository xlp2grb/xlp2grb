#!/bin/bash
if [ $# -ne 4 ]
then
	echo "usage: xFindSingleObj.sh ra dec[mount]  xtempfile ytempfile "
	exit 0
fi
echo "xFindSingleObj.sh from raw data from a single CCD"
ra=$1
dec=$2
xtempfile=$3
ytempfile=$4
boxpixel=200
CCDsize=3056
CCDsize_Big=`echo $CCDsize | awk '{print($1-1)}'`
#ra and dec are the coords of mount pointing which is parts of fits name
cd /data
echo M* | xargs -n 1 >findsingleobj.lst
if test ! -r cutfitsfile
then 
	mkdir cutfitsfile
fi
xcutfits ( )
{
echo "======xcutfits====="
echo $fitsforcut
    FILEforsub=$1
    imsubname=`echo $FILEforsub | sed 's/\.fits/_cut.fit/g'`
    xim=$xtempfile
    yim=$ytempfile
    
    #echo $FILEforsub $imsubname $xim $yim 
    xmin=`echo  $xim | awk '{printf("%.0f", $1-tsize)}' tsize=$boxpixel`
    xmax=`echo  $xim | awk '{printf("%.0f", $1+tsize)}' tsize=$boxpixel`
    ymin=`echo  $yim | awk '{printf("%.0f", $1-tsize)}' tsize=$boxpixel`
    ymax=`echo  $yim | awk '{printf("%.0f", $1+tsize)}' tsize=$boxpixel`
    xshift=1
    yshift=1

   if [ $(echo "$xmin < 0"|bc) = 1 ]
    then
        xshift=`echo $xmin | awk '{print($1-0)}'`
        xmin=1
    fi
    if [ $(echo "$xmax >= $CCDsize" | bc ) = 1 ]
    then
        xmax=$CCDsize_Big
    fi

    if [ $(echo "$ymin < 0" |bc) = 1 ]
    then
        yshift=`echo $ymin | awk '{print($1-0)}'`
        ymin=1
    fi

    if [ $(echo "$ymax >= $CCDsize" |bc) = 1 ]
    then
        ymax=$CCDsize_Big
    fi

    imtrimregion=`echo "["$xmin":"$xmax","$ymin":"$ymax"]"`
    #======================================================         
    #echo "using iraf.ccdpro to cut the fit"
    echo $imtrimregion

    cd $HOME/iraf4
    cp -f login.cl.old login.cl
    echo noao >> login.cl
    echo imred >> login.cl
    echo ccdred >>login.cl
    echo "cd $dir_rawdata" >> login.cl
    echo "ccdpro(images=\"$FILEforsub\",output=\"$imsubname\",trim+,zerocor-,darkcor-,flatcor-,trimsec=\"$imtrimregion\") " >>login.cl
    echo logout >> login.cl
    cl < login.cl >xlogfile
    #cl <login.cl
    cd $HOME/iraf4
    cp -f login.cl.old login.cl
    cd $dir_rawdata
    sethead -kr X xim=$xim yim=$yim Trimsec=$imtrimregion  imwhole=$FILEforsub  $imsubname
    mv $imsubname $dir_cutfitsfileIndate
}


for dir_rawdata in `cat findsingleobj.lst`
do
	echo $dir_rawdata
	dir_cutfitsfileIndate=`echo /data/cutfitsfile/$dir_rawdata`
	if test ! -r $dir_cutfitsfileIndate
	then
		mkdir $dir_cutfitsfileIndate
	fi
	dir_rawdata=`echo /data/$dir_rawdata`
	cd $dir_rawdata
	mv fitsbakfile/*.fits ./
	ls *.fits >listforcut
	for fitsforcut in `cat listforcut`
	do
		#echo $fitsforcut
		ccdtype=`echo $fitsforcut | cut -c14-14`
		 ra_mount=`echo $fitsforcut | cut -c16-18 | awk '{printf("%d\n",$1)}'`
		dec_mount=`echo $fitsforcut | cut -c19-21 | awk '{printf("%d\n",$1)}'`
		if [ $ccdtype == 5  ]
		then
			xcutfits  $fitsforcut
		else
			echo $fitsforcut
			echo $ra $ra_mount $dec $dec_mount
			if [ "$ra_mount" != "$ra" ] || [ "$dec_mount" !=  "$dec" ]
			then
				echo "This image is not the required fits"
			else 
				xcutfits  $fitsforcut
			fi
		fi  
	done
	
done
