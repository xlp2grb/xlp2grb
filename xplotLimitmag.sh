echo "to plot the limit mag"
titlefileCCD=$1
timenow=`date -u +%Y%m%d%H%M%S`
titlefile=`echo $titlefileCCD"_"$timenow`
limitmagpngfile=Limitmag.png
if test -s allxyaveragelimitfalseCol.cat
then
gnuplot << EOF
set term png
set output "$limitmagpngfile"
set xlabel "Images"
set ylabel "Limit mag in R-band"
set grid
set key left
set key box
set title "$titlefile"
plot 'allxyaveragelimitCol.cat' u 1:2 w lp pt 6 ps 2 title 'Limitmag','allxyaveragelimitfalseCol.cat' u 1:2 w p pt 6 ps 2 title 'false'
reset
EOF
else
gnuplot << EOF
set term png
set output "$limitmagpngfile"
set xlabel "Images"
set ylabel "Limit mag in R-band"
set grid
set key left
set key box
set title "$titlefile"
plot 'allxyaveragelimitCol.cat' u 1:2 w lp pt 6 ps 2 title 'Limitmag'
reset
EOF
fi
