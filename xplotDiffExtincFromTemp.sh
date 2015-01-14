echo "to plot the different extinction relatvie to temp image"
titlefileCCD=$1
timenow=`date -u +%Y%m%d%H%M%S`
titlefile=`echo $titlefileCCD"_"$DiffExtinc`
DiffExtincpngfile=DiffExtinc.png
gnuplot << EOF
set term png
set output "$DiffExtincpngfile"
set xlabel "Images"
set ylabel "Diff R mag relative to Temp image"
set grid
set key left
set key box
set title "$titlefile"
plot 'DiffMagCol.cat' u 1:2 w lp pt 6 ps 2 title ''
reset
EOF
