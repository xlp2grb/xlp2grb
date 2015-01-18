echo "to plot the time total plot"
titlefileCCD=$1
timenow=`date -u +%Y%m%d%H%M%S`
titlefile=`echo $titlefileCCD"_"$timenow`

Timeneedpngfile=Timeneed.png
gnuplot << EOF
set term png
set output "$Timeneedpngfile"
set xlabel "Images"
set ylabel "Total time for reduction"
set grid
set key left
set key box
set title "$titlefile"
plot [0:*] 'allxytimeNeed.cat.plot' u 1:2 w lp pt 6 ps 2 title ''
reset
quit
EOF
