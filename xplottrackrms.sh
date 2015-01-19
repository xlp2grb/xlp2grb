echo "to plot the track and rms plot"
titlefileCCD=$1
timenow=`date -u +%Y%m%d%H%M%S`
titlefile=`echo $titlefileCCD"_"$timenow`
                                            
trackpngfile=Track.png
rmspngfile=Trackrms.png
if test -s allxyshiftfalse.cat.plot
then
gnuplot << EOF
set term png
set output "$trackpngfile"
set xlabel "Images"
set ylabel "Delta pixels (new-temp)"
set grid
set key left
set key box
set title "$titlefile"
f(x)=0
plot [][-40:40]'allxyshift.cat.plot' u 1:2 w lp pt 6 ps 2 title 'DeltaX','allxyshift.cat.plot' u 1:3 w lp pt 8 ps 2 title 'DeltaY','allxyshiftfalse.cat.plot' u 1:2 w p pt 6 ps 2 title 'X false', 'allxyshiftfalse.cat.plot' u 1:3 w p pt 8 ps 2 title 'Y false',f(x) w l lt -1 lw 1 title 'Ref'
set output "$rmspngfile"
set ylabel "X/Y RMS for xyxymatch"
plot [][*:0.2] 'allxyrms.cat.plot' u 1:2 w lp pt 6 ps 2 title 'xrms','allxyrms.cat.plot' u 1:3 w lp pt 8 ps 2 title 'yrms','allxyrmsfalse.cat.plot' u 1:2 w p pt 6 ps 2 title 'X false', 'allxyshiftfalse.cat.plot' u 1:3 w p pt 8 ps 2 title 'Y false'
reset
quit
EOF
else
gnuplot << EOF
set term png
set output "$trackpngfile"
set xlabel "Images"
set ylabel "Delta pixels (new-temp)"
set grid
set key left
set key box
set title "$titlefile"
f(x)=0
plot [][-40:40]'allxyshift.cat.plot' u 1:2 w lp pt 6 ps 2 title 'DeltaX','allxyshift.cat.plot' u 1:3 w lp pt 8 ps 2 title 'DeltaY',f(x) w l lt -1 lw 1 title 'Ref'
set output "$rmspngfile"
set ylabel "X/Y RMS for xyxymatch"
plot [][*:0.2] 'allxyrms.cat.plot' u 1:2 w lp pt 6 ps 2 title 'xrms','allxyrms.cat.plot' u 1:3 w lp pt 8 ps 2 title 'yrms'
reset
quit
EOF
fi

