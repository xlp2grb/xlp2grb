#!/bin/bash
#20140225
#xlp
#to read the file matchchb.log to trim the subimages
DIR_data=`pwd`
tsize=20
CCDsize=3056
CCDsize_Big=`echo $CCDsize | awk '{print($1-1)}'`
refimage=refcom_subbg.fit
#ls *skyOT >listOT
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
./xmknewfile.sh
date -u >time_dir
year=`cat time_dir | awk '{print($6)}'`
month=`cat time_dir | awk '{print($2)}'`
day=`cat time_dir | awk '{print($3)}'`
otsubdictory=`echo "/data/workspace/resultfile/"$year$month$day"/otsubimfile"`

xtrimOTsubimage ( )
{
FILE_old=`cat new.log | awk '{print($8)}'`
FILE=`echo $FILE_old | sed 's/\.fit/.subbg.fit/'`
echo $FILE
prefix=`echo $FILE | sed 's/\.fit//'`
ra=`cat new.log | awk '{print($1)}'`
dec=`cat new.log | awk '{print($2)}'`
xim=`cat new.log | awk '{print($3)}'`
yim=`cat new.log | awk '{print($4)}'`
xref=`cat new.log | awk '{print($5)}'`
yref=`cat new.log | awk '{print($6)}'`
ximTrim=`cat new.log | awk '{printf("%4.0f",$3)}'`
yimTrim=`cat new.log | awk '{printf("%4.0f",$4)}'`
imsubname=`echo $prefix"_OT_X"$ximTrim"Y_"$yimTrim".fit"`
refsubname=`echo $prefix"_OT_X"$ximTrim"Y_"$yimTrim"_ref.fit"`
#echo $imsubname $refsubname
xmin=`echo  $xim | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
xmax=`echo  $xim | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
ymin=`echo  $yim | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
ymax=`echo  $yim | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
xrefmin=`echo  $xref | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
xrefmax=`echo  $xref | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
yrefmin=`echo  $yref | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
yrefmax=`echo  $yref | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
# xyshift for new image and ref image
xshift=1
yshift=1

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

#======================================================         

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
#echo $imsubname $xmin $xmax $ymin $ymax $xshift $yshift
xrefot_sub=`echo $xref $xrefmin $xshift | awk '{print($1-$2+$3)}'`
yrefot_sub=`echo $yref $yrefmin $yshift | awk '{print($1-$2+$3)}'`
reftrimregion=`echo "["$xrefmin":"$xrefmax","$yrefmin":"$yrefmax"]"`
echo "&&&&&&&&&&&&"
echo $FILE $imsubname $imtrimregion 
#echo $reftrimregion
#======================================================

#echo "###############"
cd $HOME/iraf3
cp -f login.cl.old login.cl
echo noao >> login.cl
echo imred >> login.cl
echo ccdred >>login.cl
echo "cd $DIR_data" >> login.cl
#echo "display(image=\"$FILE\",frame=3)" >>login.cl
echo "ccdpro(images=\"$FILE\",output=\"$imsubname\",fixpix-,oversca-,trim+,zerocor-,darkcor-,flatcor-,trimsec=\"$imtrimregion\") " >>login.cl
echo "ccdpro(images=\"$refimage\",output=\"$refsubname\",fixpix-,oversca-,trim+,zerocor-,darkcor-,flatcor-,trimsec=\"$reftrimregion\") " >>login.cl
#echo "display(image=\"$imsubname\",frame=2)" >>login.cl
echo logout >> login.cl
#cl < login.cl
cl < login.cl >xlogfile
cd $HOME/iraf3
cp -f login.cl.old login.cl

cd $DIR_data
#echo $imsubname $refsubname $ra $dec $xref $yref $xim $yim $xot_sub $yot_sub $FILE $refsubname
sethead -kr X ra=$ra dec=$dec epoch=J2000 xref=$xref yref=$yref xim=$xim yim=$yim xOT_sub=$xot_sub yOT_sub=$yot_sub  imwhole=$FILE refsubimage=$refsubname $imsubname
sethead -kr X ra=$ra dec=$dec epoch=J2000 xref=$xref yref=$yref xim=$xim yim=$yim xref_sub=$xrefot_sub yref_sub=$yrefot_sub imwhole=$FILE imsubimage=$imsubname $refsubname
#echo "@@@@@@@@@@@@@@@"
#echo $imsubname $refsubname
mv $imsubname $refsubname $otsubdictory
}

echo `date` >time1.log
cp matchchb.log newlist
NumOT=`wc matchchb.log | awk '{print($1)}'`
for ((i=0;i<$NumOT;i++))
do
	cat newlist | head -1 >new.log
	sed -n '2,2000p' newlist >temp
	mv temp newlist
	xtrimOTsubimage		
done
echo `date` >>time1.log
cat time1.log
