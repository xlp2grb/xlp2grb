#!/bin/bash
#author: xlp
#20140225
#to display the subimage automatically


date -u >time_dir
year=`cat time_dir | awk '{print($6)}'`
month=`cat time_dir | awk '{print($2)}'`
day=`cat time_dir | awk '{print($3)}'`
DIR_data=`echo "/data2/workspace/resultfile/"$year$month$day"/otsubimfile"`
cd $DIR_data


#line=`wc listsubmark | awk '{print($1)}'`
tvcolorred=204
tvcolorgreen=205
i=1
ri=2
#FILE=$1
#echo $DIR_data $line $i $tvcolorred
#ls *_OT_*.fit >listmark

if test ! -f bakfile
then
	mkdir bakfile
fi

while :
do
ls *_OT_*.fit | grep -v "ref" >listmark
for FILE in `cat listmark`
do
	fitfile=$FILE
	echo $fitfile
	reffitfile=`gethead $fitfile "refsubim"`
	
	xot=`gethead $fitfile "xot_sub"`
	yot=`gethead $fitfile "yot_sub"`
	xref=`gethead $reffitfile "xref_sub"`
	yref=`gethead $reffitfile "yref_sub"`
	echo $xot $yot "OT" >filemark
	echo $xref $yref "ref" >filemarkref
	echo $xot $yot $xref $yref	
	cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl
        echo "display(image=\"$fitfile\",frame=$i)" >>login.cl #display newimage in frame 1
        echo "tvmark(frame=$i,coords=\"filemark\",mark=\"circle\",radii=2,color=$tvcolorred,label+, nyoffse=15,pointsi=5,txsize=10)" >>login.cl #tvmark new OT in frame 1
	echo "display(image=\"$reffitfile\",frame=$ri)" >>login.cl #display newimage in frame 2
        echo "tvmark(frame=$ri,coords=\"filemarkref\",mark=\"circle\",radii=2,color=$tvcolorgreen, label+, nyoffse=15,pointsi=5,txsize=5 )" >>login.cl #tvmark new OT in frame 2
        echo logout >> login.cl
        cl < login.cl >xlogfile 
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
	mv $fitfile $reffitfile bakfile
	j=`echo $i | awk '{print($1+2)}'`
	i=`echo $j`
	rj=`echo $ri | awk '{print($1+2)}'`
	ri=`echo $rj`
	echo $i $j
	if [ $i -eq 17 ]
	then
		sleep 1
		i=1
		ri=2
	fi	
done

done
