echo "to plot the time total plot"
titlefile=$1
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
plot 'allxytimeNeed.cat.plot' u 1:2 w lp pt 6 ps 2 title ''
reset
quit
EOF
