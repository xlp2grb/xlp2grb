echo "to plot the fwhm"
titlefileCCD=$1
timenow=`date -u +%Y%m%d%H%M%S`
titlefile=`echo $titlefileCCD"_"$timenow`
fwhmpngfile=average_fwhm.jpg
if test -s allxyfwhmfalse.cat.plot
then
gnuplot << EOF
set term jpeg enhanced
set output "$fwhmpngfile"
set xlabel "Images"
set ylabel "FWHM pixel"
set grid
set title "$titlefile"
plot [][*:*] "allxyfwhm.cat.plot" u 1:5 title 'fwhm' with lp pt 2 ,'fwhm_lastdata' u 1:5  title '' with p pt 5 ps 3,'allxyfwhmfalse.cat.plot' u 1:5 title 'false' with p pt 2
reset
EOF
else
gnuplot << EOF
set term jpeg enhanced
set output "$fwhmpngfile"
set xlabel "Images"
set ylabel "FWHM pixel"
set grid
set title "$titlefile"
plot [][*:*] "allxyfwhm.cat.plot" u 1:5 title 'fwhm' with lp pt 2 ,'fwhm_lastdata' u 1:5  title '' with p pt 5 ps 3
reset
EOF
fi

