echo "to plot the limit mag"
titlefileCCD=$1
timenow=`date -u +%Y%m%d%H%M%S`
titlefile=`echo $titlefileCCD"_"$timenow`
limitmagpngfile=Limitmag.png
gnuplot << EOF
set term png
set output "$limitmagpngfile"
set xlabel "Images"
set ylabel "Limit mag in R-band (>10 is real)"
set grid
set key left
set key box
set title "$titlefile"
plot 'allxyaveragelimitCol.cat' u 1:2 w lp pt 6 ps 2 title ''
reset
EOF
