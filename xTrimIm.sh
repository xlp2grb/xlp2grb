#!/bin/bash
#20140225
#modied by 20140513
#xlp
#to read the file matchchb.log to trim the subimages
DIR_data=/data2/workspace/redufile/trimsubimage
DIR_now=`pwd`
cd $DIR_data
tsize=20
CCDsize=3056
CCDsize_Big=`echo $CCDsize | awk '{print($1-1)}'`

xmknewfile.sh
date -u >time_dir
year=`cat time_dir | awk '{print($6)}'`
month=`cat time_dir | awk '{print($2)}'`
day=`cat time_dir | awk '{print($3)}'`
otsubdictory=`echo "/data2/workspace/resultfile/"$year$month$day"/otsubimfile"`

xmkupload ()
{
#echo "---xmkupload---"
cd pngfile
dateobs=`echo $last2sdOTlog | cut -c16-21`
ccdtype=`echo $last2sdOTlog | cut -c13-14 | awk '{print("M"$1)}'`
imagefit=`ls *.fit | head -1`
imagepng=`ls *.png | head -1`
pnglist=`ls *.png *fit | awk '{print($1",")}' | tr '\n' ' ' | sed 's/, $//'`
prefixlog=`echo $last2sdOTlog | cut -c10-35 `
configfile=`echo $prefixlog".properties"`
pnguploadlist=`ls *.png *fit *.log | awk '{print("-F fileUpload=@"$1)}' | tr '\n' ' '`

echo "otlist=$last2sdOTlog
starlist=
origimage=
cutimages=$pnglist" >$configfile

echo "curl  http://190.168.1.25:8080/svom/uploadAction.action -F dpmName=$ccdtype  -F currentDirectory=$dateobs -F configFile=@$configfile $pnguploadlist" >xupload.sh

#echo "curl  http://10.36.1.154:8080/svom/uploadAction.action -F dpmName=$ccdtype  -F currentDirectory=$dateobs -F configFile=@$configfile $pnguploadlist" >xupload.sh

sh xupload.sh
wait
#rm -rf xupload.sh $configfile
cd $DIR_data
}

xnoTrimHistory ()
{
ximTrim_center=`echo $ximTrim | awk '{printf("%04d\n",$1)}'`
yimTrim_center=`echo $yimTrim | awk '{printf("%04d\n",$1)}'`
echo $ximTrim $yimTrim >>trimcenter.cat #update
imsubname=`echo $prefix"_OT_X"$ximTrim_center"Y"$yimTrim_center".fit"`
imsubnamePNG=`echo $prefix"_OT_X"$ximTrim_center"Y"$yimTrim_center".png"`
}

ximagetrim ()
{
#echo "to get the trim section"
xmin=`echo  $xim | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
xmax=`echo  $xim | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
ymin=`echo  $yim | awk '{printf("%.0f", $1-tsize)}' tsize=$tsize`
ymax=`echo  $yim | awk '{printf("%.0f", $1+tsize)}' tsize=$tsize`
xshift=1
yshift=1

if [ $(echo "$xmin < 0"|bc) = 1 ]
then
        xshift=`echo $xmin | awk '{print($1-0)}'`
        xmin=1
fi
if [ $(echo "$xmax >= $CCDsize" |bc) = 1 ]
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
#echo "@@@@@@@@@@@@@"
echo $imsubname $xmin $xmax $ymin $ymax $xshift $yshift
xot_sub=`echo $xim $xmin $xshift | awk '{print($1-$2+$3)}'`
yot_sub=`echo $yim $ymin $yshift | awk '{print($1-$2+$3)}'`
imtrimregion=`echo "["$xmin":"$xmax","$ymin":"$ymax"]"`
#echo $FILE $imsubname
#======================================================         


#echo "###############"
cd $HOME/iraf3
cp -f login.cl.old login.cl
echo noao >> login.cl
echo imred >> login.cl
echo ccdred >>login.cl
echo "cd $DIR_data" >> login.cl
echo "ccdpro(images=\"$FILEforsub\",output=\"$imsubname\",trim+,zerocor-,darkcor-,flatcor-,trimsec=\"$imtrimregion\") " >>login.cl
echo logout >> login.cl
#cl < login.cl
cl < login.cl >xlogfile
cd $HOME/iraf3
cp -f login.cl.old login.cl

cd $DIR_data
#echo $imsubname $refsubname $ra $dec $xref $yref $xim $yim $xot_sub $yot_sub $FILE $refsubname
sethead -kr X ra=$ra dec=$dec epoch=J2000 xref=$xref yref=$yref xim=$xim yim=$yim xOT_sub=$xot_sub yOT_sub=$yot_sub  imwhole=$FILE  $imsubname
#=============================
#convert fits to png
if test -r $imsubname
then
        ximstat
        wait
        ds9  -fits $imsubname -scale limits  $z1 $z2 -zoom to fit -geometry 500x500 -saveimage jpeg 50 $imsubnamePNG -exit
        wait
fi
}


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
z2=`echo $meanvalue | awk '{print($1+300)}'`
#echo $meanvalue $z1 $z2
}

xtrimOTsubimageSingle ( )
{
echo $FILE
prefix=`echo $FILE | sed 's/\.fit//'`
ra=`cat new.log | awk '{print($1)}'`
dec=`cat new.log | awk '{print($2)}'`
xim=`cat new.log | awk '{print($3)}'`
yim=`cat new.log | awk '{print($4)}'`
xref=`cat new.log | awk '{print($5)}'`
yref=`cat new.log | awk '{print($6)}'`
ximTrim=`cat new.log | awk '{printf("%.0f",$5)}'`
yimTrim=`cat new.log | awk '{printf("%.0f",$6)}'`
echo $ximTrim $yimTrim 
if test -r trimcenter.cat
then
	cat trimcenter.cat | while read ximTrim_center yimTrim_center
	do
#		echo "read trimcenter.cat: " $ximTrim_center $yimTrim_center
#		echo $ximTrim $ximTrim_center $yimTrim $yimTrim_center
		deltaX=`echo $ximTrim $ximTrim_center | awk '{print(($1-$2)*($1-$2))}'`
		deltaY=`echo $yimTrim $yimTrim_center | awk '{print(($1-$2)*($1-$2))}'`
		if [ ` echo " $deltaX < 4.0 " | bc ` -eq 1 ]  &&  [ ` echo " $deltaY < 4.0 " | bc ` -eq 1 ] #same candidate
		then
#			echo "deltaX and deltaY are all smaller than 2.0"
			ximTrim_center=`echo $ximTrim_center | awk '{printf("%04d\n",$1)}'`
			yimTrim_center=`echo $yimTrim_center | awk '{printf("%04d\n",$1)}'`
			imsubname=`echo $prefix"_OT_X"$ximTrim_center"Y"$yimTrim_center".fit"`
			imsubnamePNG=`echo $prefix"_OT_X"$ximTrim_center"Y"$yimTrim_center".png"`	
			echo $imsubname $imsubnamePNG >imagetempfile
			echo "Have trim history for this field"
			#continue
			break
		fi
	done
else
	echo "no trim history and no trimcenter.cat"
	xnoTrimHistory
fi
if test -r imagetempfile
then
        echo "to read the imagetempfile"
        imsubname=`cat imagetempfile | awk '{print($1)}'`
        imsubnamePNG=`cat imagetempfile | awk '{print($2)}'`
        rm -rf imagetempfile
        echo $imsubname $imsubnamePNG
else
	echo "no trim history and no trimcenter.cat"
	xnoTrimHistory
fi
if test ! -r $imsubname
then
	ximagetrim
else
        echo "have been trimed, break"
fi
}

xtrimOTsubimage ( )
{
FILE_old=`cat new.log | awk '{print($8)}'`
imagenum=`echo $FILE_old |  cut -c23-26`
prefixfield=`echo $FILE_old | cut -c1-21`
for msub in -2 -1 0 1 2
do
	echo "msub="$msub
        imagenewnum=`echo $imagenum $msub | awk '{printf("%04d\n",$1+$2)}'`
	FILE=`echo $prefixfield"_"$imagenewnum".fit"`
        FILEforsub=`echo $prefixfield"_"$imagenewnum".fit[0]"`
        xtrimOTsubimageSingle

done
}

if test ! -r bakfile
then
	mkdir bakfile
fi
if test ! -r pngfile
then
	mkdir pngfile
fi
if test ! -r res*.log
then
	continue
fi
echo `date` >time1.log
last2sdOTlog=`ls res*.log | tail -1`
cp $last2sdOTlog newlist

mv res*.log bakfile
NumOT=`wc newlist | awk '{print($1)}'`
echo "numot="$NumOT
for ((i=0;i<$NumOT;i++))
do
	echo "i="$i
	cat newlist | head -1 >new.log
	sed -n '2,2000p' newlist >temp
	mv temp newlist
	xtrimOTsubimage		
done
wait
cd pngfile
mv * $otsubdictory
cd $DIR_data
mv *OT*.fit *OT*.png pngfile
cp bakfile/$last2sdOTlog pngfile	
xmkupload
wait
echo `date` >>time1.log
cat time1.log
cd $DIR_now
