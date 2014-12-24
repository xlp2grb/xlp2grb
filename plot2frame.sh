#!/bin/bash
FITFILEnew=$1
ImageNum=`echo $FITFILEnew | cut -c16-26`
gnuplot <<EOF
set term png
set output "plot2frame.png"
set xlabel "x-axis pixel ($ImageNum)"
set ylabel "y-axis pixel "
set grid
set title "green:OTC1_all; red:OTC1_new; blue:OTC2_all; pink:OTC2_new"
#set key outside
#set key left 
#plot [1:3056][1:3056] 'listnewskyot.list' u 5:6 with p pt 7 ps 1 title 'new','listskyot.list' u 5:6 with p pt 4 ps 0.2 title '40img','list2frame.list' u 5:6  with p pt 6 ps 1 title '2framesall', 'newframeOT.obj' u 5:6 with p pt 6 ps 1 title 'newOT'
plot [1:3056][1:3056] 'listnewskyot.list' u 5:6 with p pt 7 ps 1 title '','listskyot.list' u 5:6 with p pt 4 ps 0.2 title '','list2frame.list' u 5:6  with p pt 6 ps 2 title '', 'newframeOT.obj' u 5:6 with p pt 6 ps 3 title ''
set output "plot2frame_sky.png"
set xlabel "RA deg ($ImageNum)"
set ylabel "DEC deg"
set grid
plot [1:3056][1:3056] 'listnewskyot.list' u 1:2 with p pt 7 ps 1 title '','listskyot.list' u 1:2 with p pt 4 ps 0.2 title '','list2frame.list' u 1:2  with p pt 6 ps 2 title '', 'newframeOT.obj' u 1:2 with p pt 6 ps 3 title ''
quit
EOF

