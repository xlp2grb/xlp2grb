#!/bin/bash
newimgMaglimit=$1

gnuplot << EOF
set term png 
set output "$newimgMaglimit"
set xlabel "Magnitude"
set ylabel "Ratio of detected stars to full number of USNO B2 stars"
set grid     
set key left 
f(x)=a*x+b   
fit [][0.3:0.7] f(x) 'newrefall_maglimit.res.cat' u 1:2 via a,b  
plot [8:14][0:1]'newrefall_maglimit.res.cat' u 1:2 t '0.1magbin',f(x) t 'fit[0.3:0.7]'
quit         
EOF
aa=`cat fit.log | tail -9 | head -1 | awk '{print($3)}'`
bb=`cat fit.log | tail -8 | head -1 | awk '{print($3)}'`
echo "The fit formula for mag bin is f(x)=$aa*x+$bb at the range [0.3:0.7]"
limitMagFromMagbin=`echo $aa $bb | awk '{print((0.5-$2)/$1)}'`
echo "the limit magnitude at 50% from magbin in R band is $limitMagFromMagbin"
