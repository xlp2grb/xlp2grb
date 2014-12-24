#!/bin/bash

DIR_data=`pwd`
tsize=20
CCDsize=3056
CCDsize_Big=`echo $CCDsize | awk '{print($1-1)}'`
refimage=refcom.fit
#ls *skyOT >listOT
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
./xmknewfile.sh
date -u >time_dir
year=`cat time_dir | awk '{print($6)}'`
month=`cat time_dir | awk '{print($2)}'`
day=`cat time_dir | awk '{print($3)}'`
otsubdictory=`echo "$HOME/workspace/resultfile/"$year$month$day"/otsubimfile"`
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
for FILE in `cat listOT`
do
	NumOT=`wc $FILE | awk '{print($1)}'`
	for ((i=0;i<$NumOT;i++))
	do
		realfile=`cat $FILE | awk '{print($8)}'`
		cp $realfile filename
		file_whole=`echo $realfile`
		prefix=`echo $realfile | sed 's/\.fit//'`
		echo $prefix $file_whole
		echo $FILE $file_whole $prefix $NumOT

		#cat filename | head -1 >FILE 
		#diff FILE filename | grep  ">" | tr -d '>' | column -t >fileleft
		ra=`cat $FILE | awk '{print($1)}'`
		dec=`cat $FILE | awk '{print($2)}'`
		xim=`cat $FILE | awk '{print($3)}'`
		yim=`cat $FILE | awk '{print($4)}'`
		xref=`cat $FILE | awk '{print($5)}'`
		yref=`cat $FILE | awk '{print($6)}'`
		
		imsubname=`echo $prefix"_OT_X"$xim"Y_"$yim".fit"`
		refsubname=`echo $prefix"_OT_X"$xim"Y_"$yim"_ref.fit"`
#		echo $imsubname $refsubname
# for new image coord
		xmin=`echo  $xim | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
		xmax=`echo  $xim | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
		ymin=`echo  $yim | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
		ymax=`echo  $yim | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
# for ref image coord
		xrefmin=`echo  $xref | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
		xrefmax=`echo  $xref | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
		yrefmin=`echo  $yref | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
		yrefmax=`echo  $yref | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
# xyshift for new image and ref image
		xshift=1
		yshift=1
# for new image 
		if [ $(echo "$xmin < 0"|bc) = 1 ]
		then
#			xshift=`echo $xmin | awk '{print($1-0)}'`
			xmin=1
		fi
		if [ $(echo "$xmax >= $CCDsize" |bc) = 1 ]
                then
		#	xshift=`echo $xmax | awk '{print($1-ccdsize_big)}' ccdsize_big=$CCDsize_Big`
                        xmax=$CCDsize_Big
                fi

		if [ $(echo "$ymin < 0" |bc) = 1 ]
                then
#			yshift=`echo $ymin | awk '{print($1-0)}'`
                        ymin=1
                fi

		if [ $(echo "$ymax >= $CCDsize" |bc) = 1 ]
                then
		#	yshift=`echo $ymax | awk '{print($1-ccdsize_big)}' ccdsize_big=$CCDsize_Big`
                        ymax=$CCDsize_Big
                fi
#		echo $imsubname $xmin $xmax $ymin $ymax $xshift $yshift
		xot_sub=`echo $xim $xmin $xshift | awk '{print($1-$2+$3)}'`
		yot_sub=`echo $yim $ymin $yshift | awk '{print($1-$2+$3)}'`  
		imtrimregion=`echo "["$xmin":"$xmax","$ymin":"$ymax"]"`
#======================================================		
# for ref image
                if [ $(echo "$xrefmin < 0"|bc) = 1 ]
                then
                        xrefmin=1
                fi
                if [ $(echo "$xrefmax >= $CCDsize" |bc) = 1 ]
                then
                        xrefmax=$CCDsize_Big
                fi

                if [ $(echo "$yrefmin < 0" |bc) = 1 ]
                then
                        yrefmin=1
                fi

                if [ $(echo "$yrefmax >= $CCDsize" |bc) = 1 ]
                then
                        yrefmax=$CCDsize_Big
                fi
               echo $imsubname $xmin $xmax $ymin $ymax $xshift $yshift
                xrefot_sub=`echo $xref $xrefmin $xshift | awk '{print($1-$2+$3)}'`
                yrefot_sub=`echo $yref $yrefmin $yshift | awk '{print($1-$2+$3)}'`
                reftrimregion=`echo "["$xrefmin":"$xrefmax","$yrefmin":"$yrefmax"]"`

		echo $file_whole $imsubname $imtrimregion $reftrimregion
#=====================================================================

	#	echo $imtrimregion $reftrimregion
		cd $HOME/iraf
	        cp -f login.cl.old login.cl
	        echo noao >> login.cl
		echo imred >> login.cl
	        echo ccdred >>login.cl
	        echo "cd $DIR_data" >> login.cl
		echo "ccdpro(images=\"$file_whole\",output=\"$imsubname\",trim+,zerocor-,darkcor-,flatcor-,trimsec=\"$imtrimregion\") " >>login.cl
		echo "ccdpro(images=\"$refimage\",output=\"$refsubname\",trim+,zerocor-,darkcor-,flatcor-,trimsec=\"$reftrimregion\") " >>login.cl
	        echo logout >> login.cl
	        cl < login.cl >xlogfile 
	
	        cd $HOME/iraf
	        cp -f login.cl.old login.cl
	        cd $DIR_data
		sethead -kr X ra=$ra dec=$dec epoch=J2000 xref=$xref yref=$yref xim=$xim yim=$yim xOT_sub=$xot_sub yOT_sub=$yot_sub OTtext=$FILE imwhole=$file_whole refsubimage=$refsubname $imsubname	
		sethead -kr X ra=$ra dec=$dec epoch=J2000 xref=$xref yref=$yref xim=$xim yim=$yim xref_sub=$xrefot_sub yref_sub=$yrefot_sub OTtext=$FILE imwhole=$file_whole imsubimage=$imsubname $refsubname		
		echo $imsubname $refsubname
		mv $imsubname $refsubname $otsubdictory		
#===================================================
		#mv fileleft filename	
	done
done
