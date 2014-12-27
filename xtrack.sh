echo "to plot the track plot"
titlefile=$1
pngfile=Track.png
gnuplot << EOF
set term png
set output "$pngfile"
set xlabel "Images"
set ylabel "Delta pixels relative to temp image"
set grid
set key left
set key box
set title "$titlefile"
f(x)=0
plot 'allxyshift.cat.plot' u 1:2 w lp pt 6 ps 2 title 'DeltaX','allxyshift.cat.plot' u 1:3 w lp pt 8 ps 2 title 'DeltaY',f(x) w l lt -1 lw 1 title 'Ref'
reset
quit
EOF
#displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
#kill -9 $displayPadNum
#display -resize 500x500+0+0 $pngfile &

