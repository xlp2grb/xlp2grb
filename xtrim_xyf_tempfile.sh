#!/bin/bash
#to delete the function of xtrimimg, it is not needed anymore. 2015011350113
#to cut the subimage from tempfile
#it needs the iraf file named iraf_trimtempforOT
if test ! -r $HOME/iraf_trimtempforOT
then
    echo "no iraf file with the name of iraf_trimtempforOT"
    exit
fi

Dir_temp=/data2/workspace/tempfile/result


xmkupload (  )
{
    #echo "---xmkupload---"
    pnglist=`cat $listotxy | awk '{print($4".fit,",$4".jpg,")}' | tr '\n' ' ' | sed 's/, $//'`
    fitfile=`head -1 $listotxy | awk '{print($1)}'`
    dateobs=`echo $fitfile | cut -c7-12`
    ccdtype=`echo $fitfile | cut -c4-5 | awk '{print("M"$1)}'`
    prefixlog=`echo $fitfile | sed 's/.fit//g'`
    configfile=`echo $prefixlog"_cut.properties"`

    #echo $crossoutput_sky  $prefixlog $configfile
    pnguploadlist=`cat $listotxy | awk '{print("-F fileUpload=@"$4".fit","-F fileUpload=@"$4".jpg")}' | tr '\n' ' '`

    echo "date=$dateobs
    dpmname=$ccdtype
    dfinfo=
    curprocnumber=
    otlist=
    starlist=
    origimage=
    cutimages=$pnglist" >$configfile
    #echo "curl http://190.168.1.105:8080/gwac/uploadAction.action -F dpmName=$ccdtype  -F currentDirectory=$dateobs -F configFile=@$configfile $pnguploadlist" >xupload.sh
    #echo "curl http://190.168.1.25/uploadAction.action -F dpmName=$ccdtype  -F currentDirectory=$dateobs -F configFile=@$configfile $pnguploadlist"

    echo "curl http://190.168.1.25/uploadAction.action -F dpmName=$ccdtype  -F currentDirectory=$dateobs -F configFile=@$configfile $pnguploadlist" >xupload2OT.sh
    sh xupload2OT.sh
    wait
    rm -rf xupload2OT.sh $configfile $pnglist $listotxy *.jpg
    #cd $DIR_data
}

xcopytemp (   )
{            
    echo "---xcopytemp---"
    tempfilename=`cat xcheckResult | awk '{print($9"_"$8)}'`
    tempfilenamefinal=`echo $Dir_temp"/"$tempfilename`
    # echo $tempfilenamefinal
    echo $tempfilenamefinal >listtemp_dirname  #this file for the update the file xUpdate_refcom3d.cat.sh 
    cp -fr $tempfilenamefinal/refcom_subbg.fit $Dir_redufile
    wait
    mv refcom_subbg.fit TempForcutImg.fit
}            


xcopytempfiletopwd (  )
{
    ID_MountCamara=`gethead  $FILEforsub "IMAGEID" | cut -c14-17`
    ra1=`gethead $FILEforsub "RA"`
    dec1=`gethead $FILEforsub "DEC" `
    ra_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$1)}'`
    dec_mount=`skycoor -d $ra1 $dec1 | awk '{printf("%.0f\n",$2)}'`
    echo $ra_mount $dec_mount $ID_MountCamara >newimageCoord

    gpfile=`echo $Dir_temp"/"GPoint_catalog`
    if test ! -r $gpfile
    then
        echo "no GPoint_catalog"
        continue
    else
        echo "Have GPoint_catalog"
        echo "Have GPoint_catalog" >>$stringtimeForMonitor
        #   cp $gpfile $Dir_redufile
        cat $gpfile | grep -v "^_" | awk '{if($3!="_")print($1,$2,$3,$4,$5,$6)}'>temp
        cp temp $gpfile
        mv temp GPoint_catalog
        ls newimageCoord GPoint_catalog
        ./xcheck_skyfield # The output is named as xcheckResult
        if [ -s xcheckResult  ] ## this case for the temp is ready but not be copied., this file exists and is not emipy
        then       
            xcopytemp
        else       
            echo "no tempfile for this field"
        fi   
    fi
}


xyf_fits2jpg ( )
{
    FILEforsub=$1
    jpgimg=$2
    xim=$3
    yim=$4
    subridus=$5
    xcopytempfiletopwd
    wait
    FILEforsub=`echo TempForcutImg.fit`
    newlineTest=`echo "$FILEforsub $jpgimg $xim $yim $subridus \" \""`
    #echo $newlineTest
    #echo " python fits_cut_to_png.py $newlineTest"
    python fits_cut_to_png.py $newlineTest

}

xfit2jpg ( )
{
    #	echo "============xfit2jpg========="
    cat $listotxy | awk '{print($1,$4".jpg",$2,$3,boxpixel)}' boxpixel=$boxpixel >newfile_listotxy

    cat newfile_listotxy | while read line
do
    #		echo "@@@@@@@@"
    #		echo $line
    xyf_fits2jpg $line
done
rm -rf newfile_listotxy

}
xtrimimage ( )
{
    #	echo "=======xtrimimage====="
    cat $listotxy | awk '{print($1,$4".fit",$2,$3,tsize)}' tsize=$boxpixel >newfile_listotxy
    cat newfile_listotxy | while read line
do
    #		echo $line
    xtrimsubimage $line
done
rm -rf newfile_listotxy
}

xtrimsubimage ( )
{
    #echo "========xtrimsubimage==========="

    FILEforsub=$1
    imsubname=$2
    xim=$3
    yim=$4
    FILEforsubbg=`echo $FILEforsub | sed 's/\.fit/_subbg.fit/g'`
    #====================
    if test ! -r $FILEforsub
    then
        echo "no $FILEforsub"
        if test ! -r $FILEforsubbg
        then
            echo "no $FILEforsubbg"
            continue
        fi
    fi
    #====================
    if test -r $FILEforsubbg
    then
        FILEforsub=$FILEforsubbg
    fi
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
    #echo $imsubname $xmin $xmax $ymin $ymax $xshift $yshift
    #xot_sub=`echo $xim $xmin $xshift | awk '{print($1-$2+$3)}'`
    #yot_sub=`echo $yim $ymin $yshift | awk '{print($1-$2+$3)}'`
    imtrimregion=`echo "["$xmin":"$xmax","$ymin":"$ymax"]"`
    #======================================================         
    #echo "using iraf.ccdpro to cut the fit"
    echo $imtrimregion

    cd $HOME/iraf_trimtempforOT
    cp -f login.cl.old login.cl
    echo noao >> login.cl
    echo imred >> login.cl
    echo ccdred >>login.cl
    echo "cd $DIR_data" >> login.cl
    echo "ccdpro(images=\"$FILEforsub\",output=\"$imsubname\",trim+,zerocor-,darkcor-,flatcor-,trimsec=\"$imtrimregion\") " >>login.cl
    echo logout >> login.cl
    cl < login.cl >xlogfile
    #cl <login.cl
    cd $HOME/iraf_trimtempforOT
    cp -f login.cl.old login.cl
    cd $DIR_data
    sethead -kr X xim=$xim yim=$yim Trimsec=$imtrimregion  imwhole=$FILEforsub  $imsubname
}

#=========================
#main function
listotxy=$1
DIR_data=`pwd`
CCDsize=3056
CCDsize_Big=`echo $CCDsize | awk '{print($1-1)}'`
boxpixel=50
echo "#############"
wc -l $listotxy
echo "#############"
xtrimimage $listotxy
wait
xfit2jpg $listotxy
wait
xmkupload
wait
