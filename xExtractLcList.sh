#!/bin/bash

#cRmag=9.91 #the R1mag for the compare star
listfile=$1
bakfile=`echo $listfile".bak"`
cp $listfile $bakfile
lineall=`wc $listfile | awk '{print($1)}'`
echo "The total star num. is " $lineall
while [ "$lineall" -gt 0 ]
do
	cat $listfile | head -1 >listfile1
	xcoord=`cat listfile1 | awk '{print($1)}'`
	ycoord=`cat listfile1 | awk '{print($2)}'`
	Rmag=`cat listfile1 | awk '{print($3)}'`
	resfilename=`echo $xcoord"_"$ycoord"_"$Rmag".cat"`
	resfilenameoutput=`echo $resfilename".output"` 
	echo $xcoord $ycoord >$resfilename
	./xExtractLc.sh $resfilename

	lcname=`echo $resfilename".png"`
	./xcctranXY2RaDec.sh $xcoord $ycoord >resxy2radec
	ra=`cat resxy2radec | awk '{print($5)}'`
	dec=`cat resxy2radec | awk '{print($6)}'`
	sourcename=`echo $ra"_"$dec"_"$Rmag`
#	cat $resfilenameoutput | awk '{print($1-2456300,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$8-$14+cRmag)}' cRmag=$cRmag | sort |  column -t >resfilenameoutput
	cat $resfilenameoutput | awk '{print($1-2456300,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$8-$14+$18)}' | sort -n -k 1 |  column -t >resfilenameoutput
	mv resfilenameoutput $resfilenameoutput 	

gnuplot << EOF
plot sin(x)
set term png
set output "$lcname"
set xlabel "jd-2456300 (days)"
set ylabel "White mag collibrated by a comp star in USNOB1.0 Rmag"
set title '$sourcename'
set grid
set yrange [] reverse
plot "$resfilenameoutput" u 1:19 w lp t ''
EOF

	
displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
kill -9 $displayPadNum
display $lcname &
cp $lcname ../png
echo $xcoord $ycoord $Rmag
grep -v "$xcoord" $listfile >listfile1
mv listfile1 $listfile
lineall=`wc $listfile | awk '{print($1)}'`
echo "The left star num. is " $lineall	
done
