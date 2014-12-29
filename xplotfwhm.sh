echo "to plot the fwhm"
titlefileCCD=$1
timenow=`date -u +%Y%m%d%H%M%S`
titlefile=`echo $titlefileCCD"_"$timenow`
fwhmpngfile=average_fwhm.png
gnuplot << EOF
set term png
set output "$fwhmpngfile"
set xlabel "Images"
set ylabel "FWHM (pixel)"
set grid
set title "$titlefile"
plot [][*:*] "averagefile_fin" u 1:5 title '' with lp pt 2 ,'fwhm_lastdata' u 1:5  title '' with p pt 5 ps 3
reset
EOF
