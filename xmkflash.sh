#!/bin/bash
#author: xlp
#date: 20140428
#aim: to get the pngfile of the same OT and then convert the the gif
xpng2flash ( )
{
	pngname=`cat listsame | tr '\n' ' '`
	flashname=`cat listsame | head -1 | sed s'/.png/.gif/'`
	echo $flashname
	convert -delay 50 $pngname -loop 1 $flashname
      	wait
	mv $pngname bakfile
}


xgetsamefieldpng ( )
{
        newimg=`cat listpng | head -1 `
        xcr=`echo $newimg | sed s'/X/ /' | sed s'/Y/ /' | sed s'/.png/ /' | awk '{print($2)}'`
        ycr=`echo $newimg | sed s'/X/ /' | sed s'/Y/ /' | sed s'/.png/ /' | awk '{print($3)}'`
        if [ "$xcr" != "$xcf" ] || [ "$ycr" != "$ycf"  ]
        then
#		echo $xcr $ycr $xcf $ycf
                xcf=`echo $xcr` 
                ycf=`echo $ycr` 
		xpng2flash
                echo $newimg >listsame
        else
#		echo $newimg
                echo $newimg >>listsame 
        fi
        m=`echo $j | awk '{print($1+1)}'`
        j=`echo $m`
        xloop
}

xloop ( )
{
        if [ $j -lt $Numpng  ]
        then
                sed -n '2,20000p' listpng >temp
                mv temp listpng
                xgetsamefieldpng
	else
		xpng2flash
        fi
}

while :
do
	if test ! -r bakfile
	then
		mkdir bakfile
	fi
	if test ! -r *.png
	then
		continue
	fi
	ls *.png >listpng
	Numpng=`wc listpng | awk '{print($1)}'`
	firstimg=`cat listpng | head -1 `
	xcf=`echo $firstimg | sed s'/X/ /' | sed s'/Y/ /' | sed s'/.png/ /' | awk '{print($2)}'`
	ycf=`echo $firstimg | sed s'/X/ /' | sed s'/Y/ /' | sed s'/.png/ /' | awk '{print($3)}'`
	echo $firstimg >listsame
	#echo $xcf $ycf
	j=1
	xloop
done
