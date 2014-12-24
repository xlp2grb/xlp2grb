#!/bin/bash
#author: xlp
#20140225
#modified by xlp at 20140410
#to display the subimage automatically from the output of the code starclassify by xuyang
#it requires all the fits in a single file $DIR_data

date -u >time_dir
year=`cat time_dir | awk '{print($6)}'`
month=`cat time_dir | awk '{print($2)}'`
day=`cat time_dir | awk '{print($3)}'`
DIR_data=`echo "/data2/workspace/resultfile/"$year$month$day"/otsubimfile"`
#DIR_data=/data/workspace/resultfile/2014Apr9/otsubimfile
cd $DIR_data


tvcolorred=204
tvcolorgreen=205
i=1

if test ! -f bakfile
then
	mkdir bakfile
fi

trotimage (  )
{
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl
        echo "display(image=\"$fitfile\",frame=$i)" >>login.cl #display newimage in frame 1
        echo "tvmark(frame=$i,coords=\"filemark\",mark=\"circle\",radii=2,color=$tvcolorred,label+, nyoffse=15,pointsi=5,txsize=10)" >>login.cl #tvmark new OT in frame 1
        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
	mv $fitfile bakfile
}

trrefimage (  )
{
	cd $HOME/iraf
        cp -f login.cl.old login.cl
        echo noao >> login.cl
        echo image >> login.cl
        echo "cd $DIR_data" >> login.cl
        echo "display(image=\"$reffitfile\",frame=$ri)" >>login.cl #display newimage in frame 2
        echo "tvmark(frame=$ri,coords=\"filemarkref\",mark=\"circle\",radii=2,color=$tvcolorgreen, label+, nyoffse=15,pointsi=5,txsize=5 )" >>login.cl #tvmark new OT in frame 2
        echo logout >> login.cl
        cl < login.cl >xlogfile
        cd $HOME/iraf
        cp -f login.cl.old login.cl
        cd $DIR_data
        mv $reffitfile bakfile
        break
}

getcoords (  )
{
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
}

#=========================
#main function

ls *_OT_*.fit | grep -v "ref" >listmark
N_OTimage=`cat listmark | wc -l | awk '{print($1+1)}'`
for FILE in `cat listmark`
do
	getcoords
	trotimage
	j=`echo $i | awk '{print($1+1)}'`
	i=`echo $j`
	
	if [ $i -eq 16 ]
	then
		ri=16
		trrefimage
	elif  [ $i -eq $N_OTimage ]
	then
		ri=`echo $i`
		trrefimage
	else
		echo $i
	fi
done
#=========================
