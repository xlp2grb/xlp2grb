echo "to plot the obj num and bg bright plot"
titlefileCCD=$1
timenow=`date -u +%Y%m%d%H%M%S`
titlefile=`echo $titlefileCCD"_"$timenow`
                                            
objlimit=$2
bgbrightlimit=$3
objnumpngfile=objnum.png
bgbrightpngfile=bgbright.png
gnuplot << EOF
set term png
set output "$objnumpngfile"
set xlabel "Images"
set ylabel "Object Num. detected (> $objlimit)"
set grid
set key left
set key box
set title "$titlefile"
f(x)=0
plot 'allxyObjNumAndBgBright.cat.plot' u 1:2 w lp pt 6 ps 2 title ''

set output "$bgbrightpngfile"
set ylabel "Bg bright (< $bgbrightlimit)"
plot [][] 'allxyObjNumAndBgBright.cat.plot' u 1:3 w lp pt 6 ps 2 title ''
reset
quit
EOF
#displayPadNum=`ps -all | awk '{if($14=="display") print($4)}'`
#kill -9 $displayPadNum
#display -resize 500x500+0+0 $pngfile &

