echo "to plot the different extinction relatvie to temp image"
titlefileCCD=$1
timenow=`date -u +%Y%m%d%H%M%S`
titlefile=`echo $titlefileCCD"_"$timenow`
DiffExtincpngfile=DiffExtinc.png
gnuplot << EOF
set term png
set output "$DiffExtincpngfile"
set xlabel "Images"
set ylabel "R_newimg - R_tempimg  (>-4 is real)"
set grid
set key left
set key box
set title "$titlefile"
#set yrange[] reverse
plot 'allxyDiffMagCol.cat.plot' u 1:2 w lp pt 6 ps 2 title ''
reset
EOF
