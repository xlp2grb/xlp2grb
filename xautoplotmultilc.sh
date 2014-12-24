ls abc*.cat.output >listcatoutput
for file in `cat listcatoutput`
do
Filename=$file
xcoord=`cat $Filename | head -1 |  sed 's/abc/ /' | sed 's/_/ /' | sed 's/.cat.output/ /' | awk '{print($2)}'`
ycoord=`cat $Filename | head -1 | sed 's/abc/ /' | sed 's/_/ /' | sed 's/.cat.output/ /' | awk '{print($3)}'`
Rmag=`cat $Filename  | head -1 | sed 's/abc/ /' | sed 's/_/ /' | sed 's/.cat.output/ /' | awk '{print($4)}'`
./xcctranXY2RaDec.sh $xcoord $ycoord >resxy2radec
ra=`cat resxy2radec | awk '{print($5)}'`
dec=`cat resxy2radec | awk '{print($6)}'`
#cat $Filename | awk '{print($1-2456300,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$8-$14+$18)}' | sort -n -k 1 |  column -t >resfilenameoutput
cat $Filename | awk '{print($1-2456300,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$11-$17+$21)}' | sort -n -k 1 |  column -t >resfilenameoutput

#mv resfilenameoutput $Filename

lcname=`echo "xlc_"$Filename".png"`
sourcename=`echo $ra"_"$dec"_"$Rmag`
gnuplot << EOF
set term png
set output "$lcname"
set xlabel "jd-2456300 (days)"
set ylabel "White mag calibrated by USNOB1.0 Rmag"
set title '$sourcename'
set grid
set yrange [] reverse
plot "resfilenameoutput" u 1:22 w lp t ''
EOF
rm -rf resfilenameoutput
displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
kill -9 $displayPadNum
display -resize 1012x1012+0+0 $lcname &
cp $lcname ../png
sleep 0.3
done

